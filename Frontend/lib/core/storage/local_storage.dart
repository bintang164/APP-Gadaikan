import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan lokal non-sensitif: flag onboarding dan profil demo.
///
/// Token autentikasi tidak disimpan di sini; gunakan [SessionStore].
class LocalStorage {
  static const String onboardingCompletedKey = 'onboarding_completed_v1';
  static const String userNameKey = 'demo_user_name_v1';
  static const String userPhoneKey = 'demo_user_phone_v1';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<bool> isOnboardingCompleted() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(onboardingCompletedKey) ?? false;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool(onboardingCompletedKey, value);
  }

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
  }
}
