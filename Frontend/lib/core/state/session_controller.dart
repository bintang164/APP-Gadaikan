import 'package:flutter/foundation.dart';

import '../storage/local_storage.dart';
import '../storage/session_store.dart';

/// Status sesi aplikasi.
///
/// Tahap 2 memakai sesi demo lokal yang jelas dilabeli di UI. Tahap
/// berikutnya akan mengganti [loginDemo] dengan autentikasi Laravel
/// Sanctum tanpa mengubah kontrak layar.
class SessionController extends ChangeNotifier {
  final LocalStorage localStorage;
  final SessionStore sessionStore;

  bool _initialized = false;
  bool _isAuthenticated = false;
  bool _onboardingCompleted = false;
  bool _isBusy = false;
  String? _userName;
  String? _userPhone;

  SessionController({
    required this.localStorage,
    required this.sessionStore,
  });

  bool get initialized => _initialized;
  bool get isAuthenticated => _isAuthenticated;
  bool get onboardingCompleted => _onboardingCompleted;
  bool get isBusy => _isBusy;
  String? get userName => _userName;
  String? get userPhone => _userPhone;

  String get displayName {
    final String? name = _userName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Pengguna Gadaikan';
  }

  /// Membaca flag onboarding dan token sesi.
  ///
  /// Error storage tidak boleh membuat aplikasi crash; fallback ke
  /// kondisi belum login.
  Future<void> bootstrap() async {
    if (_initialized) return;

    try {
      _onboardingCompleted = await localStorage.isOnboardingCompleted();
      final String? token = await sessionStore.readToken();
      _isAuthenticated = token != null && token.isNotEmpty;
      _userName = await localStorage.getUserName();
      _userPhone = await localStorage.getUserPhone();
    } catch (error, stackTrace) {
      debugPrint('Session bootstrap gagal: $error');
      debugPrintStack(stackTrace: stackTrace);
      _isAuthenticated = false;
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

  Future<void> loginDemo({
    required String identifier,
    String? name,
  }) async {
    _isBusy = true;
    notifyListeners();
    try {
      final String trimmed = identifier.trim();
      final String resolvedName = (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : _nameFromIdentifier(trimmed);

      await sessionStore.writeToken(
        'demo-${DateTime.now().microsecondsSinceEpoch}',
      );
      await localStorage.setUserName(resolvedName);
      await localStorage.setUserPhone(trimmed);

      _userName = resolvedName;
      _userPhone = trimmed;
      _isAuthenticated = true;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> registerDemo({
    required String name,
    required String phone,
  }) async {
    _isBusy = true;
    notifyListeners();
    try {
      await sessionStore.writeToken(
        'demo-${DateTime.now().microsecondsSinceEpoch}',
      );
      await localStorage.setUserName(name.trim());
      await localStorage.setUserPhone(phone.trim());

      _userName = name.trim();
      _userPhone = phone.trim();
      _isAuthenticated = true;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await sessionStore.clear();
    await localStorage.clearUserProfile();
    _isAuthenticated = false;
    _userName = null;
    _userPhone = null;
    notifyListeners();
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
