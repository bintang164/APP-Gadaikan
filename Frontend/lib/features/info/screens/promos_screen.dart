import 'package:flutter/material.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_cards.dart';
import '../../../core/widgets/state_views.dart';

class PromosScreen extends StatelessWidget {
  const PromosScreen({super.key});

  static const String routeName = '/promos';

  @override
  Widget build(BuildContext context) {
    final promos = AppStateScope.of(context).promotions;

    return Scaffold(
      appBar: AppBar(title: const Text('Informasi & Promo')),
      body: SafeArea(
        child: promos.isEmpty
            ? const EmptyState(
                icon: Icons.local_offer_outlined,
                title: 'Belum Ada Promo',
                subtitle: 'Nantikan informasi promo terbaru dari Gadaikan.',
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.md,
                ),
                itemCount: promos.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final promo = promos[index];
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.accentGoldSoft,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                promo.badgeText,
                                style: AppTextStyles.captionBold.copyWith(
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                            Text(
                              promo.period,
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(promo.title, style: AppTextStyles.sectionHeading),
                        const SizedBox(height: 6),
                        Text(promo.summary, style: AppTextStyles.body),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          'Syarat & Ketentuan:',
                          style: AppTextStyles.captionBold,
                        ),
                        const SizedBox(height: 4),
                        Text(promo.terms, style: AppTextStyles.caption),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
