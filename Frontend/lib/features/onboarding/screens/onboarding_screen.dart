import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/widgets/app_logo.dart';
import '../../../app/widgets/primary_button.dart';
import '../../../core/providers/session_providers.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Pilih jenis barang',
      description:
          'Gadai elektronik, emas, atau BPKB kendaraan sesuai kebutuhanmu.',
      illustration: OnboardingIllustration.categories,
    ),
    OnboardingData(
      title: 'Ajukan dengan mudah',
      description:
          'Lengkapi data barang dan unggah dokumen langsung dari ponsel.',
      illustration: OnboardingIllustration.upload,
    ),
    OnboardingData(
      title: 'Pantau prosesnya',
      description:
          'Lihat perkembangan pengajuan dan riwayat transaksi di satu tempat.',
      illustration: OnboardingIllustration.tracking,
    ),
  ];

  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isFinishing = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _currentPage == _pages.length - 1;

  Future<void> _finish() async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);

    await ref.read(sessionControllerProvider).completeOnboarding();
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  void _next() {
    if (_isLastPage) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('onboarding_screen'),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.horizontal,
                AppSpacing.sm,
                AppSpacing.sm,
                0,
              ),
              child: Row(
                children: [
                  const AppLogo(
                    fontSize: 18,
                    showTagline: false,
                    alignment: CrossAxisAlignment.start,
                  ),
                  const Spacer(),
                  if (!_isLastPage)
                    TextButton(
                      onPressed: _isFinishing ? null : _finish,
                      child: const Text('Lewati'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return OnboardingPage(data: _pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.horizontal,
                0,
                AppSpacing.horizontal,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) {
                      final bool active = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxs,
                        ),
                        width: active ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.borderStrong,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: _isLastPage ? 'Mulai' : 'Lanjutkan',
                    onPressed: _isFinishing ? null : _next,
                    isLoading: _isFinishing,
                    icon: _isLastPage
                        ? Icons.check_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextButton(
                    onPressed: _isFinishing ? null : _finish,
                    child: const Text('Sudah punya akun? Masuk'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
