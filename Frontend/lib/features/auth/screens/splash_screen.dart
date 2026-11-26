import 'package:flutter/material.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/gadaikan_logo.dart';
import '../../home/screens/main_shell_screen.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const String routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _bootstrapped = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bootstrapped) return;
    _bootstrapped = true;
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final appState = AppStateScope.of(context);
    final results = await Future.wait([
      appState.initialize(),
      Future<void>.delayed(const Duration(milliseconds: 1200)),
    ]);
    if (!mounted) return;
    final isAuthenticated = results[0] as bool;
    final nextRoute = isAuthenticated
        ? MainShellScreen.routeName
        : (appState.hasSeenOnboarding
            ? LoginScreen.routeName
            : OnboardingScreen.routeName);
    Navigator.of(context).pushReplacementNamed(nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const Spacer(),
              const GadaikanLogo(
                size: 72,
                darkBackground: true,
              ),
              const SizedBox(height: 16),
              Text(
                'Solusi Gadai dalam Genggaman',
                style: TextStyle(
                  color: AppColors.accentGold.withValues(alpha: 0.95),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.accentGold),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Prototipe Akademik • Mode Demo',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
