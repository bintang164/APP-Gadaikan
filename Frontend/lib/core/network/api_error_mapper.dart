import 'package:dio/dio.dart';

import '../auth/auth_exception.dart';

/// Pemetaan error Dio menjadi pesan yang bisa dipahami pengguna.
class ApiErrorMapper {
  const ApiErrorMapper._();

  static bool isTimeout(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout;
  }

  static bool isNetwork(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.badCertificate ||
        error.type == DioExceptionType.unknown;
  }

  static AuthException toAuthException(
    DioException error, {
    Map<String, String> Function(Object? errors)? fieldErrorsParser,
    String unauthorizedMessage =
        'Nomor HP/email atau kata sandi salah. Periksa kembali data kamu.',
  }) {
    if (isTimeout(error)) {
      return const AuthException(
        AuthFailureType.timeout,
        'Server terlalu lama merespons. Periksa koneksi lalu coba lagi.',
      );
    }

    if (isNetwork(error) && error.response == null) {
      return const AuthException(
        AuthFailureType.network,
        'Tidak dapat terhubung ke server. Periksa koneksi internet kamu.',
      );
    }

    final int? status = error.response?.statusCode;
    final Object? data = error.response?.data;

    if (status == 401) {
      return AuthException(
        AuthFailureType.unauthorized,
        unauthorizedMessage,
      );
    }

    if (status == 422) {
      final Map<String, String> fieldErrors =
          fieldErrorsParser?.call(data) ?? const <String, String>{};
      return AuthException(
        AuthFailureType.validation,
        _messageFromPayload(data) ??
            'Data yang dimasukkan belum sesuai. Periksa kembali.',
        fieldErrors: fieldErrors,
      );
    }

    if (status == 429) {
      return const AuthException(
        AuthFailureType.server,
        'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.',
      );
    }

    if (status != null && status >= 500) {
      return const AuthException(
        AuthFailureType.server,
        'Server sedang bermasalah. Coba lagi beberapa saat lagi.',
      );
    }

    return AuthException(
      AuthFailureType.unknown,
      _messageFromPayload(data) ?? 'Terjadi kesalahan. Silakan coba lagi.',
    );
  }

  static String messageFor(DioException error) {
    if (isTimeout(error)) {
      return 'Server terlalu lama merespons. Periksa koneksi lalu coba lagi.';
    }
    if (isNetwork(error) && error.response == null) {
      return 'Tidak dapat terhubung ke server. Periksa koneksi internet kamu.';
    }
    final int? status = error.response?.statusCode;
    if (status == 401) return 'Sesi kamu berakhir. Silakan masuk kembali.';
    if (status == 429) {
      return 'Terlalu banyak permintaan. Tunggu sebentar lalu coba lagi.';
    }
    if (status != null && status >= 500) {
      return 'Server sedang bermasalah. Coba lagi beberapa saat lagi.';
    }
    return _messageFromPayload(error.response?.data) ??
        'Gagal memuat data. Periksa koneksi lalu coba lagi.';
  }

  static String? _messageFromPayload(Object? payload) {
    if (payload is Map) {
      final Object? message = payload['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    return null;
  }

  /// Membaca `{errors: {field: [pesan]}}` khas Laravel.
  static Map<String, String> parseLaravelFieldErrors(
    Object? payload, {
    Map<String, String> keyMap = const <String, String>{},
  }) {
    if (payload is! Map) return const <String, String>{};
    final Object? rawErrors = payload['errors'];
    if (rawErrors is! Map) return const <String, String>{};

    final Map<String, String> result = <String, String>{};
    rawErrors.forEach((Object? key, Object? value) {
      final String rawKey = '$key';
      final String mappedKey = keyMap[rawKey] ?? rawKey;
      String? message;
      if (value is List && value.isNotEmpty) {
        message = '${value.first}';
      } else if (value is String && value.isNotEmpty) {
        message = value;
      }
      if (message != null && message.trim().isNotEmpty) {
        result[mappedKey] = message.trim();
      }
    });
    return result;
  }
}
