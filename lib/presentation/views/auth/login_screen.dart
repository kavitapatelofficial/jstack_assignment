import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/utils/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'demo@jstack.co');
  final _passwordController = TextEditingController(text: 'Demo@123');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authVm = context.read<AuthViewModel>();
    final success = await authVm.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  void _showServerConfigDialog() {
    final storage = context.read<SecureStorageService>();
    final client = context.read<ApiClient>();
    final currentUrl = client.dio.options.baseUrl;
    final controller = TextEditingController(text: currentUrl);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.network_check_rounded, color: AppColors.accent, size: 22),
              SizedBox(width: 8),
              Text('Server Configuration', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Set the Mock API Backend URL for your device:',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Backend Base URL',
                    hintText: 'http://10.22.134.63:3000',
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Quick Presets:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.wifi, size: 14),
                      label: const Text('Wi-Fi (10.22.134.63)'),
                      onPressed: () {
                        setDialogState(() {
                          controller.text = 'http://10.22.134.63:3000';
                        });
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.usb, size: 14),
                      label: const Text('USB (localhost)'),
                      onPressed: () {
                        setDialogState(() {
                          controller.text = 'http://localhost:3000';
                        });
                      },
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.phone_android, size: 14),
                      label: const Text('Emulator (10.0.2.2)'),
                      onPressed: () {
                        setDialogState(() {
                          controller.text = 'http://10.0.2.2:3000';
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                  ),
                  child: const Text(
                    '• Real Device on Wi-Fi: Connect phone & PC to same Wi-Fi and use http://10.22.134.63:3000\n'
                    '• Real Device over USB: Run `adb reverse tcp:3000 tcp:3000` in terminal and use http://localhost:3000',
                    style: TextStyle(fontSize: 11, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newUrl = controller.text.trim();
                if (newUrl.isNotEmpty) {
                  await storage.saveCustomBaseUrl(newUrl);
                  client.updateBaseUrl(newUrl);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save & Apply'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Server Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showServerConfigDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Branding / Logo
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        gradient: AppColors.walletCardGradient,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title & Tagline
                  Text(
                    'jWallet Lite',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Next-Gen Digital Wallet Platform by jStack',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 36),

                  // Error Banner
                  if (authVm.errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.debitRedBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.debitRed.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: AppColors.debitRed, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  authVm.errorMessage!,
                                  style: const TextStyle(
                                    color: AppColors.debitRed,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (authVm.errorMessage!.contains('connect') ||
                              authVm.errorMessage!.contains('server') ||
                              authVm.errorMessage!.contains('network')) ...[
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.debitRed,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  visualDensity: VisualDensity.compact,
                                ),
                                onPressed: _showServerConfigDialog,
                                icon: const Icon(Icons.settings, size: 14),
                                label: const Text('Configure Server IP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Email Input
                  AppTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'demo@jstack.co',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: Validators.validateEmail,
                    onChanged: (_) => authVm.clearError(),
                  ),
                  const SizedBox(height: 18),

                  // Password Input
                  AppTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: '••••••••',
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: Validators.validatePassword,
                    onChanged: (_) => authVm.clearError(),
                    onFieldSubmitted: (_) => _handleLogin(),
                  ),

                  const SizedBox(height: 28),

                  // Login Button
                  ElevatedButton(
                    onPressed: authVm.isLoading ? null : _handleLogin,
                    child: authVm.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                  ),

                  const SizedBox(height: 20),

                  // Quick Demo Credentials Chip (for evaluators)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Demo Credentials',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            InkWell(
                              onTap: () {
                                _emailController.text = 'demo@jstack.co';
                                _passwordController.text = 'Demo@123';
                              },
                              child: const Text(
                                'Fill Form',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Email: demo@jstack.co  •  Password: Demo@123',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
