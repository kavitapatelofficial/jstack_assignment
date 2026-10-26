import 'package:uuid/uuid.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../domain/entities/transaction_item.dart';
import '../../domain/entities/transfer_result.dart';
import '../../domain/repositories/transaction_repository.dart';
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
      if (_cachedTransactions.isNotEmpty &&
          (type == null || type.isEmpty || type == 'ALL') &&
          (search == null || search.trim().isEmpty)) {
        return _cachedTransactions;
      }
      rethrow;
    }
  }

  @override
  Future<TransactionItem> getTransactionDetail(String id) async {
    final response = await _transactionService.getTransactionDetail(id);
    final data = response['data'] as Map<String, dynamic>;
    return TransactionItem.fromJson(data);
  }

  @override
  Future<TransferResult> transferMoney({
    required String beneficiaryName,
    required String mobileNumber,
    required double amount,
    String? remarks,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? _uuid.v4();
    final response = await _transactionService.transferMoney(
      beneficiaryName: beneficiaryName,
      mobileNumber: mobileNumber,
      amount: amount,
      remarks: remarks,
      idempotencyKey: key,
    );
    final data = response['data'] as Map<String, dynamic>;
    return TransferResult.fromJson(data);
  }
}
