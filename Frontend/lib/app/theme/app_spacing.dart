/// Skala spacing 8pt dan ukuran komponen Gadaikan.
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;

  /// Padding horizontal standar layar (DESIGN 2.3).
  static const double horizontal = 20.0;

  /// Jarak vertikal standar antar komponen.
  static const double vertical = 8.0;

  // Alias lama agar kode existing tetap kompatibel.
  static const double small = xxs;
  static const double medium = sm;
  static const double large = xl;
}

/// Radius sudut komponen.
class AppRadius {
  const AppRadius._();

  static const double xs = 8.0;
  static const double sm = 10.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double pill = 999.0;
}

/// Elevation/shadow tipis. Hindari bayangan berat.
class AppElevation {
  const AppElevation._();

  static const double none = 0.0;
  static const double low = 1.0;
  static const double medium = 2.0;
  static const double high = 4.0;
}

/// Ukuran komponen yang dipakai lintas layar.
class AppSizes {
  const AppSizes._();

  static const double buttonHeight = 50.0;
  static const double inputHeight = 52.0;
  static const double bottomNavHeight = 72.0;
  static const double appBarHeight = 56.0;

  static const double iconXs = 16.0;
  static const double iconSm = 18.0;
  static const double iconMd = 22.0;
  static const double iconLg = 28.0;
  static const double iconXl = 36.0;

  static const double avatarSm = 36.0;
  static const double avatarMd = 44.0;
  static const double avatarLg = 64.0;

  static const double contentMaxWidth = 560.0;
}

/// Durasi animasi singkat yang konsisten.
class AppDurations {
  const AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration splashMinimum = Duration(milliseconds: 1300);
}
