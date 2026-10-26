import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class TransferConfirmationSheet extends StatelessWidget {
  final String beneficiaryName;
  final String mobileNumber;
  final double amount;
  final String? remarks;
  final double availableBalance;
  final bool isSubmitting;
  final VoidCallback onConfirm;

  const TransferConfirmationSheet({
    super.key,
    required this.beneficiaryName,
    required this.mobileNumber,
    required this.amount,
    this.remarks,
    required this.availableBalance,
    required this.isSubmitting,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remainingBalance = availableBalance - amount;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'Confirm Transfer',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Please review the transfer details before proceeding',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Big Amount Display
          Center(
            child: Column(
              children: [
                Text(
                  CurrencyFormatter.format(amount),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.creditGreenBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Transfer Fee: ₹0.00 (Free)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.creditGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Transfer Route Pathway
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                      child: const Icon(Icons.account_balance_wallet_rounded, size: 14, color: AppColors.accent),
                    ),
                    const SizedBox(width: 8),
                    const Text('jWallet', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
                Row(
                  children: [
                    Container(width: 14, height: 1, color: isDark ? Colors.white24 : Colors.black26),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.creditGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('IMPS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.creditGreen)),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.creditGreen),
                  ],
                ),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.catShopping.withValues(alpha: 0.15),
                      child: Text(
                        beneficiaryName.isNotEmpty ? beneficiaryName[0] : 'U',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.catShopping),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      beneficiaryName.split(' ').first,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Summary details box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              children: [
                _DetailRow(
                  label: 'To Beneficiary',
                  value: beneficiaryName,
                  isBold: true,
                ),
                const Divider(height: 20),
                _DetailRow(
                  label: 'Mobile Number',
                  value: mobileNumber,
                ),
                if (remarks != null && remarks!.isNotEmpty) ...[
                  const Divider(height: 20),
                  _DetailRow(
                    label: 'Remarks',
                    value: remarks!,
                  ),
                ],
                const Divider(height: 20),
                _DetailRow(
                  label: 'Estimated Balance After',
                  value: CurrencyFormatter.format(remainingBalance > 0 ? remainingBalance : 0.0),
                  valueColor: remainingBalance < 0 ? AppColors.debitRed : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Buttons
          ElevatedButton(
            onPressed: isSubmitting ? null : onConfirm,
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_rounded, size: 18),
                      SizedBox(width: 8),
                      Text('Confirm & Pay', style: TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: isSubmitting ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
