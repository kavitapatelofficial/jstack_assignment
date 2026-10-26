import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/wallet_repository_impl.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'data/services/auth_service.dart';
import 'data/services/wallet_service.dart';
import 'data/services/transaction_service.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/wallet_repository.dart';
import 'domain/repositories/transaction_repository.dart';
import 'presentation/routing/app_router.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/theme_viewmodel.dart';
import 'presentation/viewmodels/transaction_history_viewmodel.dart';
import 'presentation/viewmodels/transfer_viewmodel.dart';
import 'presentation/viewmodels/wallet_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await SecureStorageService.init();
  final apiClient = ApiClient(storageService: storageService);

  // Data layer services
  final authService = AuthService(apiClient);
  final walletService = WalletService(apiClient);
  final transactionService = TransactionService(apiClient);

  // Repositories
  final authRepository = AuthRepositoryImpl(
    authService: authService,
    storageService: storageService,
  );
  final walletRepository = WalletRepositoryImpl(
    walletService: walletService,
    storageService: storageService,
  );
  final transactionRepository = TransactionRepositoryImpl(
    transactionService: transactionService,
    storageService: storageService,
  );

  runApp(
    JWalletApp(
      storageService: storageService,
      apiClient: apiClient,
      authRepository: authRepository,
      walletRepository: walletRepository,
      transactionRepository: transactionRepository,
    ),
  );
}

class JWalletApp extends StatefulWidget {
  final SecureStorageService storageService;
  final ApiClient apiClient;
  final AuthRepository authRepository;
  final WalletRepository walletRepository;
  final TransactionRepository transactionRepository;

  const JWalletApp({
    super.key,
    required this.storageService,
    required this.apiClient,
    required this.authRepository,
    required this.walletRepository,
    required this.transactionRepository,
  });

  @override
  State<JWalletApp> createState() => _JWalletAppState();
}

class _JWalletAppState extends State<JWalletApp> {
  late final AuthViewModel _authViewModel;
  late final WalletViewModel _walletViewModel;
  late final TransferViewModel _transferViewModel;
  late final TransactionHistoryViewModel _transactionHistoryViewModel;
  late final ThemeViewModel _themeViewModel;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authViewModel = AuthViewModel(authRepository: widget.authRepository);
    _walletViewModel = WalletViewModel(walletRepository: widget.walletRepository);
    _transferViewModel = TransferViewModel(
      transactionRepository: widget.transactionRepository,
      walletViewModel: _walletViewModel,
    );
    _transactionHistoryViewModel = TransactionHistoryViewModel(
      transactionRepository: widget.transactionRepository,
    );
    _themeViewModel = ThemeViewModel(storageService: widget.storageService);

    _router = AppRouter.createRouter(_authViewModel);
  }

  @override
  void dispose() {
    _authViewModel.dispose();
    _walletViewModel.dispose();
    _transferViewModel.dispose();
    _transactionHistoryViewModel.dispose();
    _themeViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Dependencies
        Provider<SecureStorageService>.value(value: widget.storageService),
        Provider<ApiClient>.value(value: widget.apiClient),
        Provider<AuthRepository>.value(value: widget.authRepository),
        Provider<WalletRepository>.value(value: widget.walletRepository),
        Provider<TransactionRepository>.value(value: widget.transactionRepository),

        // ViewModels
        ChangeNotifierProvider<AuthViewModel>.value(value: _authViewModel),
        ChangeNotifierProvider<WalletViewModel>.value(value: _walletViewModel),
        ChangeNotifierProvider<TransferViewModel>.value(value: _transferViewModel),
        ChangeNotifierProvider<TransactionHistoryViewModel>.value(
          value: _transactionHistoryViewModel,
        ),
        ChangeNotifierProvider<ThemeViewModel>.value(value: _themeViewModel),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVm, _) {
          return MaterialApp.router(
            title: 'jWallet Lite',
            debugShowCheckedModeBanner: false,
            themeMode: themeVm.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
