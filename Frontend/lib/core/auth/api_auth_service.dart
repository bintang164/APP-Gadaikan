import 'package:dio/dio.dart';

import '../models/auth_user.dart';
import '../network/api_client.dart';
import '../network/api_error_mapper.dart';
import 'auth_exception.dart';
import 'auth_service.dart';

/// Autentikasi terhadap backend Laravel Sanctum.
///
/// Kontrak endpoint (sesuai PRD Gadaikan; akan diverifikasi saat backend
/// tersedia, bukan klaim endpoint yang sudah berjalan):
/// - `POST /api/login` `{identifier, password, device_name}`
/// - `POST /api/register` `{name, phone, email?, password, password_confirmation, device_name}`
/// - `POST /api/logout` (Bearer token)
/// - `GET /api/me` (Bearer token)
///
/// Kata sandi tidak disimpan di perangkat; hanya token akses yang
/// disimpan aman oleh [SessionStore].
class ApiAuthService implements AuthService {
  final ApiClient apiClient;
  final String deviceName;

  ApiAuthService({
    ApiClient? apiClient,
    this.deviceName = 'gadaikan-android',
  }) : apiClient = apiClient ?? ApiClient();

  @override
  bool get isMock => false;

  @override
  Future<AuthSession> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final Response<dynamic> response = await apiClient.dio.post<dynamic>(
        '/login',
        data: <String, dynamic>{
          'identifier': identifier.trim(),
          'password': password,
          'device_name': deviceName,
        },
      );
      return _parseSession(response.data, fallbackIdentifier: identifier);
    } on DioException catch (error) {
      throw ApiErrorMapper.toAuthException(
        error,
        fieldErrorsParser: (Object? errors) =>
            ApiErrorMapper.parseLaravelFieldErrors(
          errors,
          keyMap: const <String, String>{
            'email': 'identifier',
            'login': 'identifier',
            'identifier': 'identifier',
          },
        ),
        unauthorizedMessage:
            'Nomor HP/email atau kata sandi salah. Periksa kembali data kamu.',
      );
    }
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String phone,
    String? email,
    required String password,
  }) async {
    try {
      final Response<dynamic> response = await apiClient.dio.post<dynamic>(
        '/register',
        data: <String, dynamic>{
          'name': name.trim(),
          'phone': phone.trim(),
          'email': (email == null || email.trim().isEmpty) ? null : email.trim(),
          'password': password,
          'password_confirmation': password,
          'device_name': deviceName,
        },
      );
      return _parseSession(response.data, fallbackIdentifier: phone);
    } on DioException catch (error) {
      throw ApiErrorMapper.toAuthException(
        error,
        fieldErrorsParser: (Object? errors) =>
            ApiErrorMapper.parseLaravelFieldErrors(errors),
      );
    }
  }

  @override
  Future<void> logout({required String token}) async {
    try {
      await apiClient.dio.post<dynamic>(
        '/logout',
        options: Options(headers: _authHeaders(token)),
      );
    } on DioException catch (error) {
      throw ApiErrorMapper.toAuthException(error);
    }
  }

  @override
  Future<AuthUser> me({required String token}) async {
    try {
      final Response<dynamic> response = await apiClient.dio.get<dynamic>(
        '/me',
        options: Options(headers: _authHeaders(token)),
      );
      return _parseUser(response.data);
    } on DioException catch (error) {
      throw ApiErrorMapper.toAuthException(error);
    }
  }

  Map<String, String> _authHeaders(String token) {
    return <String, String>{'Authorization': 'Bearer $token'};
  }

  AuthSession _parseSession(Object? payload, {required String fallbackIdentifier}) {
    final Map<String, dynamic> map = ApiClient.extractMap(payload);

    final String token =
        '${map['token'] ?? map['access_token'] ?? map['plainTextToken'] ?? ''}';
    if (token.isEmpty) {
      throw const AuthException(
        AuthFailureType.server,
        'Server tidak mengembalikan token. Silakan coba lagi.',
      );
    }

    final AuthUser user = _parseUser(
      payload,
      fallbackIdentifier: fallbackIdentifier,
    );

    return AuthSession(token: token, user: user);
  }

  AuthUser _parseUser(Object? payload, {String fallbackIdentifier = ''}) {
    final Map<String, dynamic> outer = payload is Map
        ? Map<String, dynamic>.from(payload)
        : <String, dynamic>{};

    Object? userPayload;
    if (outer.containsKey('user')) {
      userPayload = outer['user'];
    } else if (outer.containsKey('data')) {
      final Object? data = outer['data'];
      if (data is Map && data.containsKey('user')) {
        userPayload = data['user'];
      } else if (data is Map && !data.containsKey('token')) {
        userPayload = data;
      } else {
        userPayload = outer['data'];
      }
    } else {
      userPayload = outer;
    }

    final Map<String, dynamic> userMap = userPayload is Map
        ? Map<String, dynamic>.from(userPayload)
        : <String, dynamic>{};

    // Buang key token agar tidak terbawa ke model pengguna.
    userMap.remove('token');
    userMap.remove('access_token');

    final bool phoneOrEmailIsEmail = fallbackIdentifier.contains('@');

    final Map<String, dynamic> normalized = <String, dynamic>{
      'id': userMap['id'] ?? '',
      'name': userMap['name'] ?? '',
      'phone': userMap['phone'] ??
          userMap['phone_number'] ??
          (phoneOrEmailIsEmail ? '' : fallbackIdentifier),
      'email': userMap['email'] ?? (phoneOrEmailIsEmail ? fallbackIdentifier : null),
      ...userMap,
    };

    return AuthUser.fromJson(normalized);
  }
}
