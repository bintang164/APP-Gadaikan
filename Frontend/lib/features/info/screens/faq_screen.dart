import 'package:flutter/material.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_cards.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const String routeName = '/faq';

  @override
  Widget build(BuildContext context) {
    final faqs = AppStateScope.of(context).faqs;

    return Scaffold(
      appBar: AppBar(title: const Text('Pusat Bantuan & FAQ')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.md,
          ),
          children: [
            AppCard(
              backgroundColor: AppColors.primarySoft,
              borderColor: AppColors.primary.withValues(alpha: 0.2),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Butuh Bantuan Lebih Lanjut?',
                    style: AppTextStyles.sectionHeading,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Hubungi layanan bantuan demo kami di support@gadaikan.id atau (021) 555-0100.',
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Pertanyaan Umum',
              style: AppTextStyles.sectionHeading,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final faq in faqs) ...[
              AppCard(
                padding: EdgeInsets.zero,
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 4,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  title: Text(
                    faq.question,
                    style: AppTextStyles.cardTitle,
                  ),
                  children: [
                    Text(
                      faq.answer,
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm + 4),
            ],
          ],
        ),
      ),
    );
  }
}
