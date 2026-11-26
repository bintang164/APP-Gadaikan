import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_card.dart';
import '../../../app/widgets/empty_state.dart';

class PawnScreen extends StatelessWidget {
  const PawnScreen({super.key});

  Future<void> _showCategorySheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.horizontal,
              0,
              AppSpacing.horizontal,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mau gadai apa hari ini?',
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Pilih kategori untuk memulai pengajuan.',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                _CategoryTile(
                  icon: Icons.smartphone_rounded,
                  title: 'Elektronik',
                  subtitle: 'Ponsel, laptop, kamera, dan gadget.',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showComingSoon(context, 'Elektronik');
                  },
                ),
                _CategoryTile(
                  icon: Icons.diamond_outlined,
                  title: 'Emas',
                  subtitle: 'Perhiasan dan logam mulia.',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showComingSoon(context, 'Emas');
                  },
                ),
                _CategoryTile(
                  icon: Icons.directions_car_outlined,
                  title: 'BPKB',
                  subtitle: 'Kendaraan bermotor dengan dokumen lengkap.',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _showComingSoon(context, 'BPKB');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showComingSoon(BuildContext context, String category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Form pengajuan $category akan tersedia pada tahap berikutnya.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const Key('pawn_screen'),
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
            Text('Pengajuan', style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Buat dan pantau pengajuan gadai kamu.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              child: EmptyState(
                icon: Icons.assignment_add,
                title: 'Belum ada pengajuan',
                description:
                    'Pilih kategori barang untuk memulai pengajuan gadai pertama.',
                actionLabel: 'Pilih Kategori',
                onAction: () => _showCategorySheet(context),
                padding: const EdgeInsets.all(AppSpacing.lg),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Tips pengajuan',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            const _TipRow(
              icon: Icons.photo_camera_outlined,
              text: 'Siapkan foto barang dari beberapa sisi.',
            ),
            const SizedBox(height: AppSpacing.xs),
            const _TipRow(
              icon: Icons.description_outlined,
              text: 'Siapkan dokumen pendukung sesuai kategori.',
            ),
            const SizedBox(height: AppSpacing.xs),
            const _TipRow(
              icon: Icons.verified_user_outlined,
              text: 'Data dan dokumen hanya dipakai untuk verifikasi.',
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: AppCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.titleMedium),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSizes.iconSm, color: AppColors.primary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(text, style: AppTextStyles.bodySmall),
        ),
      ],
    );
  }
}
