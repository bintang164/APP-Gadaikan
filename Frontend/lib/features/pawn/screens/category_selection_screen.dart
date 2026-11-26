import 'package:flutter/material.dart';
import '../../../core/models/gadaikan_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/storage/pawn_draft_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_cards.dart';
import '../../../core/widgets/state_views.dart';
import 'pawn_submission_flow_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  static const String routeName = '/pawn/categories';

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  PawnCategory? _selected;
  bool _isContinuing = false;

  List<PawnCategoryInfo> get _categories =>
      AppStateScope.of(context).categories;

  Future<void> _continueToForm() async {
    final PawnCategory? category = _selected;
    if (category == null || _isContinuing) return;

    setState(() => _isContinuing = true);
    try {
      final PawnDraftStore store = PawnDraftStore();
      final PawnDraft? existing = await store.read();
      await store.write(
        PawnDraft(
          categoryId: category.apiId,
          data: existing?.data ?? const <String, dynamic>{},
        ),
      );
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PawnSubmissionFlowScreen(initialCategory: category),
        ),
      );
    } finally {
      if (mounted) setState(() => _isContinuing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState appState = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Kategori Gadai'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Kembali',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mau gadai apa hari ini?',
                  style: AppTextStyles.pageHeading),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Pilih salah satu kategori barang agar formulir dan dokumen sesuai kebutuhan.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              if (appState.isLoadingData && _categories.isEmpty)
                const Expanded(
                  child: LoadingView(message: 'Memuat kategori...'),
                )
              else if (_categories.isEmpty)
                Expanded(
                  child: ErrorState(
                    message: appState.dataError ??
                        'Kategori belum tersedia. Periksa koneksi lalu coba lagi.',
                    onRetry: appState.refreshAllData,
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    children: [
                      for (final PawnCategoryInfo category in _categories) ...[
                        ServiceCategoryCard(
                          title: category.name,
                          subtitle: category.description,
                          icon: category.category.icon,
                          selected: _selected == category.category,
                          onTap: () => setState(
                            () => _selected = category.category,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      if (_selected != null)
                        _RequirementsCard(category: _selected!),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              const _VerificationNotice(),
              const SizedBox(height: AppSpacing.sm),
              PrimaryButton(
                label: 'Lanjut',
                isLoading: _isContinuing,
                onPressed: (_selected == null || _isContinuing)
                    ? null
                    : _continueToForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequirementsCard extends StatelessWidget {
  const _RequirementsCard({required this.category});

  final PawnCategory category;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      backgroundColor: AppColors.primarySoft,
      borderColor: AppColors.primary.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Persyaratan ${category.label}',
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final String requirement in category.requirements) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(requirement, style: AppTextStyles.body),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _VerificationNotice extends StatelessWidget {
  const _VerificationNotice();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Icon(Icons.info_outline_rounded,
            size: 16, color: AppColors.textSecondary),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Pengajuan tetap memerlukan pemeriksaan data dan persetujuan '
            'petugas. Pilihan kategori tidak menjamin persetujuan.',
            style: AppTextStyles.caption,
          ),
        ),
      ],
    );
  }
}
