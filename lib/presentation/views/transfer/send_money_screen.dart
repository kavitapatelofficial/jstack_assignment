import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../viewmodels/transfer_viewmodel.dart';
import '../../viewmodels/wallet_viewmodel.dart';
import '../../widgets/app_text_field.dart';
import 'transfer_confirmation_sheet.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _amountController = TextEditingController();
  final _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransferViewModel>().reset();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _amountController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _reviewTransfer() {
    if (!_formKey.currentState!.validate()) return;

    final walletVm = context.read<WalletViewModel>();
    final transferVm = context.read<TransferViewModel>();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    transferVm.setFormData(
      beneficiaryName: _nameController.text,
      mobileNumber: _mobileController.text,
      amount: amount,
      remarks: _remarksController.text,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Consumer<TransferViewModel>(
          builder: (context, vm, _) {
            return TransferConfirmationSheet(
              beneficiaryName: _nameController.text.trim(),
              mobileNumber: _mobileController.text.trim(),
              amount: amount,
              remarks: _remarksController.text.trim(),
              availableBalance: walletVm.availableBalance,
              isSubmitting: vm.isSubmitting,
              onConfirm: () async {
                final router = GoRouter.of(context);
                final success = await vm.executeTransfer();
                if (sheetContext.mounted) {
                  Navigator.pop(sheetContext);
                }
                if (!mounted) return;
                if (success) {
                  router.pushReplacement(
                    '/transfer-result',
                    extra: {
                      'isSuccess': true,
                      'result': vm.lastResult,
                    },
                  );
                } else {
                  router.push(
                    '/transfer-result',
                    extra: {
                      'isSuccess': false,
                      'errorMessage': vm.errorMessage ?? 'Transfer failed',
                      'amount': amount,
                      'beneficiaryName': _nameController.text.trim(),
                    },
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  void _fillSampleBeneficiary(String name, String phone) {
    _nameController.text = name;
    _mobileController.text = phone;
  }

  @override
  Widget build(BuildContext context) {
    final walletVm = context.watch<WalletViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Money'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Available Balance Card with Live Calculations
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF161F33), const Color(0xFF0F172A)]
                          : [Colors.white, const Color(0xFFF1F5F9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.creditGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 20,
                              color: AppColors.creditGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available in Wallet',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                CurrencyFormatter.format(walletVm.availableBalance, currency: walletVm.currency),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.creditGreen,
                                  letterSpacing: 0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Instant IMPS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Frequent Beneficiaries
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequent Beneficiaries',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _QuickBeneficiaryChip(
                            name: 'Rahul Sharma',
                            phone: '9876543210',
                            onTap: () => _fillSampleBeneficiary('Rahul Sharma', '9876543210'),
                          ),
                          const SizedBox(width: 10),
                          _QuickBeneficiaryChip(
                            name: 'Amit Kumar',
                            phone: '9811223344',
                            onTap: () => _fillSampleBeneficiary('Amit Kumar', '9811223344'),
                          ),
                          const SizedBox(width: 10),
                          _QuickBeneficiaryChip(
                            name: 'Priya Verma',
                            phone: '9823456789',
                            onTap: () => _fillSampleBeneficiary('Priya Verma', '9823456789'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // Form Inputs Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Beneficiary Name
                      AppTextField(
                        controller: _nameController,
                        label: 'Beneficiary Name *',
                        hint: 'e.g. Rahul Sharma',
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        validator: Validators.validateBeneficiaryName,
                      ),

                      const SizedBox(height: 18),

                      // Mobile Number
                      AppTextField(
                        controller: _mobileController,
                        label: 'Mobile Number *',
                        hint: '10-digit mobile number',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        prefixIcon: const Icon(Icons.phone_outlined),
                        validator: Validators.validateMobileNumber,
                      ),

                      const SizedBox(height: 18),

                      // Transfer Amount
                      AppTextField(
                        controller: _amountController,
                        label: 'Transfer Amount (₹) *',
                        hint: '0.00',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        prefixIcon: const Icon(Icons.currency_rupee_rounded),
                        validator: (val) => Validators.validateAmount(
                          val,
                          maxBalance: walletVm.availableBalance,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Quick Amount Chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...[500, 1000, 2000, 5000].map((quickAmt) {
                            return ActionChip(
                              label: Text('+₹$quickAmt', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              onPressed: () {
                                setState(() {
                                  _amountController.text = quickAmt.toDouble().toStringAsFixed(2);
                                });
                              },
                              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                              side: BorderSide(
                                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                              ),
                            );
                          }),
                          ActionChip(
                            label: const Text('Max Balance', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent)),
                            onPressed: () {
                              setState(() {
                                _amountController.text = walletVm.availableBalance.toStringAsFixed(2);
                              });
                            },
                            backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                            side: BorderSide(
                              color: AppColors.accent.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Remarks
                      AppTextField(
                        controller: _remarksController,
                        label: 'Remarks (Optional)',
                        hint: 'e.g. Dinner share, Rent, Groceries',
                        prefixIcon: const Icon(Icons.notes_rounded),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Guarantee Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, size: 18, color: AppColors.accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Zero transfer fee  •  Authoritative balance verified  •  Instant 24x7',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : const Color(0xFF1E40AF),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Continue Button
                ElevatedButton(
                  onPressed: _reviewTransfer,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Review & Transfer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickBeneficiaryChip extends StatelessWidget {
  final String name;
  final String phone;
  final VoidCallback onTap;

  const _QuickBeneficiaryChip({
    required this.name,
    required this.phone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ActionChip(
      avatar: CircleAvatar(
        radius: 12,
        backgroundColor: AppColors.accent,
        child: Text(
          name.isNotEmpty ? name[0] : 'U',
          style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      label: Text(name),
      onPressed: onTap,
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
      side: BorderSide(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
      ),
    );
  }
}
