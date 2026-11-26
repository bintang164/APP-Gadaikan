import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/core/auth/api_auth_service.dart';
import 'package:flutter_application_1/core/auth/auth_exception.dart';
import 'package:flutter_application_1/core/auth/auth_repository.dart';
import 'package:flutter_application_1/core/auth/mock_auth_service.dart';
import 'package:flutter_application_1/core/models/auth_user.dart';
import 'package:flutter_application_1/core/network/api_error_mapper.dart';
import 'package:flutter_application_1/core/network/api_client.dart';
import 'package:flutter_application_1/core/storage/local_storage.dart';
import 'package:flutter_application_1/core/storage/session_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  AuthRepository buildRepository(InMemorySessionStore store) {
    final LocalStorage localStorage = LocalStorage();
    return AuthRepository(
      service: MockAuthService(
        localStorage: localStorage,
        delay: Duration.zero,
      ),
      sessionStore: store,
      localStorage: localStorage,
    );
  }

  test('register -> logout -> login -> sesi bertahan dari token', () async {
    final InMemorySessionStore store = InMemorySessionStore();
    final AuthRepository repository = buildRepository(store);

    final AuthUser registered = await repository.register(
      name: 'Siti Rahma',
      phone: '081234567891',
      email: 'siti@example.test',
      password: 'rahasia123',
    );
    expect(registered.name, 'Siti Rahma');
    expect(registered.isDemo, isTrue);
    expect(await store.readToken(), isNotNull);
    expect((await store.readToken())!.startsWith('demo-'), isTrue);

    await repository.logout();
    expect(await store.readToken(), isNull);
    expect(await repository.restoreSession(), isNull);

    final AuthUser loggedIn = await repository.login(
      identifier: 'siti@example.test',
      password: 'rahasia123',
    );
    expect(loggedIn.phone, '081234567891');

    // Sesi baru membaca token yang sama dari secure storage.
    final AuthRepository restarted = buildRepository(store);
    final AuthUser? restored = await restarted.restoreSession();
    expect(restored, isNotNull);
    expect(restored!.name, 'Siti Rahma');
    expect(restored.isDemo, isTrue);
  });

  test('kata sandi tidak pernah disimpan', () async {
    final InMemorySessionStore store = InMemorySessionStore();
    final LocalStorage localStorage = LocalStorage();
    final AuthRepository repository = AuthRepository(
      service: MockAuthService(
        localStorage: localStorage,
        delay: Duration.zero,
      ),
      sessionStore: store,
      localStorage: localStorage,
    );

    await repository.register(
      name: 'Budi Demo',
      phone: '081234567892',
      password: 'sangatRahasia123',
    );

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Pastikan tidak ada kunci yang menyimpan kata sandi.
    expect(
      prefs.getKeys().where((String key) => key.toLowerCase().contains('pass')),
      isEmpty,
    );
    expect(
      await localStorage.getDemoAccountsJson(),
      isNot(contains('sangatRahasia123')),
    );
    expect(await store.readToken(), isNot(contains('sangatRahasia123')));
  });

  test('login akun demo bawaan berhasil, akun unknown -> 401 demo', () async {
    final AuthRepository repository = buildRepository(InMemorySessionStore());
    final AuthUser user = await repository.login(
      identifier: '081234567890',
      password: 'demo1234',
    );
    expect(user.name, 'Pengguna Gadaikan');

    try {
      await repository.login(
        identifier: '081299999999',
        password: 'demo1234',
      );
      fail('Seharusnya melempar AuthException');
    } on AuthException catch (error) {
      expect(error.type, AuthFailureType.unauthorized);
      expect(error.fieldErrors['identifier'], isNotNull);
    }
  });

  test('register duplikat -> 422 dengan error per field', () async {
    final AuthRepository repository = buildRepository(InMemorySessionStore());
    await repository.register(
      name: 'Pertama Demo',
      phone: '081234567893',
      password: 'rahasia123',
    );

    try {
      await repository.register(
        name: 'Kedua Demo',
        phone: '081234567893',
        password: 'rahasia123',
      );
      fail('Seharusnya melempar AuthException');
    } on AuthException catch (error) {
      expect(error.type, AuthFailureType.validation);
      expect(error.fieldErrors['phone'], contains('sudah terdaftar'));
    }
  });

  test('ApiErrorMapper memetakan 401, 422, timeout, dan koneksi', () async {
    final ApiAuthService api = ApiAuthService(apiClient: ApiClient());

    final AuthException connection = ApiErrorMapper.toAuthException(
      DioException(
        requestOptions: RequestOptions(path: '/login'),
        type: DioExceptionType.connectionError,
      ),
    );
    expect(connection.type, AuthFailureType.network);

    expect(
      ApiErrorMapper.toAuthException(
        DioException(
          requestOptions: RequestOptions(path: '/login'),
          response: Response<dynamic>(
            statusCode: 401,
            data: <String, dynamic>{'message': 'Unauthenticated.'},
            requestOptions: RequestOptions(path: '/login'),
          ),
          type: DioExceptionType.badResponse,
        ),
      ).type,
      AuthFailureType.unauthorized,
    );

    final AuthException validation = ApiErrorMapper.toAuthException(
      DioException(
        requestOptions: RequestOptions(path: '/register'),
        response: Response<dynamic>(
          statusCode: 422,
          data: <String, dynamic>{
            'message': 'Validasi gagal.',
            'errors': <String, dynamic>{
              'phone': <String>['Nomor HP sudah digunakan.'],
            },
          },
          requestOptions: RequestOptions(path: '/register'),
        ),
        type: DioExceptionType.badResponse,
      ),
      fieldErrorsParser: (Object? data) =>
          ApiErrorMapper.parseLaravelFieldErrors(data),
    );
    expect(validation.type, AuthFailureType.validation);
    expect(validation.fieldErrors['phone'], 'Nomor HP sudah digunakan.');

    expect(
      ApiErrorMapper.toAuthException(
        DioException(
          requestOptions: RequestOptions(path: '/login'),
          type: DioExceptionType.sendTimeout,
        ),
      ).type,
      AuthFailureType.timeout,
    );

    // Pastikan service API tidak mengklaim mode demo.
    expect(api.isMock, isFalse);
  });
}
