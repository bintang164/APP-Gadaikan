import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_text_field.dart';
import '../../../app/widgets/password_field.dart';
import '../../../app/widgets/primary_button.dart';
import '../../../core/providers/session_providers.dart';
import '../../../core/utils/validators.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _acceptedTerms = false;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_acceptedTerms) {
      setState(() {
        _errorText = 'Setujui syarat layanan dan kebijakan privasi terlebih dahulu.';
      });
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await ref.read(sessionControllerProvider).registerDemo(
            name: _nameController.text,
            phone: _phoneController.text,
          );
      if (!mounted) return;
      context.go(AppRoutes.home);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Gagal membuat akun demo. Silakan coba lagi.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showTerms() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Syarat & kebijakan'),
          content: const SingleChildScrollView(
            child: Text(
              'Gadaikan adalah prototipe akademik. Data yang dimasukkan pada '
              'mode demo hanya disimpan di perangkat dan tidak dikirim ke '
              'lembaga gadai, payment gateway, atau layanan resmi mana pun.\n\n'
              'Jangan menggunakan data identitas asli untuk demo.',
            ),
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
      key: const Key('register_screen'),
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Daftar akun')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.horizontal,
            AppSpacing.lg,
            AppSpacing.horizontal,
            AppSpacing.xl + bottomInset,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Buat akun Gadaikan',
                      style: AppTextStyles.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Isi data berikut untuk mencoba alur pengajuan gadai.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      controller: _nameController,
                      label: 'Nama lengkap',
                      hint: 'Contoh: Siti Rahma',
                      prefixIcon: Icons.badge_outlined,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      autofillHints: const [AutofillHints.name],
                      validator: Validators.name,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _phoneController,
                      label: 'Nomor HP',
                      hint: 'Contoh: 081234567890',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      validator: Validators.phone,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _emailController,
                      label: 'Email (opsional)',
                      hint: 'nama@email.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        return Validators.email(value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PasswordField(
                      controller: _passwordController,
                      label: 'Kata sandi',
                      hint: 'Minimal 8 karakter',
                      validator: Validators.password,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    PasswordField(
                      controller: _confirmController,
                      label: 'Konfirmasi kata sandi',
                      hint: 'Ulangi kata sandi',
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: (value) => Validators.confirmPassword(
                        value,
                        _passwordController.text,
                      ),
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _acceptedTerms,
                            onChanged: _isLoading
                                ? null
                                : (value) => setState(
                                      () => _acceptedTerms = value ?? false,
                                    ),
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text.rich(
                                TextSpan(
                                  style: AppTextStyles.bodySmall,
                                  children: [
                                    const TextSpan(text: 'Saya menyetujui '),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.baseline,
                                      baseline: TextBaseline.alphabetic,
                                      child: GestureDetector(
                                        onTap: _showTerms,
                                        child: Text(
                                          'syarat layanan dan kebijakan privasi',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const TextSpan(text: ' Gadaikan.'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_errorText != null) ...[
                      const SizedBox(height: AppSpacing.sm),
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
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    PrimaryButton(
                      label: 'Buat Akun',
                      onPressed: _isLoading ? null : _submit,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => context.go(AppRoutes.login),
                      child: const Text('Sudah punya akun? Masuk'),
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
                              'Mode demo: akun ini hanya tersimpan di perangkat '
                              'dan belum terhubung ke backend Laravel.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.info,
                              ),
                            ),
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
      ),
    );
  }
}
