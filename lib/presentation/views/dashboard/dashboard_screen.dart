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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
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
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 2),
              ),
              child: CircleAvatar(
                radius: 19,
                backgroundColor: AppColors.accent,
                child: Text(
                  userInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.creditGreenBgDark : AppColors.creditGreenBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 10, color: AppColors.creditGreen),
                          SizedBox(width: 2),
                          Text(
                            'KYC',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.creditGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
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

              const SizedBox(height: 12),

              // Monthly Inflow vs Outflow Financial Pulse
              Builder(
                builder: (context) {
                  double totalCredit = 0;
                  double totalDebit = 0;
                  for (final txn in historyVm.transactions) {
                    if (txn.isCredit) {
                      totalCredit += txn.amount;
                    } else {
                      totalDebit += txn.amount;
                    }
                  }

                  return Row(
                    children: [
                      // Inflow Pill
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.creditGreen.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_downward_rounded, size: 14, color: AppColors.creditGreen),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Money In',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '+₹${totalCredit > 0 ? totalCredit.toStringAsFixed(0) : "35,000"}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.creditGreen,
                                          letterSpacing: 0,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Outflow Pill
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.debitRed.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.arrow_upward_rounded, size: 14, color: AppColors.debitRed),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Money Out',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '-₹${totalDebit > 0 ? totalDebit.toStringAsFixed(0) : "9,549"}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                          letterSpacing: 0,
                                        ),
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 18),

              // Quick Transfer Avatars Row
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Send Again',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      InkWell(
                        onTap: () => context.push('/transfer'),
                        child: const Text(
                          '+ New Transfer',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _QuickContactAvatar(
                          name: 'Rahul Sharma',
                          initials: 'RS',
                          color: const Color(0xFF2563EB),
                          onTap: () => context.push('/transfer'),
                        ),
                        const SizedBox(width: 14),
                        _QuickContactAvatar(
                          name: 'Amit Kumar',
                          initials: 'AK',
                          color: const Color(0xFF10B981),
                          onTap: () => context.push('/transfer'),
                        ),
                        const SizedBox(width: 14),
                        _QuickContactAvatar(
                          name: 'Priya Verma',
                          initials: 'PV',
                          color: const Color(0xFFA855F7),
                          onTap: () => context.push('/transfer'),
                        ),
                        const SizedBox(width: 14),
                        _QuickContactAvatar(
                          name: 'Swiggy',
                          initials: 'SW',
                          color: const Color(0xFFF97316),
                          onTap: () => context.push('/transfer'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Security & Daily Limit Insight Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.creditGreenBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.shield_rounded, size: 16, color: AppColors.creditGreen),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Fraud Protection Active',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: AppColors.creditGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Daily Limit: ₹1,00,000  •  Zero unauthorized liability',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

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
    ),
  ),
);
  }
}

class _QuickContactAvatar extends StatelessWidget {
  final String name;
  final String initials;
  final Color color;
  final VoidCallback onTap;

  const _QuickContactAvatar({
    required this.name,
    required this.initials,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: color,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 64,
            child: Text(
              name.split(' ').first,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
