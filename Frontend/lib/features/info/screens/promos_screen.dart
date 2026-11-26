import 'package:flutter/material.dart';
import '../../../core/models/gadaikan_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_cards.dart';
import '../../../core/widgets/state_views.dart';

class PromosScreen extends StatefulWidget {
  const PromosScreen({super.key});

  static const String routeName = '/promos';

  @override
  State<PromosScreen> createState() => _PromosScreenState();
}

class _PromosScreenState extends State<PromosScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppStateScope.of(context).loadInfoData();
    });
  }

  Future<void> _showDetail(PromoInfo promo) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(promo.title, style: AppTextStyles.sectionHeading),
                const SizedBox(height: 6),
                Text(
                  promo.period,
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(promo.summary, style: AppTextStyles.body),
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
                Text('Syarat & Ketentuan', style: AppTextStyles.cardTitle),
                const SizedBox(height: 6),
                Text(promo.terms, style: AppTextStyles.bodySecondary),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppStateScope.of(context);
    final List<PromoInfo> promos = state.promotions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi & Promo'),
        actions: [
          IconButton(
            onPressed: state.loadInfoData,
            tooltip: 'Muat ulang promo',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoadingInfo && promos.isEmpty
            ? const LoadingView(message: 'Memuat informasi...')
            : state.infoError != null && promos.isEmpty
                ? ErrorState(
                    message: state.infoError!,
                    onRetry: state.loadInfoData,
                  )
                : promos.isEmpty
                    ? const EmptyState(
                        icon: Icons.local_offer_outlined,
                        title: 'Belum Ada Informasi',
                        subtitle:
                            'Promo dan pengumuman dari admin backend akan muncul di sini. '
                            'Tidak ada promo resmi fiktif yang dibuat aplikasi.',
                      )
                    : RefreshIndicator(
                        onRefresh: state.loadInfoData,
                        color: AppColors.primary,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenHorizontal,
                            vertical: AppSpacing.md,
                          ),
                          itemCount: promos.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final PromoInfo promo = promos[index];
                            return AppCard(
                              onTap: () => _showDetail(promo),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.primaryDark,
                                          AppColors.primary,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentGold
                                                .withValues(alpha: 0.22),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            promo.badgeText,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.accentGold,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        if (promo.isDemo)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withValues(alpha: 0.18),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'DEMO',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    promo.title,
                                    style: AppTextStyles.sectionHeading,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    promo.period,
                                    style: AppTextStyles.caption,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(promo.summary, style: AppTextStyles.body),
                                  const SizedBox(height: AppSpacing.sm),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Syarat & Ketentuan: ${promo.terms}',
                                    style: AppTextStyles.caption,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}
