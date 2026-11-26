import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/session_controller.dart';
import '../storage/local_storage.dart';
import '../storage/session_store.dart';

final Provider<LocalStorage> localStorageProvider = Provider<LocalStorage>(
  (ref) => LocalStorage(),
);

final Provider<SessionStore> sessionStoreProvider = Provider<SessionStore>(
  (ref) => SecureSessionStore(),
);

final ChangeNotifierProvider<SessionController> sessionControllerProvider =
    ChangeNotifierProvider<SessionController>(
  (ref) => SessionController(
    localStorage: ref.watch(localStorageProvider),
    sessionStore: ref.watch(sessionStoreProvider),
  ),
);
