import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/transaction_item.dart';

class StatusBadge extends StatelessWidget {
  final TransactionStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String text;
    IconData icon;

    switch (status) {
      case TransactionStatus.success:
        bg = AppColors.creditGreenBg;
        fg = AppColors.creditGreen;
        text = 'SUCCESS';
        icon = Icons.check_circle_rounded;
        break;
      case TransactionStatus.failed:
        bg = AppColors.debitRedBg;
        fg = AppColors.debitRed;
        text = 'FAILED';
        icon = Icons.cancel_rounded;
        break;
      case TransactionStatus.pending:
        bg = Colors.amber.shade100;
        fg = Colors.amber.shade900;
        text = 'PENDING';
        icon = Icons.hourglass_top_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
