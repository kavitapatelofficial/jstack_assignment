import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/entities/transaction_item.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../viewmodels/transaction_history_viewmodel.dart';
import '../../viewmodels/wallet_viewmodel.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/spending_breakdown_card.dart';
import '../../widgets/transaction_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _activeNavIndex = 0;
  HistoryFilter _dashboardFilter = HistoryFilter.all;

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
        padding: const EdgeInsets.all(22.0),
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
            const SizedBox(height: 14),
            const Text(
              'Add funds instantly using UPI, Debit Card, or Net Banking with zero convenience fee.',
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Add Money Now'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCardsSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Linked Cards', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card_rounded, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mastercard Platinum', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        SizedBox(height: 2),
                        Text('•••• •••• •••• 4589', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.creditGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('ACTIVE', style: TextStyle(color: AppColors.creditGreen, fontSize: 10, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreMenu() {
    final themeVm = context.read<ThemeViewModel>();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(themeVm.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
              title: Text(themeVm.isDarkMode ? 'Switch to Light Theme' : 'Switch to Dark Theme'),
              onTap: () {
                Navigator.pop(ctx);
                themeVm.toggleTheme();
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long_rounded),
              title: const Text('Transaction History'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/history');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.debitRed),
              title: const Text('Log Out', style: TextStyle(color: AppColors.debitRed)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmLogout();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQrScanDemo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.qr_code_scanner_rounded, color: AppColors.accent),
            SizedBox(width: 8),
            Text('Scan QR Code'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
              ),
              child: const Center(
                child: Icon(Icons.qr_code_2_rounded, size: 120, color: Color(0xFF0F172A)),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Point camera at merchant UPI QR to send money seamlessly.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/transfer');
            },
            child: const Text('Proceed to Transfer'),
          ),
        ],
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

  // Groups transactions into Today, Yesterday, and Earlier dates matching Screenshot 2
  Map<String, List<TransactionItem>> _groupTransactions(List<TransactionItem> list) {
    final Map<String, List<TransactionItem>> groups = {};
    final now = DateTime.now();

    for (final txn in list) {
      DateTime? dt;
      try {
        dt = DateTime.parse(txn.createdAt).toLocal();
      } catch (_) {}

      String groupKey = 'Earlier';
      if (dt != null) {
        final diffDays = DateTime(now.year, now.month, now.day)
            .difference(DateTime(dt.year, dt.month, dt.day))
            .inDays;
        if (diffDays == 0) {
          groupKey = 'Today';
        } else if (diffDays == 1) {
          groupKey = 'Yesterday';
        } else {
          const months = [
            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
          ];
          groupKey = '${months[dt.month - 1]} ${dt.day}';
        }
      }

      groups.putIfAbsent(groupKey, () => []).add(txn);
    }
    return groups;
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

    // Total spent for the breakdown card
    final totalDebit = historyVm.totalDebit;

    final filteredRecent = historyVm.allTransactions.where((t) {
      if (_dashboardFilter == HistoryFilter.credit && !t.isCredit) return false;
      if (_dashboardFilter == HistoryFilter.debit && t.isCredit) return false;
      return true;
    }).take(5).toList();

    final groupedTxns = _groupTransactions(filteredRecent);

    return Scaffold(
      backgroundColor: const Color(0xFF050811),
      body: Stack(
        children: [
          // Main Scrollable Area
          RefreshIndicator(
            onRefresh: () => _loadDashboardData(forceRefresh: true),
            color: AppColors.accent,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Top Hero Section with Gradient
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: AppColors.modernBankHeroGradient,
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          // User Information Row (Mandatory Assignment Requirement: User name · Profile avatar/initials · Welcome message)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: const Color(0xFF60A5FA), width: 1.5),
                                      ),
                                      child: CircleAvatar(
                                        radius: 18,
                                        backgroundColor: const Color(0xFF1E3A8A),
                                        child: Text(
                                          userInitials,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getGreeting(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white.withValues(alpha: 0.75),
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
                                                color: Colors.white,
                                                letterSpacing: -0.2,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                              decoration: BoxDecoration(
                                                color: AppColors.creditGreenBgDark,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.check_circle_rounded, size: 9, color: AppColors.creditGreen),
                                                  SizedBox(width: 2),
                                                  Text(
                                                    'KYC',
                                                    style: TextStyle(
                                                      fontSize: 9,
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
                                Row(
                                  children: [
                                    IconButton(
                                      tooltip: 'Toggle Theme',
                                      icon: Icon(
                                        themeVm.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: () => themeVm.toggleTheme(),
                                    ),
                                    IconButton(
                                      tooltip: 'Log Out',
                                      icon: const Icon(
                                        Icons.logout_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: _confirmLogout,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Search Bar Capsule & Actions (Screenshot 1 Header)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Row(
                        children: [
                          // Search Pill Capsule
                          Expanded(
                            child: InkWell(
                              onTap: () => context.push('/history'),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E2430),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    width: 1,
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.search_rounded,
                                      color: Color(0xFF94A3B8),
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Search',
                                      style: TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Chat Circular Button
                          InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Support Chat: 24/7 AI Banking Assistant is ready.'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1E2430),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // More Menu Circular Button (Opens Menu Bottom Sheet)
                          InkWell(
                            onTap: _showMoreMenu,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1E2430),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.more_vert_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Hero Balance Card Area
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: BalanceCard(
                        balance: walletVm.availableBalance,
                        currency: walletVm.currency,
                        maskedAccountNumber: walletVm.maskedAccountNumber,
                        isLoading: walletVm.isLoading,
                        onSendMoneyTap: () => context.push('/transfer'),
                        onAddMoneyTap: _showAddMoneyDialog,
                        onHistoryTap: () => context.push('/history'),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),

            // White Body Sheet (Screenshot 1 & 2)
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "Transactions" Header with "View all"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Transactions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      InkWell(
                        onTap: () => context.push('/history'),
                        child: const Text(
                          'View all',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // "Spent this week" Card (Screenshot 1 breakdown bar)
                  SpendingBreakdownCard(
                    totalSpent: totalDebit,
                    currency: walletVm.currency,
                  ),

                  const SizedBox(height: 10),

                  // Quick Filter Chips (All, Credits, Debits)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _DashboardFilterChip(
                          label: 'All (${historyVm.totalCount})',
                          isSelected: _dashboardFilter == HistoryFilter.all,
                          onTap: () => setState(() => _dashboardFilter = HistoryFilter.all),
                        ),
                        const SizedBox(width: 8),
                        _DashboardFilterChip(
                          label: 'Credits (${historyVm.creditCount})',
                          icon: Icons.arrow_downward_rounded,
                          color: AppColors.creditGreen,
                          isSelected: _dashboardFilter == HistoryFilter.credit,
                          onTap: () => setState(() => _dashboardFilter = HistoryFilter.credit),
                        ),
                        const SizedBox(width: 8),
                        _DashboardFilterChip(
                          label: 'Debits (${historyVm.debitCount})',
                          icon: Icons.arrow_upward_rounded,
                          color: AppColors.debitRed,
                          isSelected: _dashboardFilter == HistoryFilter.debit,
                          onTap: () => setState(() => _dashboardFilter = HistoryFilter.debit),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Date-Grouped Transaction List (Screenshot 2)
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
                  else if (filteredRecent.isEmpty)
                    EmptyView(
                      title: 'No ${_dashboardFilter == HistoryFilter.credit ? "Credit" : (_dashboardFilter == HistoryFilter.debit ? "Debit" : "")} Transactions',
                      subtitle: 'Try changing your filter to view other transactions.',
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: groupedTxns.keys.length,
                      itemBuilder: (context, groupIndex) {
                        final groupName = groupedTxns.keys.elementAt(groupIndex);
                        final txnsInGroup = groupedTxns[groupName]!;

                        // Calculate net sum for this group
                        double groupSum = 0;
                        for (final t in txnsInGroup) {
                          if (t.isCredit) {
                            groupSum += t.amount;
                          } else {
                            groupSum -= t.amount;
                          }
                        }
                        final isNetCredit = groupSum >= 0;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Date Group Header Row (e.g. "Today" -₹109.24)
                            Padding(
                              padding: EdgeInsets.only(
                                top: groupIndex == 0 ? 2 : 10,
                                bottom: 4,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    groupName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    '${isNetCredit ? '+' : '-'}${CurrencyFormatter.format(groupSum.abs(), currency: walletVm.currency)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isNetCredit
                                          ? const Color(0xFF059669)
                                          : (isDark ? AppColors.textMutedDark : const Color(0xFF64748B)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // List of transaction items in group
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: txnsInGroup.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 6),
                              itemBuilder: (context, i) {
                                final txn = txnsInGroup[i];
                                return TransactionTile(
                                  transaction: txn,
                                  onTap: () => context.push('/transaction/${txn.id}', extra: txn),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),

          // Floating Bottom Navigation Bar + QR Scanner (Screenshots 1 & 2)
          Positioned(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom > 0
                ? MediaQuery.of(context).padding.bottom + 6
                : 16,
            child: Row(
              children: [
                // Floating Pill Navigation Bar (Home, Cards, More)
                Expanded(
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF161F33) : Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Home Pill Button
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() => _activeNavIndex = 0);
                            },
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: _activeNavIndex == 0
                                    ? const Color(0xFF2563EB).withValues(alpha: 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.home_rounded,
                                    color: _activeNavIndex == 0
                                        ? const Color(0xFF2563EB)
                                        : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                                    size: 19,
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'Home',
                                    style: TextStyle(
                                      fontSize: 10,
                                      height: 1.0,
                                      fontWeight: FontWeight.w700,
                                      color: _activeNavIndex == 0
                                          ? const Color(0xFF2563EB)
                                          : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Cards Pill Button
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() => _activeNavIndex = 1);
                              _showCardsSheet();
                            },
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.credit_card_rounded,
                                    color: _activeNavIndex == 1
                                        ? const Color(0xFF2563EB)
                                        : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                                    size: 19,
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'Cards',
                                    style: TextStyle(
                                      fontSize: 10,
                                      height: 1.0,
                                      fontWeight: FontWeight.w700,
                                      color: _activeNavIndex == 1
                                          ? const Color(0xFF2563EB)
                                          : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // More Pill Button
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() => _activeNavIndex = 2);
                              _showMoreMenu();
                            },
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.more_horiz_rounded,
                                    color: _activeNavIndex == 2
                                        ? const Color(0xFF2563EB)
                                        : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                                    size: 19,
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    'More',
                                    style: TextStyle(
                                      fontSize: 10,
                                      height: 1.0,
                                      fontWeight: FontWeight.w700,
                                      color: _activeNavIndex == 2
                                          ? const Color(0xFF2563EB)
                                          : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Floating Circular QR Scanner Action Button (Screenshot 1 & 2 right button)
                InkWell(
                  onTap: _showQrScanDemo,
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF161F33) : Colors.white,
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardFilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _DashboardFilterChip({
    required this.label,
    this.icon,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = color ?? AppColors.accent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark ? const Color(0xFF1E2430) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : primaryColor,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
