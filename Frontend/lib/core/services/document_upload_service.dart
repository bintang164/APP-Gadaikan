import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../network/api_client.dart';
import '../network/api_error_mapper.dart';
import '../storage/session_store.dart';

/// Berkas hasil picker sebelum dikirim. Path bersifat lokal/privat.
class PickedDocument {
  const PickedDocument({
    required this.path,
    required this.name,
    required this.sizeBytes,
    this.mimeType,
  });

  final String path;
  final String name;
  final int sizeBytes;
  final String? mimeType;

  String get extension {
    final int dot = name.lastIndexOf('.');
    return dot == -1 ? '' : name.substring(dot + 1).toLowerCase();
  }
}

/// Metadata dari server. Tidak menyimpan URL publik untuk berkas privat.
class UploadedDocumentMeta {
  const UploadedDocumentMeta({
    required this.serverId,
    this.isDemo = false,
    this.privateReference,
  });

  final String serverId;
  final bool isDemo;

  /// Referensi internal (bukan URL publik), hanya untuk keperluan API
  /// terotorisasi. Boleh null pada mode demo.
  final String? privateReference;
}

class DocumentUploadException implements Exception {
  const DocumentUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Validasi tipe dan ukuran berkas sebelum upload.
class DocumentValidation {
  const DocumentValidation._();

  static const int maxBytes = 5 * 1024 * 1024; // 5 MB
  static const List<String> allowedExtensions = <String>[
    'jpg',
    'jpeg',
    'png',
    'pdf',
  ];

  static String? validate(PickedDocument file) {
    if (!allowedExtensions.contains(file.extension)) {
      return 'Format berkas tidak didukung. Gunakan JPG, PNG, atau PDF.';
    }
    if (file.sizeBytes <= 0) {
      return 'Berkas kosong atau tidak dapat dibaca.';
    }
    if (file.sizeBytes > maxBytes) {
      return 'Ukuran berkas melebihi 5 MB.';
    }
    return null;
  }
}

/// Kontrak upload dokumen. Implementasi mock tidak boleh mengklaim
/// berkas tersimpan di server.
abstract class DocumentUploadService {
  bool get isMock;

  Future<UploadedDocumentMeta> upload({
    required PickedDocument file,
    required bool isSensitive,
    required void Function(double progress) onProgress,
  });
}

/// Mode demo: hanya menyimpan metadata lokal dan melabeli hasilnya.
class MockDocumentUploadService implements DocumentUploadService {
  final Duration stepDelay;

  MockDocumentUploadService({this.stepDelay = const Duration(milliseconds: 120)});

  @override
  bool get isMock => true;

  @override
  Future<UploadedDocumentMeta> upload({
    required PickedDocument file,
    required bool isSensitive,
    required void Function(double progress) onProgress,
  }) async {
    for (int step = 1; step <= 5; step++) {
      if (stepDelay > Duration.zero) {
        await Future<void>.delayed(stepDelay);
      }
      onProgress(step / 5);
    }
    return UploadedDocumentMeta(
      serverId: 'demo-local-${DateTime.now().microsecondsSinceEpoch}',
      isDemo: true,
    );
  }
}

/// Upload multipart ke Laravel. Endpoint dan nama field mengikuti kontrak PRD;
/// backend belum tersedia sehingga belum diverifikasi.
class ApiDocumentUploadService implements DocumentUploadService {
  ApiDocumentUploadService({
    ApiClient? apiClient,
    SessionStore? sessionStore,
  })  : _apiClient = apiClient ?? ApiClient(),
        _sessionStore = sessionStore ?? SecureSessionStore();

  final ApiClient _apiClient;
  final SessionStore _sessionStore;

  static const String uploadPath = '/pawn-applications/documents';

  @override
  bool get isMock => false;

  @override
  Future<UploadedDocumentMeta> upload({
    required PickedDocument file,
    required bool isSensitive,
    required void Function(double progress) onProgress,
  }) async {
    try {
      final String? token = await _sessionStore.readToken();
      if (token == null || token.isEmpty) {
        throw const DocumentUploadException(
          'Sesi berakhir. Silakan masuk kembali sebelum mengunggah berkas.',
        );
      }

      final FormData form = FormData.fromMap(<String, dynamic>{
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.name,
        ),
        'is_sensitive': isSensitive.toString(),
      });

      final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
        uploadPath,
        data: form,
        options: Options(
          headers: <String, String>{'Authorization': 'Bearer $token'},
          sendTimeout: AppConfig.apiTimeout,
        ),
        onSendProgress: (int sent, int total) {
          if (total > 0) onProgress(sent / total);
        },
      );

      onProgress(1);
      final Map<String, dynamic> body =
          ApiClient.extractMap(response.data);
      final Object? id = body['id'] ?? body['document_id'];
      if (id == null) {
        throw const DocumentUploadException(
          'Server tidak mengembalikan metadata berkas. Coba lagi.',
        );
      }
      return UploadedDocumentMeta(
        serverId: '$id',
        privateReference: body['reference']?.toString(),
      );
    } on DioException catch (error) {
      throw DocumentUploadException(ApiErrorMapper.messageFor(error));
    } on DocumentUploadException {
      rethrow;
    } catch (_) {
      throw const DocumentUploadException(
        'Gagal mengunggah berkas. Periksa koneksi lalu coba lagi.',
      );
    }
  }
}
