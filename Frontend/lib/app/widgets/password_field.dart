import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_text_field.dart';

/// Input kata sandi dengan tombol tampilkan/sembunyikan.
class PasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? errorText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final AutovalidateMode autovalidateMode;

  const PasswordField({
    super.key,
    this.controller,
    this.label = 'Kata sandi',
    this.hint,
    this.errorText,
    this.validator,
    this.onChanged,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
    this.enabled = true,
    this.autofillHints,
    this.autovalidateMode = AutovalidateMode.disabled,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  void _toggleVisibility() {
    setState(() => _obscure = !_obscure);
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      label: widget.label,
      hint: widget.hint,
      errorText: widget.errorText,
      validator: widget.validator,
      onChanged: widget.onChanged,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onFieldSubmitted,
      enabled: widget.enabled,
      obscureText: _obscure,
      keyboardType: TextInputType.visiblePassword,
      autofillHints: widget.autofillHints,
      textCapitalization: TextCapitalization.none,
      autovalidateMode: widget.autovalidateMode,
      prefixIcon: Icons.lock_outline_rounded,
      suffixIcon: IconButton(
        onPressed: widget.enabled ? _toggleVisibility : null,
        tooltip: _obscure ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
        icon: Icon(
          _obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: AppSizes.iconMd,
        ),
        padding: const EdgeInsets.all(AppSpacing.sm),
        constraints: const BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
      ),
    );
  }
}
