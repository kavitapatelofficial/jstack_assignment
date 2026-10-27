import 'package:flutter_test/flutter_test.dart';
import 'package:jstack_assignment/domain/entities/transaction_item.dart';
import 'package:jstack_assignment/domain/entities/transfer_result.dart';
import 'package:jstack_assignment/domain/repositories/transaction_repository.dart';
import 'package:jstack_assignment/presentation/viewmodels/transaction_history_viewmodel.dart';

class MockTransactionRepository implements TransactionRepository {
  List<TransactionItem> mockList = [
    const TransactionItem(
      id: 'TXN10001',
      type: TransactionType.debit,
      amount: 1500.0,
      currency: 'INR',
      beneficiaryName: 'Rahul Sharma',
      status: TransactionStatus.success,
      createdAt: '2026-10-20T10:30:00Z',
      remarks: 'Payment for services',
    ),
    const TransactionItem(
      id: 'TXN10002',
      type: TransactionType.credit,
      amount: 5000.0,
      currency: 'INR',
      beneficiaryName: 'Amit Kumar',
      status: TransactionStatus.success,
      createdAt: '2026-10-19T14:15:00Z',
      remarks: 'Salary payout',
    ),
    const TransactionItem(
      id: 'TXN10003',
      type: TransactionType.debit,
      amount: 320.0,
      currency: 'INR',
      beneficiaryName: 'Swiggy Food',
      status: TransactionStatus.success,
      createdAt: '2026-10-18T19:40:00Z',
      remarks: 'Dinner order',
    ),
    const TransactionItem(
      id: 'TXN10004',
      type: TransactionType.credit,
      amount: 1200.0,
      currency: 'INR',
      beneficiaryName: 'Cashback Reward',
      status: TransactionStatus.success,
      createdAt: '2026-10-17T11:20:00Z',
      remarks: 'Festival promotion',
    ),
  ];

  @override
  List<TransactionItem> get cachedTransactions => mockList;

  @override
  Future<List<TransactionItem>> getTransactions({
    String? type,
    String? search,
    bool forceRefresh = false,
  }) async {
    return mockList;
  }

  @override
  Future<TransactionItem> getTransactionDetail(String id) async {
    return mockList.firstWhere((t) => t.id == id);
  }

  @override
  Future<TransferResult> transferMoney({
    required String beneficiaryName,
    required String mobileNumber,
    required double amount,
    String? remarks,
    String? idempotencyKey,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  late MockTransactionRepository repository;
  late TransactionHistoryViewModel viewModel;

  setUp(() {
    repository = MockTransactionRepository();
    viewModel = TransactionHistoryViewModel(transactionRepository: repository);
  });

  group('TransactionHistoryViewModel Filter & Search Tests', () {
    test('Initializes with cached transactions and accurate counts', () {
      expect(viewModel.allTransactions.length, equals(4));
      expect(viewModel.totalCount, equals(4));
      expect(viewModel.creditCount, equals(2));
      expect(viewModel.debitCount, equals(2));
      expect(viewModel.totalDebit, equals(1820.0)); // 1500 + 320
      expect(viewModel.filter, equals(HistoryFilter.all));
      expect(viewModel.transactions.length, equals(4));
    });

    test('Filtering by Credit returns only credits without mutating master list', () {
      viewModel.setFilter(HistoryFilter.credit);

      expect(viewModel.filter, equals(HistoryFilter.credit));
      expect(viewModel.transactions.length, equals(2));
      expect(viewModel.transactions.every((t) => t.isCredit), isTrue);

      // Master counts and totalDebit remain uncorrupted
      expect(viewModel.totalCount, equals(4));
      expect(viewModel.creditCount, equals(2));
      expect(viewModel.debitCount, equals(2));
      expect(viewModel.totalDebit, equals(1820.0));
      expect(viewModel.allTransactions.length, equals(4));
    });

    test('Filtering by Debit returns only debits without mutating master list', () {
      viewModel.setFilter(HistoryFilter.debit);

      expect(viewModel.filter, equals(HistoryFilter.debit));
      expect(viewModel.transactions.length, equals(2));
      expect(viewModel.transactions.every((t) => t.isDebit), isTrue);

      // Master counts and totalDebit remain uncorrupted
      expect(viewModel.totalCount, equals(4));
      expect(viewModel.totalDebit, equals(1820.0));
    });

    test('Search query matches beneficiary name case-insensitively', () {
      viewModel.setSearchQuery('rahul');

      expect(viewModel.transactions.length, equals(1));
      expect(viewModel.transactions.first.beneficiaryName, equals('Rahul Sharma'));

      viewModel.clearSearch();
      expect(viewModel.transactions.length, equals(4));
    });

    test('Combined filter and search works properly', () {
      viewModel.setFilter(HistoryFilter.debit);
      viewModel.setSearchQuery('swiggy');

      expect(viewModel.transactions.length, equals(1));
      expect(viewModel.transactions.first.beneficiaryName, equals('Swiggy Food'));

      // Searching for a credit beneficiary under debit filter returns 0
      viewModel.setSearchQuery('amit');
      expect(viewModel.transactions.isEmpty, isTrue);
    });
  });
}
