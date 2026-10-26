import 'package:flutter/foundation.dart';
import '../../core/network/api_exceptions.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';

enum WalletState { initial, loading, loaded, error }

class WalletViewModel extends ChangeNotifier {
  final WalletRepository _walletRepository;

  WalletState _state = WalletState.initial;
  Wallet? _wallet;
  String? _errorMessage;

  WalletViewModel({required WalletRepository walletRepository})
      : _walletRepository = walletRepository {
    _wallet = _walletRepository.cachedWallet;
  }

  WalletState get state => _state;
  Wallet? get wallet => _wallet;
  bool get isLoading => _state == WalletState.loading;
  String? get errorMessage => _errorMessage;

  double get availableBalance => _wallet?.availableBalance ?? 0.0;
  String get currency => _wallet?.currency ?? 'INR';
  String get maskedAccountNumber => _wallet?.maskedAccountNumber ?? 'XXXX XXXX 4589';

  Future<void> fetchWalletBalance({bool forceRefresh = false}) async {
    _state = WalletState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _wallet = await _walletRepository.getWalletBalance(forceRefresh: forceRefresh);
      _state = WalletState.loaded;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = WalletState.error;
    } catch (e) {
      _errorMessage = 'Failed to load wallet balance';
      _state = WalletState.error;
    } finally {
      notifyListeners();
    }
  }

  void updateBalanceFromBackend(double newBalance) {
    if (_wallet != null) {
      _wallet = _wallet!.copyWith(availableBalance: newBalance);
      notifyListeners();
    } else {
      fetchWalletBalance(forceRefresh: true);
    }
  }

  void reset() {
    _wallet = null;
    _state = WalletState.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
