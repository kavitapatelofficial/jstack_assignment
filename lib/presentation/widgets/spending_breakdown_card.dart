import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

class SpendingBreakdownCard extends StatelessWidget {
  final double totalSpent;
  final String currency;

  const SpendingBreakdownCard({
    super.key,
    required this.totalSpent,
    this.currency = 'INR',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Proportional breakdown amounts
    final spentAmount = totalSpent > 0 ? totalSpent : 203.98;
    final transfers = spentAmount * 0.36;
    final food = spentAmount * 0.28;
    final transport = spentAmount * 0.17;
    final groceries = spentAmount * 0.11;
    final subs = spentAmount * 0.08;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spent this week',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(spentAmount, currency: currency),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),

          // Multi-segmented colored progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 7,
              child: Row(
                children: [
                  Expanded(flex: 36, child: Container(color: const Color(0xFF2563EB))),
                  const SizedBox(width: 3),
                  Expanded(flex: 28, child: Container(color: const Color(0xFFF59E0B))),
                  const SizedBox(width: 3),
                  Expanded(flex: 17, child: Container(color: const Color(0xFF8B5CF6))),
                  const SizedBox(width: 3),
                  Expanded(flex: 11, child: Container(color: const Color(0xFF14B8A6))),
                  const SizedBox(width: 3),
                  Expanded(flex: 8, child: Container(color: const Color(0xFFF43F5E))),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Legend
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildLegendItem('Transfers', transfers, const Color(0xFF2563EB), currency, isDark),
              _buildLegendItem('Food', food, const Color(0xFFF59E0B), currency, isDark),
              _buildLegendItem('Transport', transport, const Color(0xFF8B5CF6), currency, isDark),
              _buildLegendItem('Groceries', groceries, const Color(0xFF14B8A6), currency, isDark),
              _buildLegendItem('Subscriptions', subs, const Color(0xFFF43F5E), currency, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, double amount, Color color, String curr, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          '$label ',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B),
          ),
        ),
        Text(
          CurrencyFormatter.format(amount, currency: curr),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
