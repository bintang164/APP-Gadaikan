import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_logo.dart';
import '../../../app/widgets/app_text_field.dart';
import '../../../app/widgets/password_field.dart';
import '../../../app/widgets/primary_button.dart';
import '../../../app/widgets/secondary_button.dart';
import '../../../core/providers/session_providers.dart';
import '../../../core/utils/validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await ref.read(sessionControllerProvider).loginDemo(
            identifier: _identifierController.text,
          );
      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Gagal masuk. Silakan coba lagi.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showForgotPassword() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Lupa kata sandi?'),
          content: const Text(
            'Pemulihan kata sandi akan tersedia setelah backend Gadaikan '
            'terhubung. Untuk prototipe ini, gunakan kata sandi apa pun '
            'minimal 8 karakter.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Mengerti'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      key: const Key('login_screen'),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.horizontal,
              AppSpacing.xl,
              AppSpacing.horizontal,
              AppSpacing.xl + bottomInset,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: AppLogo(
                        fontSize: 30,
                        showTagline: true,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Selamat datang kembali',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Masuk untuk melanjutkan pengajuan gadai.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      controller: _identifierController,
                      label: 'Nomor HP atau email',
                      hint: 'Contoh: 081234567890',
                      prefixIcon: Icons.person_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      validator: Validators.emailOrPhone,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PasswordField(
                      controller: _passwordController,
                      label: 'Kata sandi',
                      hint: 'Minimal 8 karakter',
                      validator: Validators.password,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : _showForgotPassword,
                        child: const Text('Lupa kata sandi?'),
                      ),
                    ),
                    if (_errorText != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.dangerSoft,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 18,
                              color: AppColors.danger,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                _errorText!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.danger,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    PrimaryButton(
                      label: 'Masuk',
                      onPressed: _isLoading ? null : _submit,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.infoSoft,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: AppColors.info,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              'Mode demo: autentikasi backend belum aktif. '
                              'Data yang dimasukkan hanya disimpan di perangkat.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.info,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: const [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: Text('atau'),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SecondaryButton(
                      label: 'Daftar akun',
                      onPressed: _isLoading
                          ? null
                          : () => context.go(AppRoutes.register),
                      isFullWidth: true,
                      icon: Icons.person_add_alt_1_outlined,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Dengan masuk, kamu menyetujui syarat layanan dan '
                      'kebijakan privasi Gadaikan.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption,
                    ),
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
