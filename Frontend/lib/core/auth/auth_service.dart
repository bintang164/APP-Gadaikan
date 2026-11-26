import '../models/auth_user.dart';

/// Hasil autentikasi: token akses + profil pengguna.
class AuthSession {
  final String token;
  final AuthUser user;

  const AuthSession({
    required this.token,
    required this.user,
  });
}

/// Kontrak layanan autentikasi.
///
/// Implementasi produksi memakai Laravel Sanctum ([ApiAuthService]),
/// sedangkan [MockAuthService] dipakai saat backend belum tersedia dan
/// selalu dilabeli sebagai mode demo di UI.
abstract class AuthService {
  /// True jika data tidak dikirim ke backend.
  bool get isMock;

  Future<AuthSession> login({
    required String identifier,
    required String password,
  });

  Future<AuthSession> register({
    required String name,
    required String phone,
    String? email,
    required String password,
  });

  Future<void> logout({required String token});

  Future<AuthUser> me({required String token});
}
