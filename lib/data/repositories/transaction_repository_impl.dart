import 'package:uuid/uuid.dart';
import '../../core/network/api_exceptions.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../domain/entities/transaction_item.dart';
import '../../domain/entities/transfer_result.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../mock/mock_data_store.dart';
import '../services/transaction_service.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionService _transactionService;
  final SecureStorageService _storageService;
  final Uuid _uuid = const Uuid();

  List<TransactionItem> _cachedTransactions = [];

  TransactionRepositoryImpl({
    required TransactionService transactionService,
    required SecureStorageService storageService,
  })  : _transactionService = transactionService,
        _storageService = storageService {
    final cached = _storageService.getCachedTransactions();
    if (cached != null) {
      _cachedTransactions = cached.map((e) => TransactionItem.fromJson(e)).toList();
    }
  }

  @override
  List<TransactionItem> get cachedTransactions => List.unmodifiable(_cachedTransactions);

  @override
  Future<List<TransactionItem>> getTransactions({
    String? type,
    String? search,
    bool forceRefresh = false,
  }) async {
    try {
      final response = await _transactionService.getTransactions(
        type: type,
        search: search,
      );
      final list = (response['data'] as List)
          .map((item) => TransactionItem.fromJson(item as Map<String, dynamic>))
          .toList();

      if ((type == null || type.isEmpty || type == 'ALL') &&
          (search == null || search.trim().isEmpty)) {
        _cachedTransactions = list;
        await _storageService.cacheTransactions(list.map((e) => e.toJson()).toList());
      }

      return list;
    } catch (e) {
      // Seamless Offline Demo Fallback
      final source = _cachedTransactions.isNotEmpty
          ? _cachedTransactions
          : MockDataStore.instance.getTransactions();

      return _filterLocalTransactions(source, type: type, search: search);
    }
  }

  List<TransactionItem> _filterLocalTransactions(
    List<TransactionItem> list, {
    String? type,
    String? search,
  }) {
    return list.where((txn) {
      if (type != null && type.isNotEmpty && type != 'ALL') {
        if (txn.type.name.toUpperCase() != type.toUpperCase()) {
          return false;
        }
      }
      if (search != null && search.trim().isNotEmpty) {
        final query = search.trim().toLowerCase();
        final matchesBeneficiary = txn.beneficiaryName.toLowerCase().contains(query);
        final matchesId = txn.id.toLowerCase().contains(query);
        final matchesRemarks = (txn.remarks ?? '').toLowerCase().contains(query);
        final matchesMobile = (txn.mobileNumber ?? '').toLowerCase().contains(query);
        final matchesAmount = txn.amount.toString().contains(query);
        if (!matchesBeneficiary && !matchesId && !matchesRemarks && !matchesMobile && !matchesAmount) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Future<TransactionItem> getTransactionDetail(String id) async {
    try {
      final response = await _transactionService.getTransactionDetail(id);
      final data = response['data'] as Map<String, dynamic>;
      return TransactionItem.fromJson(data);
    } catch (e) {
      return MockDataStore.instance.getTransactionDetail(id);
    }
  }

  @override
  Future<TransferResult> transferMoney({
    required String beneficiaryName,
    required String mobileNumber,
    required double amount,
    String? remarks,
    String? idempotencyKey,
  }) async {
    try {
      final key = idempotencyKey ?? _uuid.v4();
      final response = await _transactionService.transferMoney(
        beneficiaryName: beneficiaryName,
        mobileNumber: mobileNumber,
        amount: amount,
        remarks: remarks,
        idempotencyKey: key,
      );
      final data = response['data'] as Map<String, dynamic>;
      final result = TransferResult.fromJson(data);

      final newTxn = TransactionItem(
        id: result.transactionId,
        type: TransactionType.debit,
        amount: result.amount,
        currency: result.currency,
        beneficiaryName: beneficiaryName,
        mobileNumber: mobileNumber,
        status: TransactionStatus.success,
        createdAt: result.createdAt ?? DateTime.now().toUtc().toIso8601String(),
        remarks: remarks,
      );
      _cachedTransactions = [newTxn, ..._cachedTransactions.where((t) => t.id != newTxn.id)];
      await _storageService.cacheTransactions(_cachedTransactions.map((e) => e.toJson()).toList());

      return result;
    } catch (e) {
      if (e is InsufficientFundsException || e is ValidationException) {
        rethrow;
      }
      // Seamless Offline Demo Fallback
      final result = MockDataStore.instance.transferMoney(
        beneficiaryName: beneficiaryName,
        mobileNumber: mobileNumber,
        amount: amount,
        remarks: remarks,
      );
      final newTxn = MockDataStore.instance.getTransactionDetail(result.transactionId);
      _cachedTransactions = [newTxn, ..._cachedTransactions.where((t) => t.id != newTxn.id)];
      await _storageService.cacheTransactions(_cachedTransactions.map((e) => e.toJson()).toList());
      return result;
    }
  }
}
