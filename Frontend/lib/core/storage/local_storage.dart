import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_user.dart';

/// Penyimpanan lokal non-sensitif: flag onboarding, profil sesi, dan
/// daftar akun mode demo.
///
/// Token autentikasi tidak disimpan di sini; gunakan `SessionStore`
/// (secure storage). Kata sandi tidak pernah disimpan.
class LocalStorage {
  static const String onboardingCompletedKey = 'onboarding_completed_v1';
  static const String userNameKey = 'demo_user_name_v1';
  static const String userPhoneKey = 'demo_user_phone_v1';
  static const String cachedUserKey = 'auth_user_v1';
  static const String demoAccountsKey = 'demo_accounts_v1';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<bool> isOnboardingCompleted() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(onboardingCompletedKey) ?? false;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool(onboardingCompletedKey, value);
  }

  // ---------------------------------------------------------------------
  // Profil sesi (cache non-sensitif agar sapaan tetap muncul saat offline)
  // ---------------------------------------------------------------------

  Future<AuthUser?> getCachedUser() async {
    final SharedPreferences prefs = await _prefs;
    final String? raw = prefs.getString(cachedUserKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AuthUser.fromJson(decoded);
      }
      if (decoded is Map) {
        return AuthUser.fromJson(Map<String, dynamic>.from(decoded));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> setCachedUser(AuthUser user) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(cachedUserKey, jsonEncode(user.toJson()));
  }

  Future<void> clearCachedUser() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(cachedUserKey);
  }

  // ---------------------------------------------------------------------
  // Akun mode demo
  // ---------------------------------------------------------------------

  Future<String?> getDemoAccountsJson() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(demoAccountsKey);
  }

  Future<void> setDemoAccountsJson(String value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(demoAccountsKey, value);
  }

  // ---------------------------------------------------------------------
  // Kompatibilitas dengan sesi demo Tahap 2 (nama & nomor HP)
  // ---------------------------------------------------------------------

  Future<String?> getUserName() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(userNameKey);
  }

  Future<void> setUserName(String value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(userNameKey, value);
  }

  Future<String?> getUserPhone() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString(userPhoneKey);
  }

  Future<void> setUserPhone(String value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(userPhoneKey, value);
  }

  Future<void> clearUserProfile() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(userNameKey);
    await prefs.remove(userPhoneKey);
    await prefs.remove(cachedUserKey);
  }
}
