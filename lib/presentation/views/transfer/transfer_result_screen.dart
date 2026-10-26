import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/transfer_result.dart';

class TransferResultScreen extends StatelessWidget {
  final bool isSuccess;
  final TransferResult? result;
  final String? errorMessage;
  final double? amount;
  final String? beneficiaryName;

  const TransferResultScreen({
    super.key,
    required this.isSuccess,
    this.result,
    this.errorMessage,
    this.amount,
    this.beneficiaryName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayAmount = result?.amount ?? amount ?? 0.0;
    final displayBeneficiary = result?.beneficiaryName ?? beneficiaryName ?? 'Beneficiary';
    final txnRef = result?.transactionId ?? 'N/A';
    final txnDate = result?.createdAt != null
        ? DateFormatter.formatIso(result!.createdAt!)
        : DateFormatter.formatDate(DateTime.now());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.go('/dashboard');
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Align(
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                // Status Icon with Multi-ring Celebration Glow
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          color: (isSuccess ? AppColors.creditGreen : AppColors.debitRed).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: isSuccess ? AppColors.creditGreenBg : AppColors.debitRedBg,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: (isSuccess ? AppColors.creditGreen : AppColors.debitRed).withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: isSuccess ? AppColors.creditGreen : AppColors.debitRed,
                          size: 50,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Title
                Text(
                  isSuccess ? 'Transfer Successful!' : 'Transfer Failed',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isSuccess
                            ? (isDark ? Colors.white : AppColors.textPrimaryLight)
                            : AppColors.debitRed,
                        letterSpacing: 0,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  isSuccess
                      ? 'Money has been transferred successfully to $displayBeneficiary'
                      : (errorMessage ?? 'Unable to process transfer at this moment'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                // Amount
                Center(
                  child: Text(
                    CurrencyFormatter.format(displayAmount),
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Receipt Card (if success)
                if (isSuccess)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                      boxShadow: isDark
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                    ),
                    child: Column(
                      children: [
                        _ReceiptRow(
                          label: 'Transaction Reference',
                          value: txnRef,
                          trailing: InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Transaction reference copied to clipboard'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(Icons.copy_rounded, size: 14, color: AppColors.accent),
                            ),
                          ),
                        ),
                        const Divider(height: 20),
                        _ReceiptRow(label: 'Beneficiary', value: displayBeneficiary),
                        const Divider(height: 20),
                        _ReceiptRow(label: 'Date & Time', value: txnDate),
                        const Divider(height: 20),
                        _ReceiptRow(
                          label: 'Updated Balance',
                          value: CurrencyFormatter.format(result?.availableBalance ?? 0.0),
                          valueColor: AppColors.creditGreen,
                          isBold: true,
                        ),
                      ],
                    ),
                  ),

                const Spacer(),

                // Action Buttons
                if (isSuccess) ...[
                  ElevatedButton(
                    onPressed: () => context.go('/dashboard'),
                    child: const Text('Back to Dashboard'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => context.pushReplacement('/transfer'),
                    child: const Text('Send Money Again'),
                  ),
                ] else ...[
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Try Again'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => context.go('/dashboard'),
                    child: const Text('Back to Dashboard'),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;
  final Widget? trailing;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
    this.trailing,
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
                color: valueColor,
              ),
            ),
            ?trailing,
          ],
        ),
      ],
    );
  }
}
