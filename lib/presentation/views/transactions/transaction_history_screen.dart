import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../viewmodels/transaction_history_viewmodel.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/transaction_tile.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionHistoryViewModel>().fetchTransactions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyVm = context.watch<TransactionHistoryViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            children: [
          // Search & Filter header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              children: [
                // Search Field
                TextField(
                  controller: _searchController,
                  onChanged: (val) => historyVm.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search by beneficiary or TXN ID...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              historyVm.clearSearch();
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Chips (All, Credits, Debits)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterTab(
                        label: 'All (${historyVm.totalCount})',
                        isSelected: historyVm.filter == HistoryFilter.all,
                        onTap: () => historyVm.setFilter(HistoryFilter.all),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'Credits (${historyVm.creditCount})',
                        icon: Icons.arrow_downward_rounded,
                        color: AppColors.creditGreen,
                        isSelected: historyVm.filter == HistoryFilter.credit,
                        onTap: () => historyVm.setFilter(HistoryFilter.credit),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'Debits (${historyVm.debitCount})',
                        icon: Icons.arrow_upward_rounded,
                        color: AppColors.debitRed,
                        isSelected: historyVm.filter == HistoryFilter.debit,
                        onTap: () => historyVm.setFilter(HistoryFilter.debit),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search / Filter Indicator Sub-bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${historyVm.transactions.length} Transactions Found',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.security_rounded, size: 12, color: AppColors.creditGreen),
                    const SizedBox(width: 4),
                    Text(
                      'Idempotent & Audited',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Transactions List / States
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => historyVm.fetchTransactions(forceRefresh: true),
              color: AppColors.accent,
              child: _buildListContent(context, historyVm, isDark),
            ),
          ),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildListContent(
    BuildContext context,
    TransactionHistoryViewModel historyVm,
    bool isDark,
  ) {
    if (historyVm.isLoading && historyVm.transactions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (historyVm.state == HistoryState.error && historyVm.transactions.isEmpty) {
      return ErrorView(
        message: historyVm.errorMessage ?? 'Unable to load transaction history',
        onRetry: () => historyVm.fetchTransactions(forceRefresh: true),
      );
    }

    if (historyVm.transactions.isEmpty) {
      return EmptyView(
        title: 'No Transactions Found',
        subtitle: historyVm.searchQuery.isNotEmpty
            ? 'No transactions matching "${historyVm.searchQuery}"'
            : 'You haven\'t made any transactions under this filter yet.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: historyVm.transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final txn = historyVm.transactions[index];
        return TransactionTile(
          transaction: txn,
          onTap: () => context.push('/transaction/${txn.id}', extra: txn),
        );
      },
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    this.icon,
    this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChoiceChip(
      selected: isSelected,
      onSelected: (_) => onTap(),
      avatar: icon != null
          ? Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : (color ?? AppColors.accent),
            )
          : null,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected
            ? Colors.white
            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
      ),
      selectedColor: color ?? AppColors.accent,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      side: BorderSide(
        color: isSelected
            ? (color ?? AppColors.accent)
            : (isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
    );
  }
}
