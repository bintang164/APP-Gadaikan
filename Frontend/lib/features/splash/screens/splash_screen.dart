import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_logo.dart';
import '../../../core/providers/session_providers.dart';
import '../../../core/state/session_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    // Tampilkan identitas sebentar, tetapi jangan menahan pengguna.
    await Future<void>.delayed(AppDurations.splashMinimum);
    if (!mounted) return;

    final SessionController session = ref.read(sessionControllerProvider);
    await session.bootstrap();
    if (!mounted) return;

    final String target;
    if (session.isAuthenticated) {
      target = AppRoutes.home;
    } else if (session.onboardingCompleted) {
      target = AppRoutes.login;
    } else {
      target = AppRoutes.onboarding;
    }

    context.go(target);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('splash_screen'),
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.splashGradient),
          ),
          Positioned(
            top: -90,
            right: -70,
            child: _GoldOrb(size: 240, opacity: 0.10),
          ),
          Positioned(
            bottom: -110,
            left: -80,
            child: _GoldOrb(size: 280, opacity: 0.08),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xl,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  const AppLogo(
                    fontSize: 42,
                    light: true,
                    showTagline: true,
                  ),
                  const Spacer(flex: 4),
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.gold,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Menyiapkan layanan...',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Simulasi gadai untuk prototipe akademik',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textOnPrimary.withValues(alpha: 0.50),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoldOrb extends StatelessWidget {
  final double size;
  final double opacity;

  const _GoldOrb({
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.gold.withValues(alpha: opacity),
            AppColors.gold.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
