import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/transaction_item.dart';
import 'status_badge.dart';

class TransactionTile extends StatelessWidget {
  final TransactionItem transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  ({IconData icon, Color bg, Color fg}) _getCategoryStyle(String name, bool isCredit) {
    final lower = name.toLowerCase();

    if (lower.contains('swiggy') || lower.contains('zomato') || lower.contains('food')) {
      return (
        icon: Icons.fastfood_rounded,
        bg: const Color(0xFFFFF7ED),
        fg: AppColors.catFood,
      );
    }
    if (lower.contains('amazon') || lower.contains('flipkart') || lower.contains('shop')) {
      return (
        icon: Icons.shopping_bag_rounded,
        bg: const Color(0xFFFAF5FF),
        fg: AppColors.catShopping,
      );
    }
    if (lower.contains('uber') || lower.contains('ola') || lower.contains('ride') || lower.contains('commute')) {
      return (
        icon: Icons.directions_car_rounded,
        bg: const Color(0xFFEFF6FF),
        fg: AppColors.catTravel,
      );
    }
    if (lower.contains('airtel') || lower.contains('broadband') || lower.contains('fiber') || lower.contains('bill')) {
      return (
        icon: Icons.wifi_rounded,
        bg: const Color(0xFFECFEFF),
        fg: AppColors.catBills,
      );
    }
    if (lower.contains('salary') || lower.contains('payroll')) {
      return (
        icon: Icons.account_balance_rounded,
        bg: const Color(0xFFECFDF5),
        fg: AppColors.catSalary,
      );
    }
    if (lower.contains('cashback') || lower.contains('reward')) {
      return (
        icon: Icons.stars_rounded,
        bg: const Color(0xFFFEF3C7),
        fg: AppColors.catReward,
      );
    }

    if (isCredit) {
      return (
        icon: Icons.arrow_downward_rounded,
        bg: AppColors.creditGreenBg,
        fg: AppColors.creditGreen,
      );
    }

    return (
      icon: Icons.arrow_upward_rounded,
      bg: AppColors.debitRedBg,
      fg: AppColors.debitRed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final catStyle = _getCategoryStyle(transaction.beneficiaryName, isCredit);

    return Material(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(10),
      elevation: isDark ? 0 : 0.5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Category / Direction Avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? catStyle.fg.withValues(alpha: 0.15) : catStyle.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  catStyle.icon,
                  color: catStyle.fg,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),

              // Beneficiary & ID & Date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.beneficiaryName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          transaction.id,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            DateFormatter.formatIso(transaction.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Amount & Status Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isCredit ? '+' : '-'}${CurrencyFormatter.format(transaction.amount, currency: transaction.currency)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isCredit
                          ? AppColors.creditGreen
                          : (isDark ? Colors.white : AppColors.textPrimaryLight),
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StatusBadge(status: transaction.status),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
