import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Kontrak penyimpanan sesi agar mudah diganti/diuji.
abstract class SessionStore {
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<void> clear();
}

/// Implementasi produksi memakai secure storage.
class SecureSessionStore implements SessionStore {
  static const String _tokenKey = 'auth_token';

  final FlutterSecureStorage _storage;

  SecureSessionStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> writeToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  @override
  Future<void> clear() => _storage.delete(key: _tokenKey);
}

/// Implementasi in-memory untuk unit/widget test.
class InMemorySessionStore implements SessionStore {
  String? _token;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> writeToken(String token) async => _token = token;

  @override
  Future<void> clear() async => _token = null;
}
