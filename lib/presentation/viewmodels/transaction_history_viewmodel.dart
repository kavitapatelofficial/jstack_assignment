import 'package:flutter/foundation.dart';
import '../../core/network/api_exceptions.dart';
import '../../domain/entities/transaction_item.dart';
import '../../domain/repositories/transaction_repository.dart';

enum HistoryFilter { all, credit, debit }
enum HistoryState { initial, loading, loaded, error }

class TransactionHistoryViewModel extends ChangeNotifier {
  final TransactionRepository _transactionRepository;

  HistoryState _state = HistoryState.initial;
  List<TransactionItem> _allTransactions = [];
  String? _errorMessage;

  HistoryFilter _filter = HistoryFilter.all;
  String _searchQuery = '';

  TransactionHistoryViewModel({
    required TransactionRepository transactionRepository,
  }) : _transactionRepository = transactionRepository {
    _allTransactions = _transactionRepository.cachedTransactions;
    if (_allTransactions.isNotEmpty) {
      _state = HistoryState.loaded;
    }
  }

  HistoryState get state => _state;
  bool get isLoading => _state == HistoryState.loading;
  String? get errorMessage => _errorMessage;
  HistoryFilter get filter => _filter;
  String get searchQuery => _searchQuery;

  // Unmodifiable access to master list
  List<TransactionItem> get allTransactions => List.unmodifiable(_allTransactions);

  // Accurate counts for filter tabs
  int get totalCount => _allTransactions.length;
  int get creditCount => _allTransactions.where((t) => t.isCredit).length;
  int get debitCount => _allTransactions.where((t) => !t.isCredit).length;

  // Reactive filtered list matching selected tab and search query
  List<TransactionItem> get transactions {
    return _allTransactions.where((txn) {
      // 1. Credit / Debit filter
      if (_filter == HistoryFilter.credit && !txn.isCredit) {
        return false;
      }
      if (_filter == HistoryFilter.debit && txn.isCredit) {
        return false;
      }

      // 2. Search query filter
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.trim().toLowerCase();
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

  // Latest 5 transactions for dashboard display
  List<TransactionItem> get recentTransactions => _allTransactions.take(5).toList();

  // Total debited amount for dashboard spending breakdown
  double get totalDebit {
    return _allTransactions
        .where((t) => !t.isCredit)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  bool get isEmpty => _state == HistoryState.loaded && transactions.isEmpty;

  Future<void> fetchTransactions({bool forceRefresh = false}) async {
    // Only show loading spinner if we don't have any cached transactions yet
    if (_allTransactions.isEmpty) {
      _state = HistoryState.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final list = await _transactionRepository.getTransactions(
        forceRefresh: forceRefresh,
      );

      _allTransactions = list;
      _state = HistoryState.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      if (_allTransactions.isEmpty) {
        _errorMessage = e.message;
        _state = HistoryState.error;
      }
    } catch (e) {
      if (_allTransactions.isEmpty) {
        _errorMessage = 'Failed to load transactions';
        _state = HistoryState.error;
      }
    } finally {
      notifyListeners();
    }
  }

  // Instant 0ms filter change
  void setFilter(HistoryFilter newFilter) {
    if (_filter != newFilter) {
      _filter = newFilter;
      notifyListeners();
    }
  }

  // Instant 0ms search as you type
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Instant 0ms clear search
  void clearSearch() {
    if (_searchQuery.isNotEmpty) {
      _searchQuery = '';
      notifyListeners();
    }
  }
}
