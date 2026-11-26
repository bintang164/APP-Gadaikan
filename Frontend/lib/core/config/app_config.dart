/// Konfigurasi aplikasi dari `--dart-define`.
///
/// Tidak ada URL produksi yang dikarang. Nilai default hanya untuk
/// pengembangan lokal.
///
/// Contoh:
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
class AppConfig {
  const AppConfig._();

  static const String appName = 'Gadaikan';
  static const String tagline = 'Solusi Gadai dalam Genggaman';
  static const String appVersion = '1.0.0';

  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api',
  );

  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => !isProduction;
}
