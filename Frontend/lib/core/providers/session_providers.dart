import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/api_auth_service.dart';
import '../auth/auth_repository.dart';
import '../auth/auth_service.dart';
import '../auth/mock_auth_service.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../state/session_controller.dart';
import '../storage/local_storage.dart';
import '../storage/session_store.dart';

final Provider<LocalStorage> localStorageProvider = Provider<LocalStorage>(
  (ref) => LocalStorage(),
);

final Provider<SessionStore> sessionStoreProvider = Provider<SessionStore>(
  (ref) => SecureSessionStore(),
);

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(),
);

/// Layanan autentikasi. Default mode demo; `AUTH_MODE=api` memakai
/// backend Laravel Sanctum. Tidak pernah berpura-pura API berhasil di
/// mode demo.
final Provider<AuthService> authServiceProvider = Provider<AuthService>((ref) {
  if (AppConfig.useMockAuth) {
    return MockAuthService(localStorage: ref.watch(localStorageProvider));
  }
  return ApiAuthService(apiClient: ref.watch(apiClientProvider));
});

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>(
  (ref) => AuthRepository(
    service: ref.watch(authServiceProvider),
    sessionStore: ref.watch(sessionStoreProvider),
    localStorage: ref.watch(localStorageProvider),
  ),
);

final ChangeNotifierProvider<SessionController> sessionControllerProvider =
    ChangeNotifierProvider<SessionController>(
  (ref) => SessionController(
    localStorage: ref.watch(localStorageProvider),
    authRepository: ref.watch(authRepositoryProvider),
  ),
);
