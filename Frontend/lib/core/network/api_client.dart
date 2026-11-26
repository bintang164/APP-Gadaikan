import 'package:dio/dio.dart';

import '../config/app_config.dart';

/// Klien HTTP tunggal untuk backend Laravel.
///
/// Base URL berasal dari `--dart-define=API_BASE_URL=...` sehingga tidak
/// ada URL produksi yang di-hard-code. Token dikirim sebagai Bearer oleh
/// pemanggil yang membutuhkannya.
class ApiClient {
  final Dio dio;

  ApiClient({Dio? dio})
      : dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConfig.apiBaseUrl,
                connectTimeout: AppConfig.apiTimeout,
                receiveTimeout: AppConfig.apiTimeout,
                sendTimeout: AppConfig.apiTimeout,
                headers: <String, String>{
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            );

  /// Mengambil map dari respons yang mungkin dibungkus `{data: {...}}`.
  static Map<String, dynamic> extractMap(Object? payload) {
    if (payload is Map<String, dynamic>) {
      final Object? data = payload['data'];
      if (data is Map<String, dynamic> && payload.length == 1) {
        return data;
      }
      if (data is Map<String, dynamic> && !payload.containsKey('token')) {
        return data;
      }
      return payload;
    }
    if (payload is Map) {
      return Map<String, dynamic>.from(payload);
    }
    return <String, dynamic>{};
  }
}
