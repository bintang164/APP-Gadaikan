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

  /// Menyembunyikan sebagian nomor polisi di tampilan umum/log.
  static String maskPlate(String value) {
    final String trimmed = value.trim().toUpperCase();
    if (trimmed.length <= 5) return trimmed;
    final RegExpMatch? match =
        RegExp(r'^([A-Z]{1,2}\s*)(\d{2,4})(.*)$').firstMatch(trimmed);
    if (match == null) {
      return '${trimmed.substring(0, 3)}••••';
    }
    return '${match.group(1) ?? ''}••••${match.group(3) ?? ''}';
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

  /// Angka desimal positif dalam batas wajar, misalnya berat emas.
  static String? positiveDecimal(
    String? value, {
    String label = 'Nilai',
    required double min,
    required double max,
  }) {
    final String? required = requiredField(value, label: label);
    if (required != null) return required;
    final double? parsed = double.tryParse(value!.trim().replaceAll(',', '.'));
    if (parsed == null || parsed.isNaN) {
      return '$label harus berupa angka.';
    }
    if (parsed <= 0) {
      return '$label harus lebih dari 0.';
    }
    if (parsed < min || parsed > max) {
      return '$label harus antara $min dan $max.';
    }
    return null;
  }

  /// Kadar/karat opsional; menerima "22", "22 Karat", atau "99.9%".
  static String? karat(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final RegExp number = RegExp(r'(\d+(?:\.\d+)?)');
    final Match? match = number.firstMatch(value.trim());
    if (match == null) return 'Kadar/karat harus berupa angka.';
    final double? parsed = double.tryParse(match.group(1) ?? '');
    if (parsed == null || parsed <= 0 || parsed > 100) {
      return 'Kadar/karat harus antara 0 dan 100.';
    }
    return null;
  }

  /// Tahun kendaraan 4 digit dalam rentang wajar.
  static String? vehicleYear(String? value) {
    final String? required = requiredField(value, label: 'Tahun kendaraan');
    if (required != null) return required;
    final int now = DateTime.now().year;
    final int? parsed = int.tryParse(value!.trim());
    if (parsed == null || value.trim().length != 4) {
      return 'Tahun kendaraan harus 4 digit (contoh: 2024).';
    }
    if (parsed < 1980 || parsed > now + 1) {
      return 'Tahun kendaraan harus antara 1980 dan ${now + 1}.';
    }
    return null;
  }

  /// Nomor polisi Indonesia, misalnya "B 4123 DEMO".
  static String? plateNumber(String? value) {
    final String? required = requiredField(value, label: 'Nomor polisi');
    if (required != null) return required;
    final String trimmed = value!.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{1,2}\s*\d{2,4}\s*[A-Z]{0,4}$').hasMatch(trimmed)) {
      return 'Format nomor polisi tidak valid (contoh: B 4123 DEMO).';
    }
    return null;
  }
}
