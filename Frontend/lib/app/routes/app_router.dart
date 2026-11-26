import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/session_providers.dart';
import '../../core/state/session_controller.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/history/screens/history_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/pawn/screens/pawn_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../navigation/main_shell.dart';
import '../theme/app_spacing.dart';
import '../widgets/error_state.dart';
import 'app_routes.dart';

final Provider<GoRouter> routerProvider = Provider<GoRouter>((ref) {
  final SessionController session = ref.read(sessionControllerProvider);
  return AppRouter.create(session);
});

class AppRouter {
  const AppRouter._();

  static GoRouter create(SessionController session) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: session,
      debugLogDiagnostics: false,
      redirect: (context, state) {
        final String location = state.matchedLocation;
        final bool atSplash = location == AppRoutes.splash;
        final bool atOnboarding = location == AppRoutes.onboarding;
        final bool atLogin = location == AppRoutes.login;
        final bool atRegister = location == AppRoutes.register;

        if (!session.initialized) {
          return atSplash ? null : AppRoutes.splash;
        }

        if (session.isAuthenticated) {
          if (atSplash || atOnboarding || atLogin || atRegister) {
            return AppRoutes.home;
          }
          return null;
        }

        if (!session.onboardingCompleted) {
          if (atOnboarding) return null;
          return AppRoutes.onboarding;
        }

        if (atOnboarding) return AppRoutes.login;
        if (atLogin || atRegister) return null;
        return AppRoutes.login;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: AppRoutes.splashName,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          name: AppRoutes.onboardingName,
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: AppRoutes.loginName,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoutes.register,
          name: AppRoutes.registerName,
          builder: (context, state) => const RegisterScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  name: AppRoutes.homeName,
                  builder: (context, state) =>
                      HomeScreen(onNavigateTab: (_) {}),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.applications,
                  name: AppRoutes.applicationsName,
                  builder: (context, state) => const PawnScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.history,
                  name: AppRoutes.historyName,
                  builder: (context, state) =>
                      HistoryScreen(onStartNewApplication: () {}),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.profile,
                  name: AppRoutes.profileName,
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
      errorBuilder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ErrorState(
                title: 'Halaman tidak ditemukan',
                message:
                    'Alamat "${state.uri}" tidak tersedia. Kembali ke awal aplikasi.',
                onRetry: () => context.go(AppRoutes.splash),
              ),
            ),
          ),
        );
      },
    );
  }
}
