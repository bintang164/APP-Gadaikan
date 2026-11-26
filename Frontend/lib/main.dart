import 'package:flutter/material.dart';
import 'core/auth/api_auth_service.dart';
import 'core/auth/auth_repository.dart';
import 'core/auth/mock_auth_service.dart';
import 'core/config/app_config.dart';
import 'core/services/api_gadaikan_repository.dart';
import 'core/services/gadaikan_repository.dart';
import 'core/storage/local_storage.dart';
import 'core/storage/session_store.dart';
import 'core/state/app_state.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/onboarding_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/home/screens/main_shell_screen.dart';
import 'features/info/screens/faq_screen.dart';
import 'features/info/screens/notifications_screen.dart';
import 'features/info/screens/outlets_screen.dart';
import 'features/info/screens/promos_screen.dart';
import 'features/pawn/screens/category_selection_screen.dart';
import 'features/simulation/screens/simulation_screen.dart';

void main() {
  runApp(GadaikanApp());
}

class GadaikanApp extends StatefulWidget {
  GadaikanApp({
    super.key,
    GadaikanRepository? repository,
  }) : repository = repository ?? _createDefaultRepository();

  /// Repository produksi: autentikasi via Laravel bila `AUTH_MODE=api`,
  /// jika tidak memakai mode demo lokal. Token disimpan di secure storage.
  static GadaikanRepository _createDefaultRepository() {
    final LocalStorage localStorage = LocalStorage();
    final AuthRepository authRepository = AuthRepository(
      service: AppConfig.useMockAuth
          ? MockAuthService(localStorage: localStorage)
          : ApiAuthService(),
      sessionStore: SecureSessionStore(),
      localStorage: localStorage,
    );
    if (AppConfig.useMockAuth) {
      return MockGadaikanRepository(authRepository: authRepository);
    }
    return ApiGadaikanRepository(authRepository: authRepository);
  }

  final GadaikanRepository repository;

  @override
  State<GadaikanApp> createState() => _GadaikanAppState();
}

class _GadaikanAppState extends State<GadaikanApp> {
  late final AppState _appState;

  @override
  void initState() {
    super.initState();
    _appState = AppState(widget.repository);
  }

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      state: _appState,
      child: MaterialApp(
        title: 'Gadaikan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (_) => const SplashScreen(),
          OnboardingScreen.routeName: (_) => const OnboardingScreen(),
          LoginScreen.routeName: (_) => const LoginScreen(),
          RegisterScreen.routeName: (_) => const RegisterScreen(),
          MainShellScreen.routeName: (_) => const MainShellScreen(),
          CategorySelectionScreen.routeName: (_) =>
              const CategorySelectionScreen(),
          SimulationScreen.routeName: (_) => const SimulationScreen(),
          OutletsScreen.routeName: (_) => const OutletsScreen(),
          PromosScreen.routeName: (_) => const PromosScreen(),
          NotificationsScreen.routeName: (_) => const NotificationsScreen(),
          FaqScreen.routeName: (_) => const FaqScreen(),
        },
      ),
    );
  }
}
