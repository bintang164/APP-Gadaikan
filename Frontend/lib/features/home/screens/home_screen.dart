import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_card.dart';
import '../../../app/widgets/empty_state.dart';
import '../../../app/widgets/primary_button.dart';
import '../../../app/widgets/section_header.dart';
import '../../../app/widgets/service_category_card.dart';
import '../../../core/providers/session_providers.dart';
import '../../../core/state/session_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SessionController session = ref.watch(sessionControllerProvider);

    return SafeArea(
      key: const Key('home_screen'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.horizontal,
          AppSpacing.md,
          AppSpacing.horizontal,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HomeHeader(
              name: session.displayName,
              onProfileTap: () => context.go(AppRoutes.profile),
              onNotificationTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Belum ada notifikasi baru.'),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            _HeroCard(
              onApply: () => context.go(AppRoutes.applications),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(
              title: 'Pilih Layanan',
              subtitle: 'Tiga kategori gadai yang tersedia.',
            ),
            _ServiceGrid(
              onSelected: (_) => context.go(AppRoutes.applications),
            ),
            const SizedBox(height: AppSpacing.xl),
            _SimulationCard(
              onTap: () => context.go(AppRoutes.applications),
            ),
            const SizedBox(height: AppSpacing.xl),
            SectionHeader(
              title: 'Pengajuan Terakhir',
              actionLabel: 'Lihat semua',
              onAction: () => context.go(AppRoutes.history),
            ),
            AppCard(
              child: EmptyState(
                compact: true,
                icon: Icons.assignment_outlined,
                title: 'Belum ada pengajuan',
                description:
                    'Mulai pengajuan pertamamu dan pantau prosesnya di sini.',
                actionLabel: 'Buat Pengajuan',
                onAction: () => context.go(AppRoutes.applications),
                padding: const EdgeInsets.all(AppSpacing.md),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _DemoNotice(),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final String name;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;

  const _HomeHeader({
    required this.name,
    required this.onProfileTap,
    required this.onNotificationTap,
  });

  String get _initials {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'G';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, $name',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Mau gadai apa hari ini?',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onNotificationTap,
          tooltip: 'Notifikasi',
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        const SizedBox(width: AppSpacing.xxs),
        InkWell(
          onTap: onProfileTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: AppSizes.avatarMd,
            height: AppSizes.avatarMd,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initials,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final VoidCallback onApply;

  const _HeroCard({required this.onApply});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.navyGradient,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -36,
            right: -24,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    'GADAI CEPAT & MUDAH',
                    style: AppTextStyles.overline.copyWith(
                      color: AppColors.gold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Butuh dana tanpa\nkehilangan barang?',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textOnPrimary,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Ajukan gadai elektronik, emas, atau BPKB dalam satu aplikasi.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Ajukan Gadai',
                  onPressed: onApply,
                  isFullWidth: false,
                  icon: Icons.add_rounded,
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.primaryDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const _ServiceGrid({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth =
            (constraints.maxWidth - (AppSpacing.sm * 2)) / 3;

        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            SizedBox(
              width: itemWidth,
              child: ServiceCategoryCard(
                compact: true,
                icon: Icons.smartphone_rounded,
                title: 'Elektronik',
                description: 'Ponsel, laptop, dan gadget.',
                onTap: () => onSelected('elektronik'),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: ServiceCategoryCard(
                compact: true,
                icon: Icons.diamond_outlined,
                title: 'Emas',
                description: 'Perhiasan dan logam mulia.',
                accentColor: AppColors.goldDark,
                onTap: () => onSelected('emas'),
              ),
            ),
            SizedBox(
              width: itemWidth,
              child: ServiceCategoryCard(
                compact: true,
                icon: Icons.directions_car_outlined,
                title: 'BPKB',
                description: 'Kendaraan bermotor.',
                accentColor: AppColors.info,
                onTap: () => onSelected('bpkb'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SimulationCard extends StatelessWidget {
  final VoidCallback onTap;

  const _SimulationCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.goldSoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.calculate_outlined,
              color: AppColors.goldDark,
              size: 26,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Simulasi Gadai',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Perkirakan plafon sebelum mengajukan.',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _DemoNotice extends StatelessWidget {
  const _DemoNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.science_outlined,
            size: 18,
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Prototipe akademik. Nilai taksiran, pinjaman, dan status '
              'merupakan simulasi, bukan penawaran resmi.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
