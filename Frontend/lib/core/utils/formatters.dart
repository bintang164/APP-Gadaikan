/// Indonesian currency, date, and form validation helpers.
class AppFormatters {
  AppFormatters._();

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Formats an integer or double into Indonesian Rupiah, e.g. `Rp 2.500.000`.
  static String formatRupiah(num amount) {
    final rounded = amount.round();
    final isNegative = rounded < 0;
    final digits = rounded.abs().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final fromRight = digits.length - i;
      buffer.write(digits[i]);
      if (fromRight > 1 && fromRight % 3 == 1) {
        buffer.write('.');
      }
    }
    return '${isNegative ? '-' : ''}Rp ${buffer.toString()}';
  }

  /// Formats a [DateTime] as `26 Nov 2026`.
  static String formatDate(DateTime date) {
    final month = _months[date.month - 1];
    return '${date.day} $month ${date.year}';
  }

  /// Formats a [DateTime] as `26 Nov 2026, 14:30`.
  static String formatDateTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${formatDate(date)}, $hour:$minute';
  }

  /// Parses digits-only numeric input safely.
  static double? parseCurrency(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }
}

class AppValidators {
  AppValidators._();

  static String? requiredField(String? value, {String label = 'Kolom ini'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label wajib diisi';
    }
    return null;
  }

  static String? phoneOrEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor HP atau email wajib diisi';
    }
    final trimmed = value.trim();
    if (trimmed.contains('@')) {
      return email(trimmed);
    }
    return phone(trimmed);
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor HP wajib diisi';
    }
    final digits = value.replaceAll(RegExp(r'[\s\-\+]'), '');
    if (!RegExp(r'^08[0-9]{8,12}$').hasMatch(digits) &&
        !RegExp(r'^628[0-9]{8,12}$').hasMatch(digits)) {
      return 'Masukkan nomor HP Indonesia yang valid (contoh: 081234567890)';
    }
    return null;
  }

  static String? email(String? value, {bool required = true}) {
    if (value == null || value.trim().isEmpty) {
      return required ? 'Email wajib diisi' : null;
    }
    final emailRegex = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kata sandi wajib diisi';
    }
    if (value.length < 8) {
      return 'Kata sandi minimal 8 karakter';
    }
    return null;
  }
}
