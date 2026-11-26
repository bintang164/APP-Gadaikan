import 'dart:convert';

import '../models/auth_user.dart';
import '../storage/local_storage.dart';
import 'auth_exception.dart';
import 'auth_service.dart';

/// Autentikasi mode demo yang berjalan sepenuhnya di perangkat.
///
/// Aturan penting:
/// - **Kata sandi tidak pernah disimpan.** Mode demo hanya memeriksa
///   panjang minimal, bukan mencocokkan kata sandi.
/// - Akun demo disimpan sebagai nama, nomor HP, dan email saja.
/// - Setiap data yang dihasilkan wajib ditandai "Mode demo" di UI.
class MockAuthService implements AuthService {
  final LocalStorage localStorage;
  final Duration delay;

  MockAuthService({
    required this.localStorage,
    this.delay = const Duration(milliseconds: 650),
  });

  /// Akun demo awal agar alur login bisa dicoba tanpa registrasi.
  static const List<AuthUser> _seedAccounts = <AuthUser>[
    AuthUser(
      id: 'demo-1',
      name: 'Pengguna Gadaikan',
      phone: '081234567890',
      email: 'demo@gadaikan.test',
      isDemo: true,
    ),
  ];

  @override
  bool get isMock => true;

  @override
  Future<AuthSession> login({
    required String identifier,
    required String password,
  }) async {
    await _simulateLatency();

    if (password.trim().length < 8) {
      throw const AuthException(
        AuthFailureType.validation,
        'Kata sandi minimal 8 karakter.',
        fieldErrors: <String, String>{
          'password': 'Kata sandi minimal 8 karakter.',
        },
      );
    }

    final List<AuthUser> accounts = await _loadAccounts();
    final String normalized = _normalizeIdentifier(identifier);
    AuthUser? match;
    for (final AuthUser account in accounts) {
      if (_matches(account, normalized)) {
        match = account;
        break;
      }
    }

    if (match == null) {
      throw const AuthException(
        AuthFailureType.unauthorized,
        'Akun demo tidak ditemukan. Daftar dulu atau gunakan akun demo '
        '081234567890.',
        fieldErrors: <String, String>{
          'identifier': 'Akun demo tidak ditemukan.',
        },
      );
    }

    return AuthSession(
      token: 'demo-${match.id}-${DateTime.now().microsecondsSinceEpoch}',
      user: match.copyWith(isDemo: true),
    );
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String phone,
    String? email,
    required String password,
  }) async {
    await _simulateLatency();

    final String cleanName = name.trim();
    final String cleanPhone = phone.trim();
    final String? cleanEmail =
        (email == null || email.trim().isEmpty) ? null : email.trim();

    final List<AuthUser> accounts = await _loadAccounts();
    final Map<String, String> fieldErrors = <String, String>{};

    if (accounts.any(
      (AuthUser account) =>
          _normalizeIdentifier(account.phone) == _normalizeIdentifier(cleanPhone),
    )) {
      fieldErrors['phone'] = 'Nomor HP sudah terdaftar pada data demo.';
    }
    if (cleanEmail != null &&
        accounts.any(
          (AuthUser account) =>
              (account.email ?? '').toLowerCase() == cleanEmail.toLowerCase(),
        )) {
      fieldErrors['email'] = 'Email sudah terdaftar pada data demo.';
    }
    if (fieldErrors.isNotEmpty) {
      throw AuthException(
        AuthFailureType.validation,
        'Data pendaftaran belum bisa digunakan.',
        fieldErrors: fieldErrors,
      );
    }

    final AuthUser user = AuthUser(
      id: 'demo-${DateTime.now().microsecondsSinceEpoch}',
      name: cleanName,
      phone: cleanPhone,
      email: cleanEmail,
      isDemo: true,
    );

    accounts.add(user);
    await _saveAccounts(accounts);

    return AuthSession(
      token: 'demo-${user.id}-${DateTime.now().microsecondsSinceEpoch}',
      user: user,
    );
  }

  @override
  Future<void> logout({required String token}) async {
    await _simulateLatency();
    // Tidak ada sesi server yang perlu dihapus pada mode demo.
  }

  @override
  Future<AuthUser> me({required String token}) async {
    await _simulateLatency();
    final List<AuthUser> accounts = await _loadAccounts();
    for (final AuthUser account in accounts) {
      if (token.contains(account.id)) {
        return account.copyWith(isDemo: true);
      }
    }
    throw const AuthException(
      AuthFailureType.unauthorized,
      'Sesi demo tidak dikenali. Silakan masuk kembali.',
    );
  }

  Future<List<AuthUser>> _loadAccounts() async {
    final String? raw = await localStorage.getDemoAccountsJson();
    if (raw == null || raw.isEmpty) {
      await _saveAccounts(_seedAccounts);
      return List<AuthUser>.of(_seedAccounts);
    }

    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is List) {
        final List<AuthUser> accounts = decoded
            .whereType<Map<dynamic, dynamic>>()
            .map(
              (Map<dynamic, dynamic> item) =>
                  AuthUser.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
        if (accounts.isNotEmpty) return accounts;
      }
    } catch (_) {
      // Data rusak: kembalikan akun seed agar pengguna tidak terkunci.
    }

    await _saveAccounts(_seedAccounts);
    return List<AuthUser>.of(_seedAccounts);
  }

  Future<void> _saveAccounts(List<AuthUser> accounts) async {
    final String raw = jsonEncode(
      accounts.map((AuthUser user) => user.toJson()).toList(),
    );
    await localStorage.setDemoAccountsJson(raw);
  }

  String _normalizeIdentifier(String value) {
    final String trimmed = value.trim().toLowerCase();
    if (trimmed.contains('@')) return trimmed;
    return trimmed.replaceAll(RegExp(r'[\s\-+]'), '');
  }

  bool _matches(AuthUser account, String normalizedIdentifier) {
    final String phone = _normalizeIdentifier(account.phone);
    final String email = (account.email ?? '').toLowerCase();
    return normalizedIdentifier == phone ||
        (email.isNotEmpty && normalizedIdentifier == email);
  }

  Future<void> _simulateLatency() async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
  }
}
