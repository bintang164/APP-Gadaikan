import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_card.dart';
import '../../../app/widgets/secondary_button.dart';
import '../../../app/widgets/status_badge.dart';
import '../../../core/config/app_config.dart';
import '../../../core/providers/session_providers.dart';
import '../../../core/state/session_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(child: Text(message)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmLogout(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Keluar dari akun?'),
          content: const Text(
            'Kamu perlu masuk kembali untuk melihat pengajuan dan riwayat.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Keluar',
                style: TextStyle(color: AppColors.danger),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ref.read(sessionControllerProvider).logout();
    if (!context.mounted) return;
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SessionController session = ref.watch(sessionControllerProvider);

    return SafeArea(
      key: const Key('profile_screen'),
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
            Text('Profil', style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Kelola data akun dan pengaturan aplikasi.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: Row(
                children: [
                  Container(
                    width: AppSizes.avatarLg,
                    height: AppSizes.avatarLg,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 34,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          session.userPhone ?? 'Belum ada nomor HP',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        const StatusBadge.warning(
                          label: 'Mode demo',
                          dense: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.edit_outlined,
                    title: 'Edit profil',
                    subtitle: 'Nama, nomor HP, dan email',
                    onTap: () => _showInfoDialog(
                      context,
                      title: 'Edit profil',
                      message:
                          'Edit profil akan tersedia setelah backend Laravel '
                          'terhubung. Data akun saat ini masih tersimpan lokal.',
                    ),
                  ),
                  const Divider(),
                  _MenuTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Bantuan & FAQ',
                    subtitle: 'Pertanyaan umum dan kontak bantuan',
                    onTap: () => _showInfoDialog(
                      context,
                      title: 'Bantuan & FAQ',
                      message:
                          'Pusat bantuan akan tersedia pada tahap berikutnya. '
                          'Untuk prototipe ini, gunakan alur demo yang ada.',
                    ),
                  ),
                  const Divider(),
                  _MenuTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Kebijakan privasi',
                    subtitle: 'Cara data kamu digunakan',
                    onTap: () => _showInfoDialog(
                      context,
                      title: 'Kebijakan privasi',
                      message:
                          'Gadaikan adalah prototipe akademik. Data demo hanya '
                          'disimpan di perangkat. Jangan memasukkan data '
                          'identitas atau dokumen asli.',
                    ),
                  ),
                  const Divider(),
                  _MenuTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang aplikasi',
                    subtitle: 'Versi ${AppConfig.appVersion}',
                    onTap: () => _showInfoDialog(
                      context,
                      title: 'Tentang Gadaikan',
                      message:
                          '${AppConfig.appName} — ${AppConfig.tagline}.\n\n'
                          'Prototipe akademik untuk pengajuan gadai digital. '
                          'Tidak terhubung ke lembaga gadai atau layanan '
                          'pembayaran resmi.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SecondaryButton(
              label: 'Keluar',
              onPressed: () => _confirmLogout(context, ref),
              isFullWidth: true,
              icon: Icons.logout_rounded,
              foregroundColor: AppColors.danger,
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Text(
                'Gadaikan v${AppConfig.appVersion} · ${AppConfig.environment}',
                style: AppTextStyles.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.titleSmall),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textSecondary,
      ),
    );
  }
}
