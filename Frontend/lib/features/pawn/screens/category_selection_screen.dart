import 'package:flutter/material.dart';
import '../../../core/models/gadaikan_models.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_cards.dart';
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

  void _continueToForm() {
    final category = _selected;
    if (category == null) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PawnSubmissionFlowScreen(initialCategory: category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Kategori Gadai')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mau gadai apa hari ini?',
                style: AppTextStyles.pageHeading,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Pilih salah satu kategori barang agar formulir dan dokumen sesuai kebutuhan.',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView.separated(
                  itemCount: PawnCategory.values.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final category = PawnCategory.values[index];
                    return ServiceCategoryCard(
                      title: category.label,
                      subtitle: category.shortSubtitle,
                      icon: category.icon,
                      selected: _selected == category,
                      onTap: () => setState(() => _selected = category),
                    );
                  },
                ),
              ),
              PrimaryButton(
                label: 'Lanjutkan ke Formulir',
                onPressed: _selected == null ? null : _continueToForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
