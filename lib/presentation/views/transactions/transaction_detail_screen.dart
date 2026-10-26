import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/entities/transaction_item.dart';
import '../../../domain/repositories/transaction_repository.dart';
import '../../widgets/error_view.dart';
import '../../widgets/status_badge.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;
  final TransactionItem? initialTransaction;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
    this.initialTransaction,
  });

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  TransactionItem? _transaction;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _transaction = widget.initialTransaction;
    if (_transaction == null) {
      _fetchDetail();
    }
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = context.read<TransactionRepository>();
      final item = await repo.getTransactionDetail(widget.transactionId);
      if (mounted) {
        setState(() {
          _transaction = item;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load transaction details';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
      ),
      body: _buildBody(context, isDark),
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _transaction == null) {
      return ErrorView(
        message: _errorMessage!,
        onRetry: _fetchDetail,
      );
    }

    final txn = _transaction;
    if (txn == null) {
      return const Center(child: Text('Transaction not found'));
    }

    final isCredit = txn.isCredit;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Direction Avatar
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isCredit ? AppColors.creditGreenBg : AppColors.debitRedBg,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: isCredit ? AppColors.creditGreen : AppColors.debitRed,
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Amount
          Center(
            child: Text(
              '${isCredit ? '+' : '-'}${CurrencyFormatter.format(txn.amount, currency: txn.currency)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: isCredit ? AppColors.creditGreen : (isDark ? Colors.white : AppColors.textPrimaryLight),
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Beneficiary / Sender
          Center(
            child: Text(
              isCredit ? 'Received from ${txn.beneficiaryName}' : 'Paid to ${txn.beneficiaryName}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),

          // Status Badge
          Center(child: StatusBadge(status: txn.status)),

          const SizedBox(height: 24),

          // Settlement Timeline Stepper
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Builder(
              builder: (context) {
                final isSuccess = txn.status == TransactionStatus.success;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _TimelineStep(label: 'Initiated', isCompleted: true, color: AppColors.creditGreen),
                    const _TimelineConnector(isCompleted: true),
                    const _TimelineStep(label: 'Verified', isCompleted: true, color: AppColors.creditGreen),
                    _TimelineConnector(isCompleted: isSuccess),
                    _TimelineStep(
                      label: isSuccess ? 'Settled' : 'Failed',
                      isCompleted: isSuccess,
                      color: isSuccess ? AppColors.creditGreen : AppColors.debitRed,
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Details Card
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
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              children: [
                _DetailRow(
                  label: 'Transaction ID',
                  value: txn.id,
                  isSelectable: true,
                  trailing: InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transaction ID copied')),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(Icons.copy_rounded, size: 14, color: AppColors.accent),
                    ),
                  ),
                ),
                const Divider(height: 24),
                _DetailRow(
                  label: 'Transaction Type',
                  value: isCredit ? 'Credit (Deposit / Inflow)' : 'Debit (Instant Transfer)',
                ),
                const Divider(height: 24),
                _DetailRow(
                  label: isCredit ? 'Received From' : 'Sent To',
                  value: txn.beneficiaryName,
                ),
                if (txn.mobileNumber != null && txn.mobileNumber!.isNotEmpty) ...[
                  const Divider(height: 24),
                  _DetailRow(label: 'Beneficiary Mobile', value: txn.mobileNumber!),
                ],
                const Divider(height: 24),
                _DetailRow(
                  label: 'Date & Time',
                  value: DateFormatter.formatIso(txn.createdAt),
                ),
                const Divider(height: 24),
                _DetailRow(
                  label: 'Payment Method',
                  value: 'IMPS 24x7 Instant',
                ),
                if (txn.remarks != null && txn.remarks!.isNotEmpty) ...[
                  const Divider(height: 24),
                  _DetailRow(label: 'Remarks', value: txn.remarks!),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Repeat / Transfer button if debit
          if (txn.isDebit) ...[
            ElevatedButton.icon(
              onPressed: () {
                context.push('/transfer');
              },
              icon: const Icon(Icons.send_rounded, size: 18),
              label: Text('Send to ${txn.beneficiaryName} Again'),
            ),
            const SizedBox(height: 12),
          ],

          OutlinedButton(
            onPressed: () => context.pop(),
            child: const Text('Back'),
          ),
        ],
      ),
    ),
  ),
);
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelectable;
  final Widget? trailing;

  const _DetailRow({
    required this.label,
    required this.value,
    this.isSelectable = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              isSelectable
                  ? SelectableText(
                      value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.end,
                    )
                  : Text(
                      value,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.end,
                    ),
              ?trailing,
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String label;
  final bool isCompleted;
  final Color color;

  const _TimelineStep({
    required this.label,
    required this.isCompleted,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted ? color : Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check_rounded : Icons.circle,
            color: Colors.white,
            size: isCompleted ? 14 : 6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isCompleted ? color : Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _TimelineConnector extends StatelessWidget {
  final bool isCompleted;

  const _TimelineConnector({required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: isCompleted ? AppColors.creditGreen : Colors.grey.shade300,
      ),
    );
  }
}
