import 'dart:math';
import '../../core/network/api_exceptions.dart';
import '../../domain/entities/transaction_item.dart';
import '../../domain/entities/transfer_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/wallet.dart';

/// Singleton In-App Mock Data Store that provides offline fallback capabilities
/// when running without an active backend server connection.
class MockDataStore {
  MockDataStore._();
  static final MockDataStore instance = MockDataStore._();

  static const defaultUser = User(
    id: 'USR10001',
    name: 'Demo User',
    email: 'demo@jstack.co',
    phone: '+91 98765 43210',
  );

  double _availableBalance = 25450.75;
  double get availableBalance => _availableBalance;

  final List<TransactionItem> _transactions = [
    const TransactionItem(
      id: 'TXN10001',
      type: TransactionType.debit,
      amount: 1500.00,
      currency: 'INR',
      beneficiaryName: 'Rahul Sharma',
      mobileNumber: '9876543210',
      status: TransactionStatus.success,
      createdAt: '2026-10-20T10:30:00Z',
      remarks: 'Payment for services',
    ),
    const TransactionItem(
      id: 'TXN10002',
      type: TransactionType.credit,
      amount: 5000.00,
      currency: 'INR',
      beneficiaryName: 'Amit Kumar',
      mobileNumber: '9811223344',
      status: TransactionStatus.success,
      createdAt: '2026-10-19T14:15:00Z',
      remarks: 'Freelance design payout',
    ),
    const TransactionItem(
      id: 'TXN10003',
      type: TransactionType.debit,
      amount: 450.00,
      currency: 'INR',
      beneficiaryName: 'Swiggy Food Order',
      mobileNumber: '9800112233',
      status: TransactionStatus.success,
      createdAt: '2026-10-18T20:45:00Z',
      remarks: 'Dinner with family',
    ),
    const TransactionItem(
      id: 'TXN10004',
      type: TransactionType.debit,
      amount: 12000.00,
      currency: 'INR',
      beneficiaryName: 'Priya Verma',
      mobileNumber: '9822334455',
      status: TransactionStatus.failed,
      createdAt: '2026-10-17T11:00:00Z',
      remarks: 'Rent contribution',
    ),
    const TransactionItem(
      id: 'TXN10005',
      type: TransactionType.debit,
      amount: 850.00,
      currency: 'INR',
      beneficiaryName: 'Uber Rides India',
      mobileNumber: '9833445566',
      status: TransactionStatus.success,
      createdAt: '2026-10-16T18:20:00Z',
      remarks: 'Airport commute',
    ),
    const TransactionItem(
      id: 'TXN10006',
      type: TransactionType.credit,
      amount: 25000.00,
      currency: 'INR',
      beneficiaryName: 'TechCorp Solutions Pvt Ltd',
      mobileNumber: '9844556677',
      status: TransactionStatus.success,
      createdAt: '2026-10-15T09:00:00Z',
      remarks: 'Monthly salary credit',
    ),
    const TransactionItem(
      id: 'TXN10007',
      type: TransactionType.debit,
      amount: 3200.00,
      currency: 'INR',
      beneficiaryName: 'Amazon India Shopping',
      mobileNumber: '9855667788',
      status: TransactionStatus.success,
      createdAt: '2026-10-14T15:30:00Z',
      remarks: 'Electronics accessories',
    ),
    const TransactionItem(
      id: 'TXN10008',
      type: TransactionType.debit,
      amount: 2150.00,
      currency: 'INR',
      beneficiaryName: 'Electricity Bill Payment',
      mobileNumber: '9866778899',
      status: TransactionStatus.pending,
      createdAt: '2026-10-13T12:00:00Z',
      remarks: 'October bill payment',
    ),
    const TransactionItem(
      id: 'TXN10009',
      type: TransactionType.credit,
      amount: 500.00,
      currency: 'INR',
      beneficiaryName: 'Cashback Reward Credit',
      mobileNumber: '9877889900',
      status: TransactionStatus.success,
      createdAt: '2026-10-12T16:45:00Z',
      remarks: 'Festival offer cashback',
    ),
    const TransactionItem(
      id: 'TXN10010',
      type: TransactionType.debit,
      amount: 350.00,
      currency: 'INR',
      beneficiaryName: 'Starbucks Coffee',
      mobileNumber: '9888990011',
      status: TransactionStatus.success,
      createdAt: '2026-10-11T17:15:00Z',
      remarks: 'Meeting refreshments',
    ),
  ];

  ({String token, User user}) login({
    required String email,
    required String password,
  }) {
    if (email.trim().toLowerCase() == 'demo@jstack.co' && password == 'Demo@123') {
      return (token: 'offline_mock_access_token_123', user: defaultUser);
    }
    throw const UnauthorizedException(
      message: 'Invalid email or password. Please use demo@jstack.co / Demo@123',
      errorCode: 'AUTH_INVALID_CREDENTIALS',
    );
  }

  Wallet getWallet() {
    return Wallet(
      walletId: 'WALLET10001',
      currency: 'INR',
      availableBalance: _availableBalance,
      maskedAccountNumber: 'XXXX XXXX 4589',
    );
  }

  List<TransactionItem> getTransactions({String? type, String? search}) {
    return _transactions.where((txn) {
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
        if (!matchesBeneficiary && !matchesId && !matchesRemarks) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  TransactionItem getTransactionDetail(String id) {
    return _transactions.firstWhere(
      (txn) => txn.id.toLowerCase() == id.toLowerCase(),
      orElse: () => _transactions.first,
    );
  }

  TransferResult transferMoney({
    required String beneficiaryName,
    required String mobileNumber,
    required double amount,
    String? remarks,
  }) {
    if (amount <= 0) {
      throw const ValidationException(message: 'Transfer amount must be greater than zero');
    }
    if (amount > _availableBalance) {
      throw const InsufficientFundsException(
        message: 'Insufficient wallet balance to complete this transfer',
        errorCode: 'INSUFFICIENT_FUNDS',
      );
    }

    _availableBalance -= amount;
    final randomSuffix = 10000 + Random().nextInt(90000);
    final newTxnId = 'TXN$randomSuffix';
    final now = DateTime.now().toUtc().toIso8601String();

    final newTxn = TransactionItem(
      id: newTxnId,
      type: TransactionType.debit,
      amount: amount,
      currency: 'INR',
      beneficiaryName: beneficiaryName,
      mobileNumber: mobileNumber,
      status: TransactionStatus.success,
      createdAt: now,
      remarks: remarks ?? 'Quick money transfer',
    );

    _transactions.insert(0, newTxn);

    return TransferResult(
      transactionId: newTxnId,
      status: 'SUCCESS',
      amount: amount,
      currency: 'INR',
      availableBalance: _availableBalance,
      beneficiaryName: beneficiaryName,
      createdAt: now,
    );
  }
}
