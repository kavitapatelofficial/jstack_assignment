import 'package:flutter/foundation.dart';
import '../../core/network/api_exceptions.dart';
import '../../domain/entities/transaction_item.dart';
import '../../domain/repositories/transaction_repository.dart';

enum HistoryFilter { all, credit, debit }
enum HistoryState { initial, loading, loaded, error }

class TransactionHistoryViewModel extends ChangeNotifier {
  final TransactionRepository _transactionRepository;

  HistoryState _state = HistoryState.initial;
  List<TransactionItem> _transactions = [];
  String? _errorMessage;

  HistoryFilter _filter = HistoryFilter.all;
  String _searchQuery = '';

  TransactionHistoryViewModel({
    required TransactionRepository transactionRepository,
  }) : _transactionRepository = transactionRepository {
    _transactions = _transactionRepository.cachedTransactions;
  }

  HistoryState get state => _state;
  bool get isLoading => _state == HistoryState.loading;
  String? get errorMessage => _errorMessage;
  HistoryFilter get filter => _filter;
  String get searchQuery => _searchQuery;

  List<TransactionItem> get transactions => _transactions;
  List<TransactionItem> get recentTransactions => _transactions.take(5).toList();
  bool get isEmpty => _state == HistoryState.loaded && _transactions.isEmpty;

  Future<void> fetchTransactions({bool forceRefresh = false}) async {
    _state = HistoryState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      String? typeParam;
      if (_filter == HistoryFilter.credit) typeParam = 'CREDIT';
      if (_filter == HistoryFilter.debit) typeParam = 'DEBIT';

      final list = await _transactionRepository.getTransactions(
        type: typeParam,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        forceRefresh: forceRefresh,
      );

      _transactions = list;
      _state = HistoryState.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = HistoryState.error;
    } catch (e) {
      _errorMessage = 'Failed to load transactions';
      _state = HistoryState.error;
    } finally {
      notifyListeners();
    }
  }

  void setFilter(HistoryFilter newFilter) {
    if (_filter != newFilter) {
      _filter = newFilter;
      fetchTransactions();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    fetchTransactions();
  }

  void clearSearch() {
    if (_searchQuery.isNotEmpty) {
      _searchQuery = '';
      fetchTransactions();
    }
  }
}
