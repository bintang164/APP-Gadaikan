import 'package:dio/dio.dart';

import '../auth/auth_repository.dart';
import '../models/gadaikan_models.dart';
import '../network/api_client.dart';
import '../network/api_error_mapper.dart';
import 'gadaikan_repository.dart';

/// Repository pengajuan yang benar-benar memanggil Laravel.
///
/// Method selain daftar & submit masih memakai implementasi demo dari
/// [MockGadaikanRepository] sampai endpoint terkait tersedia. Status ini
/// tidak disamarkan: UI menampilkan label demo untuk data tersebut.
class ApiGadaikanRepository extends MockGadaikanRepository {
  ApiGadaikanRepository({
    required AuthRepository authRepository,
    ApiClient? apiClient,
  })  : _apiClient = apiClient ?? ApiClient(),
        super(authRepository: authRepository);

  final ApiClient _apiClient;

  static const String applicationsPath = '/pawn-applications';

  @override
  bool get usesBackend => true;

  Future<Map<String, String>> _headers() async {
    final String? token = await authRepository!.readToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesi berakhir. Silakan masuk kembali.');
    }
    return <String, String>{'Authorization': 'Bearer $token'};
  }

  @override
  Future<List<PawnApplication>> getApplications() async {
    final PagedApplications page =
        await getApplicationsPage(status: null, page: 1, perPage: 50);
    return page.items;
  }

  @override
  Future<PagedApplications> getApplicationsPage({
    String? status,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
        applicationsPath,
        queryParameters: <String, dynamic>{
          'status': status ?? 'all',
          'page': page,
          'per_page': perPage,
        },
        options: Options(headers: await _headers()),
      );

      final Object? payload = response.data;
      final List<dynamic> rawItems;
      int resolvedPage = page;
      int resolvedPerPage = perPage;
      int total;

      if (payload is List) {
        rawItems = payload;
        total = payload.length;
      } else {
        final Map<String, dynamic> map = ApiClient.extractMap(payload);
        final Object? data = map['data'];
        rawItems = data is List ? data : <dynamic>[];
        final Object? meta = map['meta'] ?? map['pagination'];
        if (meta is Map) {
          resolvedPage = (meta['current_page'] is num)
              ? (meta['current_page'] as num).toInt()
              : page;
          resolvedPerPage = (meta['per_page'] is num)
              ? (meta['per_page'] as num).toInt()
              : perPage;
          total = (meta['total'] is num) ? (meta['total'] as num).toInt() : rawItems.length;
        } else {
          total = (map['total'] is num)
              ? (map['total'] as num).toInt()
              : rawItems.length;
        }
      }

      final List<PawnApplication> items = rawItems
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (Map<dynamic, dynamic> item) => PawnApplication.fromApiJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      return PagedApplications(
        items: items,
        page: resolvedPage,
        perPage: resolvedPerPage,
        total: total,
      );
    } on DioException catch (error) {
      throw Exception(ApiErrorMapper.messageFor(error));
    }
  }

  @override
  Future<PawnApplication> submitApplication({
    required PawnCategory category,
    required String itemTitle,
    required Map<String, String> itemDetails,
    required List<PawnDocument> documents,
    double? estimatedValue,
    int? preferredTenorDays,
  }) async {
    try {
      // Hanya berkas yang benar-benar tersimpan di server yang dikirim.
      final List<Map<String, dynamic>> uploadedDocuments = documents
          .where((PawnDocument doc) => doc.serverId != null)
          .map(
            (PawnDocument doc) => <String, dynamic>{
              'id': doc.serverId,
              'label': doc.label,
              'is_sensitive': doc.isSensitive,
            },
          )
          .toList();

      final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
        applicationsPath,
        options: Options(headers: await _headers()),
        data: <String, dynamic>{
          'category': category.apiId,
          'item_title': itemTitle,
          'item_details': itemDetails,
          'estimated_value': estimatedValue,
          'preferred_tenor_days': preferredTenorDays,
          'documents': uploadedDocuments,
        },
      );

      final Map<String, dynamic> body = ApiClient.extractMap(response.data);
      final Object? applicationJson = body['application'] ?? body;
      if (applicationJson is! Map) {
        throw Exception(
          'Server tidak mengembalikan data pengajuan. Coba lagi.',
        );
      }
      final PawnApplication application = PawnApplication.fromApiJson(
        Map<String, dynamic>.from(applicationJson),
      );
      if (application.code.isEmpty) {
        // Tidak pernah membuat nomor pengajuan palsu saat API gagal.
        throw Exception(
          'Server tidak mengembalikan nomor pengajuan. Coba lagi.',
        );
      }
      return application;
    } on DioException catch (error) {
      throw Exception(ApiErrorMapper.messageFor(error));
    }
  }
}
