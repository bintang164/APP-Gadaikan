import 'package:flutter/material.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_cards.dart';
import '../../../core/widgets/state_views.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  static const String routeName = '/faq';

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppStateScope.of(context).loadFaqs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppStateScope.of(context);
    final faqs = state.faqs;
    final bool hasDemoContent = faqs.any((faq) => faq.isDemo);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Bantuan & FAQ'),
        actions: [
          IconButton(
            onPressed: state.loadFaqs,
            tooltip: 'Muat ulang FAQ',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoadingFaqs && faqs.isEmpty
            ? const LoadingView(message: 'Memuat bantuan...')
            : state.faqError != null && faqs.isEmpty
                ? ErrorState(
                    message: state.faqError!,
                    onRetry: state.loadFaqs,
                  )
                : ListView(
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
                              'Pusat bantuan demo ini menyediakan jawaban umum. '
                              'Untuk kasus tertentu, silakan hubungi outlet '
                              'atau kanal bantuan resmi setelah backend tersedia.',
                              style: AppTextStyles.bodySecondary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (hasDemoContent)
                        const Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Text(
                            'Konten demo — bukan informasi layanan resmi.',
                            style: AppTextStyles.caption,
                          ),
                        ),
                      const Text(
                        'Pertanyaan Umum',
                        style: AppTextStyles.sectionHeading,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (faqs.isEmpty)
                        const AppCard(
                          child: Text(
                            'Belum ada FAQ dari backend. Konten demo akan '
                            'ditampilkan bila tersedia.',
                            style: AppTextStyles.bodySecondary,
                          ),
                        ),
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
                              if (faq.isDemo)
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    'Jawaban demo',
                                    style: AppTextStyles.caption,
                                  ),
                                ),
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
