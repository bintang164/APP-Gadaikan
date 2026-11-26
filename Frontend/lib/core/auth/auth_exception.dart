/// Jenis kegagalan autentikasi yang perlu ditampilkan berbeda di UI.
enum AuthFailureType {
  /// 401: kredensial salah atau sesi kedaluwarsa.
  unauthorized,

  /// 422: validasi dari server. Pesan dipetakan ke field terkait.
  validation,

  /// Koneksi melebihi batas waktu.
  timeout,

  /// Tidak dapat terhubung ke server (offline/DNS/ditolak).
  network,

  /// 5xx atau 429.
  server,

  /// Kegagalan lain yang tidak terklasifikasi.
  unknown,
}

/// Error autentikasi yang ramah pengguna.
class AuthException implements Exception {
  final AuthFailureType type;
  final String message;

  /// Error per field, misalnya `{'phone': 'Nomor HP sudah terdaftar.'}`.
  final Map<String, String> fieldErrors;

  const AuthException(
    this.type,
    this.message, {
    this.fieldErrors = const <String, String>{},
  });

  @override
  String toString() => message;
}
