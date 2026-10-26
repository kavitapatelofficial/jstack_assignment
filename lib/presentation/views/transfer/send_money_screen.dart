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
                // Available Balance Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
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
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 18,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Wallet Balance',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        CurrencyFormatter.format(walletVm.availableBalance, currency: walletVm.currency),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.creditGreen,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Quick Contacts / Sample Beneficiaries
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequent Beneficiaries',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _QuickBeneficiaryChip(
                            name: 'Rahul Sharma',
                            phone: '9876543210',
                            onTap: () => _fillSampleBeneficiary('Rahul Sharma', '9876543210'),
                          ),
                          const SizedBox(width: 8),
                          _QuickBeneficiaryChip(
                            name: 'Amit Kumar',
                            phone: '9811223344',
                            onTap: () => _fillSampleBeneficiary('Amit Kumar', '9811223344'),
                          ),
                          const SizedBox(width: 8),
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

                const SizedBox(height: 24),

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

                const SizedBox(height: 18),

                // Remarks
                AppTextField(
                  controller: _remarksController,
                  label: 'Remarks (Optional)',
                  hint: 'e.g. Payment for dinner, Rent, etc.',
                  prefixIcon: const Icon(Icons.notes_rounded),
                ),

                const SizedBox(height: 32),

                // Continue Button
                ElevatedButton(
                  onPressed: _reviewTransfer,
                  child: const Text('Review & Transfer'),
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
