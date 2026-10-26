import '../../core/storage/secure_storage_service.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../services/wallet_service.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletService _walletService;
  final SecureStorageService _storageService;

  Wallet? _cachedWallet;

  WalletRepositoryImpl({
    required WalletService walletService,
    required SecureStorageService storageService,
  })  : _walletService = walletService,
        _storageService = storageService {
    final cachedBalance = _storageService.getCachedBalance();
    if (cachedBalance != null) {
      _cachedWallet = Wallet(
        walletId: 'WALLET10001',
        currency: 'INR',
        availableBalance: cachedBalance,
        maskedAccountNumber: 'XXXX XXXX 4589',
      );
    }
  }

  @override
  Wallet? get cachedWallet => _cachedWallet;

  @override
  Future<Wallet> getWalletBalance({bool forceRefresh = false}) async {
    try {
      final response = await _walletService.getWalletBalance();
      final data = response['data'] as Map<String, dynamic>;
      final wallet = Wallet.fromJson(data);
      _cachedWallet = wallet;
      await _storageService.cacheBalance(wallet.availableBalance);
      return wallet;
    } catch (e) {
      if (_cachedWallet != null) {
        return _cachedWallet!;
      }
      rethrow;
    }
  }
}
