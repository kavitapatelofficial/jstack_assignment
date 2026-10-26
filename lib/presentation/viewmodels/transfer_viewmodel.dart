import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../core/network/api_exceptions.dart';
import '../../domain/entities/transfer_result.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'wallet_viewmodel.dart';

enum TransferStatus { idle, confirming, submitting, success, failure }

class TransferViewModel extends ChangeNotifier {
  final TransactionRepository _transactionRepository;
  final WalletViewModel _walletViewModel;
  final Uuid _uuid = const Uuid();

  TransferStatus _status = TransferStatus.idle;
  String? _errorMessage;
  TransferResult? _lastResult;

  // Form fields
  String _beneficiaryName = '';
  String _mobileNumber = '';
  double _amount = 0.0;
  String _remarks = '';
  String? _currentIdempotencyKey;

  TransferViewModel({
    required TransactionRepository transactionRepository,
    required WalletViewModel walletViewModel,
  })  : _transactionRepository = transactionRepository,
        _walletViewModel = walletViewModel;

  TransferStatus get status => _status;
  bool get isSubmitting => _status == TransferStatus.submitting;
  String? get errorMessage => _errorMessage;
  TransferResult? get lastResult => _lastResult;

  String get beneficiaryName => _beneficiaryName;
  String get mobileNumber => _mobileNumber;
  double get amount => _amount;
  String get remarks => _remarks;
  String? get currentIdempotencyKey => _currentIdempotencyKey;

  void setFormData({
    required String beneficiaryName,
    required String mobileNumber,
    required double amount,
    String? remarks,
  }) {
    _beneficiaryName = beneficiaryName.trim();
    _mobileNumber = mobileNumber.trim();
    _amount = amount;
    _remarks = remarks?.trim() ?? '';
    _status = TransferStatus.confirming;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> executeTransfer() async {
    // Prevent duplicate submission
    if (_status == TransferStatus.submitting) return false;

    _status = TransferStatus.submitting;
    _errorMessage = null;
    notifyListeners();

    // Assign idempotency key if not already generated for this request
    _currentIdempotencyKey ??= _uuid.v4();

    try {
      final result = await _transactionRepository.transferMoney(
        beneficiaryName: _beneficiaryName,
        mobileNumber: _mobileNumber,
        amount: _amount,
        remarks: _remarks.isNotEmpty ? _remarks : null,
        idempotencyKey: _currentIdempotencyKey,
      );

      _lastResult = result;
      _status = TransferStatus.success;
      _errorMessage = null;

      // Update authoritative balance returned from backend
      _walletViewModel.updateBalanceFromBackend(result.availableBalance);

      notifyListeners();
      return true;
    } on InsufficientFundsException catch (e) {
      _errorMessage = e.message;
      _status = TransferStatus.failure;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = TransferStatus.failure;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Transfer failed due to an unexpected error.';
      _status = TransferStatus.failure;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _status = TransferStatus.idle;
    _errorMessage = null;
    _lastResult = null;
    _beneficiaryName = '';
    _mobileNumber = '';
    _amount = 0.0;
    _remarks = '';
    _currentIdempotencyKey = null;
    notifyListeners();
  }
}
