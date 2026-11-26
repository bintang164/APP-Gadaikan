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
import '../../../core/widgets/gadaikan_logo.dart';
import '../../home/screens/main_shell_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _formError;
  final Map<String, String> _fieldErrors = <String, String>{};

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return; // cegah double submit
    setState(() {
      _formError = null;
      _fieldErrors.clear();
    });
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    try {
      await AppStateScope.of(context).login(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(MainShellScreen.routeName);
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

  String? _identifierValidator(String? value) {
    final String? serverError = _fieldErrors['identifier'] ??
        _fieldErrors['email'] ??
        _fieldErrors['login'];
    if (serverError != null) return serverError;
    return AppValidators.phoneOrEmail(value);
  }

  String? _passwordValidator(String? value) {
    final String? serverError = _fieldErrors['password'];
    if (serverError != null) return serverError;
    return AppValidators.password(value);
  }

  void _fillDemoCredentials() {
    _identifierController.text = '081234567890';
    _passwordController.text = 'demo1234';
    setState(() => _formError = null);
  }

  void _showForgotPasswordDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Lupa kata sandi'),
        content: const SingleChildScrollView(
          child: Text(
            'Pemulihan kata sandi belum tersedia karena backend Laravel '
            'belum terhubung. Aplikasi tidak mengirim email/SMS apa pun.\n\n'
            'Pada mode demo, gunakan akun demo 081234567890 dengan kata '
            'sandi minimal 8 karakter, atau daftar akun demo baru.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.lg,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const GadaikanLogo(size: 46),
                const SizedBox(height: AppSpacing.xl),
                const Text(
                  'Selamat datang kembali',
                  style: AppTextStyles.pageHeading,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Masuk untuk mengelola pengajuan dan memantau transaksi gadai Anda.',
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_formError != null) ...[
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
                  const SizedBox(height: AppSpacing.md),
                ],
                AppTextField(
                  label: 'Nomor HP atau Email',
                  controller: _identifierController,
                  hint: 'Contoh: 081234567890 atau budi@email.com',
                  prefixIcon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _identifierValidator,
                  onChanged: (_) {
                    if (_fieldErrors.isNotEmpty) {
                      setState(() => _fieldErrors.clear());
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                PasswordField(
                  label: 'Kata Sandi',
                  controller: _passwordController,
                  validator: _passwordValidator,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) {
                    if (_fieldErrors.isNotEmpty) {
                      setState(() => _fieldErrors.clear());
                    }
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: Text(
                      'Lupa kata sandi?',
                      style: AppTextStyles.captionBold.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                PrimaryButton(
                  label: 'Masuk',
                  isLoading: _isSubmitting,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  backgroundColor: AppColors.primarySoft,
                  borderColor: AppColors.primary.withValues(alpha: 0.2),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Mode Demo: gunakan akun simulasi untuk mencoba seluruh alur.',
                          style: AppTextStyles.caption,
                        ),
                      ),
                      TextButton(
                        onPressed: _fillDemoCredentials,
                        child: const Text('Isi Demo'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Belum punya akun? ',
                      style: AppTextStyles.bodySecondary,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          RegisterScreen.routeName,
                        );
                      },
                      child: Text(
                        'Daftar Akun',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
