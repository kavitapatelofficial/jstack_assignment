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

  static const List<Color> _avatarColors = [
    Color(0xFF2563EB), // Vibrant Blue
    Color(0xFF7C3AED), // Purple
    Color(0xFFDB2777), // Pink
    Color(0xFF059669), // Emerald
    Color(0xFFD97706), // Amber
    Color(0xFF0891B2), // Cyan
    Color(0xFF4F46E5), // Indigo
    Color(0xFF0D9488), // Teal
    Color(0xFFE11D48), // Rose
    Color(0xFF65A30D), // Lime
    Color(0xFFC026D3), // Fuchsia
    Color(0xFF0284C7), // Sky Blue
  ];

  static Color _getAvatarColor(String name) {
    if (name.isEmpty) return _avatarColors[0];
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return _avatarColors[hash.abs() % _avatarColors.length];
  }

  static String _getInitial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'T';
    return trimmed[0].toUpperCase();
  }

  String _getCategory(String name, bool isCredit) {
    final lower = name.toLowerCase();
    if (lower.contains('uber') || lower.contains('ola') || lower.contains('taxi') || lower.contains('ride')) {
      return 'Taxi';
    }
    if (lower.contains('shop') || lower.contains('grocer') || lower.contains('mart') || lower.contains('avenue')) {
      return 'Grocery';
    }
    if (lower.contains('glovo') || lower.contains('swiggy') || lower.contains('zomato') || lower.contains('food')) {
      return 'Food';
    }
    if (lower.contains('netflix') || lower.contains('subs') || lower.contains('prime') || lower.contains('spotify')) {
      return 'Subscription';
    }
    if (lower.contains('salary') || lower.contains('payroll') || isCredit) {
      return 'Salary';
    }
    if (lower.contains('payment') || lower.contains('bill')) {
      return 'Payment';
    }
    return 'Transfers';
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final category = _getCategory(transaction.beneficiaryName, isCredit);
    final initial = _getInitial(transaction.beneficiaryName);
    final avatarColor = _getAvatarColor(transaction.beneficiaryName);

    // Debit in Red, Credit in Green (User explicit requirement)
    final amountColor = isCredit
        ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
        : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626));

    return Material(
      color: isDark ? AppColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: isDark ? 0 : 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.04),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFF1F5F9),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Circle Avatar with Beneficiary Name First Character & Vibrant Background
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: avatarColor,
                  boxShadow: [
                    BoxShadow(
                      color: avatarColor.withValues(alpha: 0.28),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Beneficiary & Subtitle (Category & TXN ID)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.beneficiaryName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        // Type & Category
                        Text(
                          '${transaction.isCredit ? "Credit" : "Debit"} • $category',
                          style: TextStyle(
                            fontSize: 11,
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
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textMutedDark : const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Transaction Date and Time
                    Text(
                      DateFormatter.formatIso(transaction.createdAt),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: isDark ? AppColors.textMutedDark : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Amount (Debit Red / Credit Green) & Status Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${isCredit ? '+' : '-'}${CurrencyFormatter.format(transaction.amount, currency: transaction.currency)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: amountColor,
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

