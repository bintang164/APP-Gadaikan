import '../models/auth_user.dart';
import '../storage/local_storage.dart';
import '../storage/session_store.dart';
import 'auth_exception.dart';
import 'auth_service.dart';

/// Menyatukan [AuthService] dengan penyimpanan token & profil.
///
/// - Token disimpan di [SessionStore] (secure storage pada perangkat).
/// - Profil pengguna di-cache di [LocalStorage] (non-sensitif) agar
///   sapaan & nama tetap tampil saat offline.
/// - Kata sandi tidak pernah disimpan atau dicatat.
class AuthRepository {
  final AuthService service;
  final SessionStore sessionStore;
  final LocalStorage localStorage;

  AuthRepository({
    required this.service,
    required this.sessionStore,
    required this.localStorage,
  });

  bool get isMock => service.isMock;

  /// Memulihkan sesi dari penyimpanan.
  ///
  /// - Tidak ada token -> `null`.
  /// - Mode API: validasi ke `/me`. 401 -> bersihkan sesi. Error
  ///   timeout/koneksi -> pakai profil cache agar pengguna tidak
  ///   terkunci saat offline.
  Future<AuthUser?> restoreSession() async {
    final String? token = await sessionStore.readToken();
    if (token == null || token.isEmpty) return null;

    final AuthUser? cached = await localStorage.getCachedUser();

    if (!service.isMock) {
      try {
        final AuthUser user = await service.me(token: token);
        await _cache(user);
        return user;
      } on AuthException catch (error) {
        if (error.type == AuthFailureType.unauthorized) {
          await clearSession();
          return null;
        }
      } catch (_) {
        // fall-through: gunakan cache
      }
    }

    if (cached != null) return cached;

    // Kompatibilitas sesi demo Tahap 2 (nama/nomor HP lama).
    final String? legacyName = await localStorage.getUserName();
    final String? legacyPhone = await localStorage.getUserPhone();
    if (legacyName != null || legacyPhone != null) {
      return AuthUser(
        id: 'legacy-demo',
        name: legacyName ?? '',
        phone: legacyPhone ?? '',
        isDemo: service.isMock,
      );
    }

    return null;
  }

  Future<AuthUser> login({
    required String identifier,
    required String password,
  }) async {
    final AuthSession session = await service.login(
      identifier: identifier,
      password: password,
    );
    await sessionStore.writeToken(session.token);
    await _cache(session.user);
    return session.user;
  }

  Future<AuthUser> register({
    required String name,
    required String phone,
    String? email,
    required String password,
  }) async {
    final AuthSession session = await service.register(
      name: name,
      phone: phone,
      email: email,
      password: password,
    );
    await sessionStore.writeToken(session.token);
    await _cache(session.user);
    return session.user;
  }

  /// Logout lokal selalu dijalankan, meskipun panggilan API gagal.
  Future<void> logout() async {
    final String? token = await sessionStore.readToken();
    if (token != null && token.isNotEmpty) {
      try {
        await service.logout(token: token);
      } catch (_) {
        // Sesi lokal tetap dibersihkan.
      }
    }
    await clearSession();
  }

  Future<void> clearSession() async {
    await sessionStore.clear();
    await localStorage.clearCachedUser();
    await localStorage.clearUserProfile();
  }

  Future<void> _cache(AuthUser user) async {
    await localStorage.setCachedUser(user);
    await localStorage.setUserName(user.name);
    await localStorage.setUserPhone(user.phone);
  }
}
