import '../entities/wallet.dart';

abstract class WalletRepository {
  Future<Wallet> getWalletBalance({bool forceRefresh = false});

  Wallet? get cachedWallet;
}
