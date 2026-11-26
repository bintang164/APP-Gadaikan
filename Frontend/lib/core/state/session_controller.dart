import 'package:flutter/foundation.dart';

import '../auth/auth_repository.dart';
import '../config/app_config.dart';
import '../models/auth_user.dart';
import '../storage/local_storage.dart';

/// Status sesi aplikasi (Riverpod `ChangeNotifier`).
///
/// Persistensi mekanisme token: token disimpan aman di `SessionStore`,
/// profil non-sensitif di `LocalStorage`. Kata sandi tidak disimpan.
class SessionController extends ChangeNotifier {
  final LocalStorage localStorage;
  final AuthRepository authRepository;

  bool _initialized = false;
  bool _onboardingCompleted = false;
  bool _isBusy = false;
  AuthUser? _user;

  SessionController({
    required this.localStorage,
    required this.authRepository,
  });

  bool get initialized => _initialized;
  bool get onboardingCompleted => _onboardingCompleted;
  bool get isBusy => _isBusy;
  bool get isAuthenticated => _user != null;
  AuthUser? get user => _user;

  /// Nama pengguna dari profil/API; fallback aman bila kosong.
  String get displayName => _user?.safeName ?? 'Pengguna Gadaikan';
  String? get userName => _user?.name;
  String? get userPhone => _user?.phone;
  String? get userEmail => _user?.email;
  String get userInitials => _user?.initials ?? 'G';

  /// True jika sesi berasal dari mode demo lokal, bukan backend Laravel.
  bool get isDemoMode => _user?.isDemo ?? AppConfig.useMockAuth;

  /// Membaca flag onboarding dan memulihkan sesi token.
  ///
  /// Error storage tidak boleh membuat aplikasi crash; fallback ke
  /// kondisi belum login.
  Future<void> bootstrap() async {
    if (_initialized) return;

    try {
      _onboardingCompleted = await localStorage.isOnboardingCompleted();
      _user = await authRepository.restoreSession();
    } catch (error, stackTrace) {
      debugPrint('Session bootstrap gagal: $error');
      debugPrintStack(stackTrace: stackTrace);
      _user = null;
      _onboardingCompleted = false;
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding() async {
    if (_onboardingCompleted) return;
    _onboardingCompleted = true;
    notifyListeners();
    await localStorage.setOnboardingCompleted(true);
  }

  /// Login dengan mencegah double submit via [isBusy].
  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      _user = await authRepository.login(
        identifier: identifier,
        password: password,
      );
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  /// Login demo untuk mode offline/Tahap 2. Melabeli hasil sebagai
  /// mode demo di UI.
  Future<void> loginDemo({
    required String identifier,
    String? name,
  }) async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      final String trimmed = identifier.trim();
      final String resolvedName = (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : _nameFromIdentifier(trimmed);

      final AuthUser loggedIn = await authRepository.login(
        identifier: trimmed,
        password: 'demo123', // password dummy di mode demo
      );
      _user = loggedIn.copyWith(isDemo: true, name: resolvedName);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  /// Registrasi demo untuk mode offline/Tahap 2.
  Future<void> registerDemo({
    required String name,
    required String phone,
  }) async {
    if (_isBusy) return;
    _isBusy = true;
    notifyListeners();
    try {
      final AuthUser registered = await authRepository.register(
        name: name.trim(),
        phone: phone.trim(),
        email: null,
        password: 'demo123', // password dummy di mode demo
      );
      _user = registered.copyWith(isDemo: true);
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isBusy = true;
    notifyListeners();
    try {
      await authRepository.logout();
    } finally {
      _user = null;
      _isBusy = false;
      notifyListeners();
    }
  }

  String _nameFromIdentifier(String identifier) {
    if (identifier.contains('@')) {
      final String localPart = identifier.split('@').first;
      if (localPart.isNotEmpty) {
        return '${localPart[0].toUpperCase()}${localPart.substring(1)}';
      }
    }
    return 'Pengguna Gadaikan';
  }
}