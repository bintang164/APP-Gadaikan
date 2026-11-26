import 'package:dio/dio.dart';

import '../auth/auth_repository.dart';
import '../models/gadaikan_models.dart';
import '../network/api_client.dart';
import '../network/api_error_mapper.dart';
import '../utils/formatters.dart';
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
  Future<PawnApplication> getApplicationDetail(String id) async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
        '$applicationsPath/$id',
        queryParameters: <String, dynamic>{'include': 'status_history'},
        options: Options(headers: await _headers()),
      );
      final Map<String, dynamic> body = ApiClient.extractMap(response.data);
      final Object? applicationJson = body['application'] ?? body;
      if (applicationJson is! Map) {
        throw Exception('Detail pengajuan tidak tersedia dari server.');
      }
      return PawnApplication.fromApiJson(
        Map<String, dynamic>.from(applicationJson),
      );
    } on DioException catch (error) {
      throw Exception(ApiErrorMapper.messageFor(error));
    }
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

  static const String transactionsPath = '/transactions';

  @override
  Future<List<PawnTransaction>> getTransactions() async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
        transactionsPath,
        options: Options(headers: await _headers()),
      );
      final Object? payload = response.data;
      final List<dynamic> raw = payload is List
          ? payload
          : (ApiClient.extractMap(payload)['data'] as List? ?? <dynamic>[]);
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (Map<dynamic, dynamic> item) => PawnTransaction.fromApiJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();
    } on DioException catch (error) {
      throw Exception(ApiErrorMapper.messageFor(error));
    }
  }

  @override
  Future<PawnTransaction> getTransactionDetail(String id) async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
        '$transactionsPath/$id',
        options: Options(headers: await _headers()),
      );
      final Map<String, dynamic> body = ApiClient.extractMap(response.data);
      final Object? json = body['transaction'] ?? body;
      if (json is! Map) throw Exception('Detail transaksi tidak tersedia.');
      return PawnTransaction.fromApiJson(Map<String, dynamic>.from(json));
    } on DioException catch (error) {
      throw Exception(ApiErrorMapper.messageFor(error));
    }
  }

  @override
  Future<PawnTransaction> acceptOffer(String applicationId) async {
    try {
      final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
        '$applicationsPath/$applicationId/accept-offer',
        options: Options(headers: await _headers()),
      );
      final Map<String, dynamic> body = ApiClient.extractMap(response.data);
      final Object? json = body['transaction'] ?? body;
      if (json is! Map) {
        throw Exception('Server tidak mengembalikan data transaksi.');
      }
      return PawnTransaction.fromApiJson(Map<String, dynamic>.from(json));
    } on DioException catch (error) {
      throw Exception(ApiErrorMapper.messageFor(error));
    }
  }

  @override
  Future<PawnApplication> declineOffer(String applicationId) async {
    try {
      final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
        '$applicationsPath/$applicationId/decline-offer',
        options: Options(headers: await _headers()),
      );
      final Map<String, dynamic> body = ApiClient.extractMap(response.data);
      final Object? json = body['application'] ?? body;
      if (json is! Map) throw Exception('Server tidak mengembalikan detail pengajuan.');
      return PawnApplication.fromApiJson(Map<String, dynamic>.from(json));
    } on DioException catch (error) {
      throw Exception(ApiErrorMapper.messageFor(error));
    }
  }

  @override
  Future<PawnTransaction> recordDemoPayment({
    required String transactionId,
    required double amount,
    required String method,
  }) async {
    try {
      final Response<dynamic> response = await _apiClient.dio.post<dynamic>(
        '$transactionsPath/$transactionId/demo-payment',
        options: Options(headers: await _headers()),
        data: <String, dynamic>{
          'amount': amount,
          'method': method,
          'is_demo': true,
        },
      );
      final Map<String, dynamic> body = ApiClient.extractMap(response.data);
      final Object? json = body['transaction'] ?? body;
      if (json is! Map) throw Exception('Server tidak mengembalikan data transaksi.');
      return PawnTransaction.fromApiJson(Map<String, dynamic>.from(json));
    } on DioException catch (error) {
      throw Exception(ApiErrorMapper.messageFor(error));
    }
  }

  @override
  Future<PagedHistory> getHistoryPage({
    String filter = 'all',
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      // Dua endpoint milik pengguna yang sedang login; tidak ada data
      // lintas akun karena token Bearer dikirim ke keduanya.
      final PagedApplications applications = await getApplicationsPage(
        status: null,
        page: 1,
        perPage: 100,
      );
      final List<PawnTransaction> transactions = await getTransactions();
      final List<HistoryItem> all = <HistoryItem>[];

      if (filter == 'all' || filter == 'applications' || filter == 'rejected') {
        for (final PawnApplication app in applications.items) {
          final bool include = filter == 'rejected'
              ? app.status == ApplicationStatus.rejected ||
                  app.status == ApplicationStatus.offerDeclined ||
                  app.status == ApplicationStatus.cancelled
              : true;
          if (include) {
            all.add(
              HistoryItem(
                id: app.id,
                kind: HistoryKind.application,
                code: app.code,
                title: app.itemTitle,
                category: app.category,
                date: app.updatedAt,
                statusLabel: app.status.label,
                statusTone: app.status.tone,
                amountLabel: app.assessment != null
                    ? AppFormatters.formatRupiah(app.assessment!.approvedPrincipal)
                    : null,
              ),
            );
          }
        }
      }

      if (filter != 'applications') {
        for (final PawnTransaction trx in transactions) {
          final bool include = switch (filter) {
            'active' => trx.status == TransactionStatus.active ||
                trx.status == TransactionStatus.paymentPending ||
                trx.status == TransactionStatus.overdue,
            'paid_off' => trx.status == TransactionStatus.paidOff ||
                trx.status == TransactionStatus.closed,
            'rejected' => false,
            _ => true,
          };
          if (include) {
            all.add(
              HistoryItem(
                id: trx.id,
                kind: HistoryKind.transaction,
                code: trx.code,
                title: trx.itemTitle,
                category: trx.category,
                date: trx.startDate,
                statusLabel: trx.status.label,
                statusTone: trx.status.tone,
                amountLabel: AppFormatters.formatRupiah(trx.principalAmount),
              ),
            );
          }
        }
      }

      all.sort((HistoryItem a, HistoryItem b) => b.date.compareTo(a.date));
      final int start = ((page < 1 ? 1 : page) - 1) * perPage;
      return PagedHistory(
        items: start >= all.length
            ? <HistoryItem>[]
            : all.skip(start).take(perPage).toList(),
        page: page < 1 ? 1 : page,
        perPage: perPage,
        total: all.length,
      );
    } on DioException catch (error) {
      throw Exception(ApiErrorMapper.messageFor(error));
    }
  }

  @override
  Future<List<OutletInfo>> getOutlets() async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
        '/outlets',
        options: Options(headers: await _headers()),
      );
      final Object? payload = response.data;
      final List<dynamic> raw = payload is List
          ? payload
          : (ApiClient.extractMap(payload)['data'] as List? ?? <dynamic>[]);
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => OutletInfo.fromApiJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    } on DioException catch (error) {
      throw Exception(ApiErrorMapper.messageFor(error));
    }
  }

  @override
  Future<List<PromoInfo>> getPromotions() async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
        '/promotions',
        options: Options(headers: await _headers()),
      );
      final Object? payload = response.data;
      final List<dynamic> raw = payload is List
          ? payload
          : (ApiClient.extractMap(payload)['data'] as List? ?? <dynamic>[]);
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => PromoInfo.fromApiJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    } on DioException catch (error) {
      throw Exception(ApiErrorMapper.messageFor(error));
    }
  }

  @override
  Future<List<AppNotification>> getNotifications() async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
        '/notifications',
        options: Options(headers: await _headers()),
      );
      final Object? payload = response.data;
      final List<dynamic> raw = payload is List
          ? payload
          : (ApiClient.extractMap(payload)['data'] as List? ?? <dynamic>[]);
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => AppNotification.fromApiJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    } on DioException catch (error) {
      throw Exception(ApiErrorMapper.messageFor(error));
    }
  }

  @override
  Future<void> markNotificationRead(String notificationId) async {
    try {
      await _apiClient.dio.post<dynamic>(
        '/notifications/$notificationId/read',
        options: Options(headers: await _headers()),
      );
    } on DioException catch (error) {
      throw Exception(ApiErrorMapper.messageFor(error));
    }
  }

  @override
  Future<void> markAllNotificationsRead() async {
    try {
      await _apiClient.dio.post<dynamic>(
        '/notifications/read-all',
        options: Options(headers: await _headers()),
      );
    } on DioException catch (error) {
      throw Exception(ApiErrorMapper.messageFor(error));
    }
  }

  @override
  Future<List<FaqItem>> getFaqs() async {
    try {
      final Response<dynamic> response = await _apiClient.dio.get<dynamic>(
        '/faqs',
        options: Options(headers: await _headers()),
      );
      final Object? payload = response.data;
      final List<dynamic> raw = payload is List
          ? payload
          : (ApiClient.extractMap(payload)['data'] as List? ?? <dynamic>[]);
      return raw
          .whereType<Map<dynamic, dynamic>>()
          .map((Map<dynamic, dynamic> item) => FaqItem.fromApiJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
    } on DioException catch (error) {
      throw Exception(ApiErrorMapper.messageFor(error));
    }
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    try {
      final Response<dynamic> response = await _apiClient.dio.put<dynamic>(
        '/profile',
        options: Options(headers: await _headers()),
        data: <String, dynamic>{
          'name': profile.name,
          'phone': profile.phone,
          'email': profile.email,
          'address': profile.address,
        },
      );
      final Map<String, dynamic> body = ApiClient.extractMap(response.data);
      final Object? json = body['user'] ?? body['profile'] ?? body;
      if (json is! Map) return profile;
      final Map<String, dynamic> map = Map<String, dynamic>.from(json);
      return UserProfile(
        id: '${map['id'] ?? profile.id}',
        name: '${map['name'] ?? profile.name}',
        phone: '${map['phone'] ?? profile.phone}',
        email: map['email']?.toString(),
        address: map['address']?.toString(),
      );
    } on DioException catch (error) {
      throw Exception(ApiErrorMapper.messageFor(error));
    }
  }
}
