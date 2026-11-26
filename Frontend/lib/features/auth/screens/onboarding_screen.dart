import 'package:flutter/material.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/gadaikan_logo.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      icon: Icons.category_outlined,
      title: 'Pilih jenis barang',
      description:
          'Ajukan gadai untuk barang elektronik, emas, atau BPKB kendaraan dengan alur yang terpisah dan mudah dipahami.',
      accent: AppColors.primary,
    ),
    _OnboardingSlide(
      icon: Icons.upload_file_rounded,
      title: 'Ajukan dengan mudah',
      description:
          'Isi data barang, lihat simulasi perkiraan pinjaman, dan unggah foto dokumen langsung dari ponsel Anda.',
      accent: AppColors.accentGold,
    ),
    _OnboardingSlide(
      icon: Icons.track_changes_rounded,
      title: 'Pantau prosesnya',
      description:
          'Lacak status verifikasi, hasil taksiran, dan riwayat transaksi Anda secara transparan dalam satu aplikasi.',
      accent: AppColors.success,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishOnboarding() {
    AppStateScope.of(context).completeOnboarding();
    Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.md,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const GadaikanLogo(size: 36),
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      'Lewati',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 132,
                            height: 132,
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(36),
                              border: Border.all(
                                color: slide.accent.withValues(alpha: 0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              slide.icon,
                              size: 62,
                              color: slide.accent,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            slide.title,
                            style: AppTextStyles.pageHeading,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            slide.description,
                            style: AppTextStyles.bodySecondary.copyWith(
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (index) {
                  final active = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: isLast ? 'Mulai' : 'Lanjutkan',
                onPressed: _nextPage,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accent;
}
