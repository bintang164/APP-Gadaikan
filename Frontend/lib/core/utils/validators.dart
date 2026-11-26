/// Validasi form yang dipakai lintas layar.
class Validators {
  const Validators._();

  static final RegExp _emailPattern = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );
  static final RegExp _phonePattern = RegExp(r'^\+?[0-9]{9,15}$');

  static String? requiredField(String? value, {String label = 'Kolom'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label wajib diisi.';
    }
    return null;
  }

  static String? name(String? value) {
    final String? required = requiredField(value, label: 'Nama lengkap');
    if (required != null) return required;
    if (value!.trim().length < 3) {
      return 'Nama minimal 3 karakter.';
    }
    return null;
  }

  static String? email(String? value) {
    final String? required = requiredField(value, label: 'Email');
    if (required != null) return required;
    if (!_emailPattern.hasMatch(value!.trim())) {
      return 'Format email belum benar.';
    }
    return null;
  }

  static String? phone(String? value) {
    final String? required = requiredField(value, label: 'Nomor HP');
    if (required != null) return required;
    final String normalized = value!.trim().replaceAll(RegExp(r'[\s-]'), '');
    if (!_phonePattern.hasMatch(normalized)) {
      return 'Nomor HP harus 9–15 digit.';
    }
    return null;
  }

  static String? password(String? value) {
    final String? required = requiredField(value, label: 'Kata sandi');
    if (required != null) return required;
    if (value!.length < 8) {
      return 'Kata sandi minimal 8 karakter.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final String? required = requiredField(value, label: 'Konfirmasi kata sandi');
    if (required != null) return required;
    if (value != password) {
      return 'Konfirmasi kata sandi tidak sama.';
    }
    return null;
  }

  /// Login menerima nomor HP atau email.
  static String? emailOrPhone(String? value) {
    final String? required = requiredField(value, label: 'Nomor HP/email');
    if (required != null) return required;
    final String trimmed = value!.trim();
    if (trimmed.contains('@')) {
      return _emailPattern.hasMatch(trimmed)
          ? null
          : 'Format email belum benar.';
    }
    final String normalized = trimmed.replaceAll(RegExp(r'[\s-]'), '');
    return _phonePattern.hasMatch(normalized)
        ? null
        : 'Masukkan nomor HP atau email yang valid.';
  }
}
