import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../viewmodels/transaction_history_viewmodel.dart';
import '../../viewmodels/wallet_viewmodel.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/transaction_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData({bool forceRefresh = false}) async {
    final walletVm = context.read<WalletViewModel>();
    final historyVm = context.read<TransactionHistoryViewModel>();

    await Future.wait([
      walletVm.fetchWalletBalance(forceRefresh: forceRefresh),
      historyVm.fetchTransactions(forceRefresh: forceRefresh),
    ]);
  }

  void _showAddMoneyDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.creditGreenBg,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_card_rounded, color: AppColors.creditGreen),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Add Money to Wallet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Add Money via UPI, Debit Card, or Net Banking is a UI feature demonstration as specified in technical requirements.',
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of jWallet Lite?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.debitRed,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthViewModel>().logout();
              if (mounted) {
                context.go('/login');
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final walletVm = context.watch<WalletViewModel>();
    final historyVm = context.watch<TransactionHistoryViewModel>();
    final themeVm = context.watch<ThemeViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = authVm.user;
    final userName = user?.name ?? 'Demo User';
    final userInitials = user?.initials ?? 'DU';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: AppColors.accent,
              child: Text(
                userInitials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(themeVm.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => themeVm.toggleTheme(),
          ),
          IconButton(
            tooltip: 'Log Out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: _confirmLogout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadDashboardData(forceRefresh: true),
        color: AppColors.accent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet Information Card
              if (walletVm.state == WalletState.error && walletVm.wallet == null)
                ErrorView(
                  message: walletVm.errorMessage ?? 'Could not load wallet balance',
                  onRetry: () => _loadDashboardData(forceRefresh: true),
                )
              else
                BalanceCard(
                  balance: walletVm.availableBalance,
                  currency: walletVm.currency,
                  maskedAccountNumber: walletVm.maskedAccountNumber,
                  isLoading: walletVm.isLoading,
                  onSendMoneyTap: () => context.push('/transfer'),
                  onAddMoneyTap: _showAddMoneyDialog,
                  onHistoryTap: () => context.push('/history'),
                ),

              const SizedBox(height: 28),

              // Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/history'),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('See All', style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(width: 2),
                        Icon(Icons.chevron_right_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Recent Transactions List
              if (historyVm.isLoading && historyVm.transactions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (historyVm.state == HistoryState.error && historyVm.transactions.isEmpty)
                ErrorView(
                  message: historyVm.errorMessage ?? 'Failed to load transactions',
                  onRetry: () => historyVm.fetchTransactions(forceRefresh: true),
                )
              else if (historyVm.recentTransactions.isEmpty)
                const EmptyView(
                  title: 'No Transactions Yet',
                  subtitle: 'Send money to see your recent transactions here.',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: historyVm.recentTransactions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final txn = historyVm.recentTransactions[index];
                    return TransactionTile(
                      transaction: txn,
                      onTap: () => context.push('/transaction/${txn.id}', extra: txn),
                    );
                  },
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
