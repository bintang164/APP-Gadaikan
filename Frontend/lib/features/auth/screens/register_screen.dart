import 'package:flutter/material.dart';
import '../../../core/auth/auth_exception.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_cards.dart';
import '../../../core/widgets/app_text_fields.dart';
import '../../home/screens/main_shell_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const String routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _acceptedTerms = false;
  bool _showTermsError = false;
  bool _isSubmitting = false;
  String? _formError;
  final Map<String, String> _fieldErrors = <String, String>{};

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
    if (_isSubmitting) return; // cegah double submit
    setState(() {
      _formError = null;
      _fieldErrors.clear();
    });
    final formValid = _formKey.currentState!.validate();
    setState(() => _showTermsError = !_acceptedTerms);
    if (!formValid || !_acceptedTerms) return;

    setState(() => _isSubmitting = true);
    try {
      await AppStateScope.of(context).register(
        name: _nameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        MainShellScreen.routeName,
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _formError = e.message;
        _fieldErrors.addAll(e.fieldErrors);
      });
      _formKey.currentState?.validate();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _formError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String? _nameValidator(String? value) {
    final String? serverError = _fieldErrors['name'];
    if (serverError != null) return serverError;
    return AppValidators.requiredField(value, label: 'Nama lengkap');
  }

  String? _phoneValidator(String? value) {
    final String? serverError = _fieldErrors['phone'];
    if (serverError != null) return serverError;
    return AppValidators.phone(value);
  }

  String? _emailValidator(String? value) {
    final String? serverError = _fieldErrors['email'];
    if (serverError != null) return serverError;
    return AppValidators.email(value, required: false);
  }

  String? _passwordValidator(String? value) {
    final String? serverError = _fieldErrors['password'];
    if (serverError != null) return serverError;
    return AppValidators.password(value);
  }

  String? _confirmValidator(String? value) {
    final String? serverError = _fieldErrors['password_confirmation'];
    if (serverError != null) return serverError;
    if (value == null || value.isEmpty) {
      return 'Konfirmasi kata sandi wajib diisi';
    }
    if (value != _passwordController.text) {
      return 'Kata sandi tidak cocok';
    }
    return null;
  }

  void _clearFieldErrors() {
    if (_fieldErrors.isNotEmpty) {
      setState(() => _fieldErrors.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.md,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Buat akun Gadaikan',
                  style: AppTextStyles.pageHeading,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Lengkapi data diri berikut untuk mulai mengajukan gadai digital.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_formError != null)
                  AppCard(
                    backgroundColor: AppColors.dangerSoft,
                    borderColor: AppColors.danger.withValues(alpha: 0.35),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _formError!,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_formError != null) const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Nama Lengkap',
                  controller: _nameController,
                  hint: 'Masukkan nama sesuai identitas',
                  prefixIcon: Icons.badge_outlined,
                  textInputAction: TextInputAction.next,
                  validator: _nameValidator,
                  onChanged: (_) => _clearFieldErrors(),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Nomor HP',
                  controller: _phoneController,
                  hint: 'Contoh: 081234567890',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: _phoneValidator,
                  onChanged: (_) => _clearFieldErrors(),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Email (Opsional)',
                  controller: _emailController,
                  hint: 'contoh@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _emailValidator,
                  onChanged: (_) => _clearFieldErrors(),
                ),
                const SizedBox(height: AppSpacing.md),
                PasswordField(
                  label: 'Kata Sandi',
                  controller: _passwordController,
                  hint: 'Minimal 8 karakter',
                  textInputAction: TextInputAction.next,
                  validator: _passwordValidator,
                  onChanged: (_) => _clearFieldErrors(),
                ),
                const SizedBox(height: AppSpacing.md),
                PasswordField(
                  label: 'Konfirmasi Kata Sandi',
                  controller: _confirmController,
                  hint: 'Ulangi kata sandi',
                  textInputAction: TextInputAction.done,
                  validator: _confirmValidator,
                  onChanged: (_) => _clearFieldErrors(),
                ),
                const SizedBox(height: AppSpacing.md),
                CheckboxListTile(
                  value: _acceptedTerms,
                  onChanged: (val) {
                    setState(() {
                      _acceptedTerms = val ?? false;
                      if (_acceptedTerms) _showTermsError = false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: AppColors.primary,
                  title: const Text(
                    'Saya menyetujui Syarat Layanan dan Kebijakan Privasi Gadaikan (Mode Demo).',
                    style: AppTextStyles.caption,
                  ),
                ),
                if (_showTermsError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 8),
                    child: Text(
                      'Anda wajib menyetujui syarat dan kebijakan privasi.',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Buat Akun',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
