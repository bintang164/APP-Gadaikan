import 'package:flutter/material.dart';
import '../../../core/models/gadaikan_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_cards.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/transaction_list_tile.dart';
import '../../info/screens/notifications_screen.dart';
import '../../info/screens/outlets_screen.dart';
import '../../info/screens/promos_screen.dart';
import '../../pawn/screens/application_detail_screen.dart';
import '../../pawn/screens/category_selection_screen.dart';
import '../../pawn/screens/pawn_submission_flow_screen.dart';
import '../../simulation/screens/simulation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onNavigateTab,
  });

  final ValueChanged<int> onNavigateTab;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final user = appState.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: appState.refreshAllData,
          color: AppColors.primary,
          child: _buildBody(context, appState, user),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppState appState,
    UserProfile? user,
  ) {
    if (appState.isLoadingData && appState.applications.isEmpty) {
      return const LoadingView(message: 'Memuat beranda Gadaikan...');
    }

    if (appState.dataError != null && appState.applications.isEmpty) {
      return ErrorState(
        message: appState.dataError!,
        onRetry: appState.refreshAllData,
      );
    }

    final latestApplication =
        appState.applications.isNotEmpty ? appState.applications.first : null;
    final latestPromo =
        appState.promotions.isNotEmpty ? appState.promotions.first : null;

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      children: [
        _HomeHeader(
          userName: user?.name ?? 'Nasabah',
          unreadCount: appState.unreadNotificationCount,
          onTapNotifications: () {
            Navigator.of(context).pushNamed(NotificationsScreen.routeName);
          },
          onTapProfile: () => onNavigateTab(3),
        ),
        const SizedBox(height: AppSpacing.lg),
        _HeroCard(
          onStartPawn: () {
            Navigator.of(context).pushNamed(CategorySelectionScreen.routeName);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        const SectionHeader(title: 'Pilih Layanan'),
        const SizedBox(height: AppSpacing.sm + 4),
        Row(
          children: [
            Expanded(
              child: ServiceCategoryCard(
                title: 'Elektronik',
                subtitle: 'HP & Laptop',
                icon: PawnCategory.elektronik.icon,
                compact: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PawnSubmissionFlowScreen(
                        initialCategory: PawnCategory.elektronik,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: ServiceCategoryCard(
                title: 'Emas',
                subtitle: 'Perhiasan',
                icon: PawnCategory.emas.icon,
                compact: true,
                accentColor: AppColors.accentGoldSoft,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PawnSubmissionFlowScreen(
                        initialCategory: PawnCategory.emas,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: ServiceCategoryCard(
                title: 'BPKB',
                subtitle: 'Motor & Mobil',
                icon: PawnCategory.bpkb.icon,
                compact: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PawnSubmissionFlowScreen(
                        initialCategory: PawnCategory.bpkb,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SimulationBannerCard(
          onTap: () {
            Navigator.of(context).pushNamed(SimulationScreen.routeName);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(
          title: 'Pengajuan Terakhir',
          actionLabel: 'Lihat Semua',
          onAction: () => onNavigateTab(1),
        ),
        const SizedBox(height: AppSpacing.sm + 4),
        if (latestApplication == null)
          AppCard(
            child: Column(
              children: [
                const Text(
                  'Belum ada pengajuan aktif',
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Mulai ajukan gadai pertama Anda melalui tombol di atas.',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          TransactionListTile(
            code: latestApplication.code,
            title: latestApplication.itemTitle,
            categoryLabel: latestApplication.category.label,
            categoryIcon: latestApplication.category.icon,
            dateLabel: AppFormatters.formatDate(latestApplication.updatedAt),
            statusLabel: latestApplication.status.label,
            statusTone: latestApplication.status.tone,
            amountLabel: latestApplication.assessment != null
                ? AppFormatters.formatRupiah(
                    latestApplication.assessment!.approvedPrincipal,
                  )
                : null,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ApplicationDetailScreen(
                    applicationId: latestApplication.id,
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: AppSpacing.lg),
        SectionHeader(
          title: 'Informasi & Promo',
          actionLabel: 'Semua Promo',
          onAction: () {
            Navigator.of(context).pushNamed(PromosScreen.routeName);
          },
        ),
        const SizedBox(height: AppSpacing.sm + 4),
        if (latestPromo != null)
          AppCard(
            onTap: () {
              Navigator.of(context).pushNamed(PromosScreen.routeName);
            },
            backgroundColor: AppColors.primarySoft,
            borderColor: AppColors.primary.withValues(alpha: 0.18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accentGold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_offer_outlined,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latestPromo.title,
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        latestPromo.summary,
                        style: AppTextStyles.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          onTap: () {
            Navigator.of(context).pushNamed(OutletsScreen.routeName);
          },
          child: const Row(
            children: [
              Icon(Icons.storefront_outlined, color: AppColors.primary),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daftar Outlet Gadaikan', style: AppTextStyles.cardTitle),
                    SizedBox(height: 2),
                    Text(
                      'Lihat lokasi cabang dan jam operasional demo',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.userName,
    required this.unreadCount,
    required this.onTapNotifications,
    required this.onTapProfile,
  });

  final String userName;
  final int unreadCount;
  final VoidCallback onTapNotifications;
  final VoidCallback onTapProfile;

  @override
  Widget build(BuildContext context) {
    final initial = userName.trim().isNotEmpty
        ? userName.trim()[0].toUpperCase()
        : 'N';

    return Row(
      children: [
        InkWell(
          onTap: onTapProfile,
          borderRadius: BorderRadius.circular(24),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary,
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.accentGold,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Halo, selamat datang',
                style: AppTextStyles.caption,
              ),
              Text(
                userName,
                style: AppTextStyles.sectionHeading,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onTapNotifications,
          tooltip: 'Notifikasi',
          icon: Badge(
            isLabelVisible: unreadCount > 0,
            label: Text('$unreadCount'),
            backgroundColor: AppColors.danger,
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.textPrimary,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onStartPawn});

  final VoidCallback onStartPawn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg - 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Pengajuan Terarah & Transparan',
              style: TextStyle(
                color: AppColors.accentGold,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Gadai lebih mudah, langsung dari genggaman',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Pilih kategori, unggah foto dokumen, dan pantau penaksiran langsung dari ponsel Anda.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: onStartPawn,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGold,
                foregroundColor: AppColors.primaryDark,
                minimumSize: const Size(180, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                ),
              ),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
              label: const Text(
                'Ajukan Gadai',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SimulationBannerCard extends StatelessWidget {
  const _SimulationBannerCard({required this.onTap});

  final VoidCallback onTap;

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
              color: AppColors.accentGoldSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calculate_outlined,
              color: AppColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Simulasi Gadai', style: AppTextStyles.cardTitle),
                SizedBox(height: 2),
                Text(
                  'Hitung perkiraan plafon dan biaya sebelum mengajukan',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
