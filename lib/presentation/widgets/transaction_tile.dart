import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
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

  ({Widget iconWidget, String category, String paymentMethod}) _getCategoryConfig(String name, bool isCredit) {
    final lower = name.toLowerCase();

    if (lower.contains('john') || lower.contains('williams') || lower.contains('rahul') || lower.contains('amit') || lower.contains('priya')) {
      return (
        iconWidget: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E293B),
            border: Border.all(color: const Color(0xFF334155), width: 1),
          ),
          child: const Center(
            child: Icon(Icons.person_rounded, color: Colors.white, size: 22),
          ),
        ),
        category: 'Transfers',
        paymentMethod: 'Debit card',
      );
    }
    if (lower.contains('uber') || lower.contains('ola') || lower.contains('taxi') || lower.contains('ride')) {
      return (
        iconWidget: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              'Uber',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
            ),
          ),
        ),
        category: 'Taxi',
        paymentMethod: 'Debit card',
      );
    }
    if (lower.contains('shop') || lower.contains('grocer') || lower.contains('mart') || lower.contains('avenue')) {
      return (
        iconWidget: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFDE8E8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(Icons.storefront_rounded, color: Color(0xFFE02424), size: 20),
          ),
        ),
        category: 'Grocery Shop',
        paymentMethod: 'Debit card',
      );
    }
    if (lower.contains('glovo') || lower.contains('swiggy') || lower.contains('zomato') || lower.contains('food')) {
      return (
        iconWidget: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFEF08A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              'g',
              style: TextStyle(color: Color(0xFF854D0E), fontWeight: FontWeight.w900, fontSize: 20),
            ),
          ),
        ),
        category: 'Food delivery',
        paymentMethod: 'Debit card',
      );
    }
    if (lower.contains('netflix') || lower.contains('subs') || lower.contains('prime') || lower.contains('spotify')) {
      return (
        iconWidget: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              'N',
              style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.w900, fontSize: 20),
            ),
          ),
        ),
        category: 'Subscription',
        paymentMethod: 'Debit card',
      );
    }
    if (lower.contains('northwind') || lower.contains('salary') || lower.contains('payroll') || isCredit) {
      return (
        iconWidget: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFDEF7EC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(Icons.trending_up_rounded, color: Color(0xFF0E9F6E), size: 20),
          ),
        ),
        category: 'Salary',
        paymentMethod: 'USD account',
      );
    }

    return (
      iconWidget: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Icon(Icons.receipt_rounded, color: Color(0xFF475569), size: 20),
        ),
      ),
      category: 'Payment',
      paymentMethod: 'Debit card',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _getCategoryConfig(transaction.beneficiaryName, isCredit);

    return Material(
      color: isDark ? AppColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: isDark ? 0 : 0.5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // 44x44 Avatar (Screenshot 2 Brand Icon)
              SizedBox(
                width: 44,
                height: 44,
                child: config.iconWidget,
              ),
              const SizedBox(width: 12),

              // Beneficiary & Subtitle (Category & TXN / Method)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.beneficiaryName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          config.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            '•',
                            style: TextStyle(
                              color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                              fontSize: 10,
                            ),
                          ),
                        ),
                        // Preserves transaction.id for test find.text('TXN10002')
                        Flexible(
                          child: Text(
                            transaction.id,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B),
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

              const SizedBox(width: 8),

              // Amount & Status Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isCredit ? '+' : '-'}${CurrencyFormatter.format(transaction.amount, currency: transaction.currency)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isCredit
                          ? const Color(0xFF059669) // Screenshot 2 Green: +$4,250.00
                          : (isDark ? Colors.white : const Color(0xFF0F172A)),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Test requires finding 'SUCCESS'
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
