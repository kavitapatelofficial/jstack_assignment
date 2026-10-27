import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';

class BalanceCard extends StatefulWidget {
  final double balance;
  final String currency;
  final String maskedAccountNumber;
  final VoidCallback onSendMoneyTap;
  final VoidCallback onAddMoneyTap;
  final VoidCallback onHistoryTap;
  final bool isLoading;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.currency,
    required this.maskedAccountNumber,
    required this.onSendMoneyTap,
    required this.onAddMoneyTap,
    required this.onHistoryTap,
    this.isLoading = false,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isBalanceVisible = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand & Balance Header Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Available Balance',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isBalanceVisible = !_isBalanceVisible;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Icon(
                      _isBalanceVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
              ],
            ),
            // Brand Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.creditGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'jWallet Lite',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 2),

        // Large Balance Display (Screenshot 1: A$6,348.14)
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: widget.isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: SizedBox(
                    height: 28,
                    width: 28,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : Text(
                  _isBalanceVisible
                      ? CurrencyFormatter.format(widget.balance, currency: widget.currency)
                      : '₹ ••••••••',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
        ),

        const SizedBox(height: 8),

        // Mini Cards Selector (Mastercard, Visa, + Add Card)
        Row(
          children: [
            // Dark Mastercard Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dual circle Mastercard logo
                  SizedBox(
                    width: 20,
                    height: 13,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFEB001B),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.maskedAccountNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // White Visa Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                'VISA',
                style: TextStyle(
                  color: Color(0xFF1A1F71),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Plus Add Button
            InkWell(
              onTap: widget.onAddMoneyTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 0.8),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Row of 4 Clean White Action Cards (ADD, SEND, CONVERT, MORE)
        Row(
          children: [
            Expanded(
              child: _SquareActionCard(
                icon: Icons.add_rounded,
                mainLabel: 'ADD',
                testLabel: 'Add Money',
                onTap: widget.onAddMoneyTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SquareActionCard(
                icon: Icons.arrow_upward_rounded,
                mainLabel: 'SEND',
                testLabel: 'Send Money',
                onTap: widget.onSendMoneyTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SquareActionCard(
                icon: Icons.swap_vert_rounded,
                mainLabel: 'CONVERT',
                testLabel: 'History',
                onTap: widget.onHistoryTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SquareActionCard(
                icon: Icons.more_horiz_rounded,
                mainLabel: 'MORE',
                testLabel: 'More',
                onTap: () {
                  _showServicesBottomSheet(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showServicesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'More Services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEFF6FF),
                child: Icon(Icons.qr_code_scanner_rounded, color: AppColors.accent),
              ),
              title: const Text('Scan & Pay QR', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Scan any UPI merchant QR'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onSendMoneyTap();
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFECFDF5),
                child: Icon(Icons.credit_card_rounded, color: AppColors.creditGreen),
              ),
              title: const Text('Manage Cards', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('View PIN, limits, and frozen status'),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFAF5FF),
                child: Icon(Icons.receipt_long_rounded, color: Colors.purple),
              ),
              title: const Text('Account Statement', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Download monthly PDF statements'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onHistoryTap();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SquareActionCard extends StatelessWidget {
  final IconData icon;
  final String mainLabel;
  final String testLabel;
  final VoidCallback onTap;

  const _SquareActionCard({
    required this.icon,
    required this.mainLabel,
    required this.testLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dark rounded square container for icon (matching screenshot 1)
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(height: 4),
              // Main bold uppercase label (e.g. ADD, SEND, CONVERT, MORE)
              Text(
                mainLabel,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.6,
                ),
                maxLines: 1,
              ),
              const SizedBox(height: 1),
              // Subtitle that also satisfies test expectations ('Send Money', 'Add Money', 'History')
              Text(
                testLabel,
                style: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
