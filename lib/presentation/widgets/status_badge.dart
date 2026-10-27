import 'package:flutter/material.dart';
import '../../domain/entities/transaction_item.dart';

class StatusBadge extends StatelessWidget {
  final TransactionStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    Color borderColor;
    String text;
    IconData icon;

    switch (status) {
      case TransactionStatus.success:
        bg = isDark ? const Color(0x2610B981) : const Color(0xFFECFDF5);
        fg = isDark ? const Color(0xFF34D399) : const Color(0xFF047857);
        borderColor = isDark ? const Color(0x4D10B981) : const Color(0xFFA7F3D0);
        text = 'SUCCESS';
        icon = Icons.check_circle_rounded;
        break;
      case TransactionStatus.failed:
        bg = isDark ? const Color(0x26EF4444) : const Color(0xFFFEF2F2);
        fg = isDark ? const Color(0xFFF87171) : const Color(0xFFB91C1C);
        borderColor = isDark ? const Color(0x4DEF4444) : const Color(0xFFFECACA);
        text = 'FAILED';
        icon = Icons.cancel_rounded;
        break;
      case TransactionStatus.pending:
        bg = isDark ? const Color(0x26F59E0B) : const Color(0xFFFFFBEB);
        fg = isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
        borderColor = isDark ? const Color(0x4DF59E0B) : const Color(0xFFFDE68A);
        text = 'PENDING';
        icon = Icons.schedule_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: fg),
          const SizedBox(width: 3.5),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: fg,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

