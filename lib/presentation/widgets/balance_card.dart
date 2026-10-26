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
      children: [
        // Physical Card Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1D4ED8).withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                // Metallic Light Flare Effect
                Positioned(
                  top: -80,
                  right: -60,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.18),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                // Card Graphic Details
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Brand & Contactless
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'jWallet Lite',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 0.5),
                                ),
                                child: const Text(
                                  'PLATINUM',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.contactless_rounded,
                                color: Colors.white.withValues(alpha: 0.8),
                                size: 24,
                              ),
                              const SizedBox(width: 10),
                              // Decorative Card Emblem
                              SizedBox(
                                width: 34,
                                height: 22,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: const Color(0xFF60A5FA).withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // EMV Chip Graphic
                      Container(
                        width: 36,
                        height: 26,
                        decoration: BoxDecoration(
                          gradient: AppColors.goldChipGradient,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: const Color(0xFFFDE68A), width: 0.5),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 6,
                              left: 0,
                              right: 0,
                              child: Container(height: 1, color: Colors.black26),
                            ),
                            Positioned(
                              bottom: 6,
                              left: 0,
                              right: 0,
                              child: Container(height: 1, color: Colors.black26),
                            ),
                            Positioned(
                              left: 11,
                              top: 0,
                              bottom: 0,
                              child: Container(width: 1, color: Colors.black26),
                            ),
                            Positioned(
                              right: 11,
                              top: 0,
                              bottom: 0,
                              child: Container(width: 1, color: Colors.black26),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Balance Header with Toggle
                      Row(
                        children: [
                          Text(
                            'Available Balance',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0,
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
                              padding: const EdgeInsets.all(2.0),
                              child: Icon(
                                _isBalanceVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: widget.isLoading
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 6.0),
                                child: SizedBox(
                                  height: 26,
                                  width: 26,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              )
                            : Text(
                                _isBalanceVisible
                                    ? CurrencyFormatter.format(widget.balance,
                                        currency: widget.currency)
                                    : '₹ ••••••••',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0,
                                ),
                              ),
                      ),

                      const SizedBox(height: 12),

                      // Cardholder Name & Masked Account Number
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CARD HOLDER',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'DEMO USER',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            widget.maskedAccountNumber,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Quick Actions Modern Strip
        Row(
          children: [
            Expanded(
              child: _ModernActionButton(
                icon: Icons.send_rounded,
                label: 'Send Money',
                subtitle: 'Instant',
                color: const Color(0xFF2563EB),
                onTap: widget.onSendMoneyTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ModernActionButton(
                icon: Icons.add_circle_rounded,
                label: 'Add Money',
                subtitle: 'UPI & Cards',
                color: const Color(0xFF10B981),
                onTap: widget.onAddMoneyTap,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ModernActionButton(
                icon: Icons.receipt_long_rounded,
                label: 'History',
                subtitle: 'Records',
                color: const Color(0xFF8B5CF6),
                onTap: widget.onHistoryTap,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModernActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ModernActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: isDark ? 0 : 1,
      shadowColor: color.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.2),
                      color.withValues(alpha: 0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 1),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
