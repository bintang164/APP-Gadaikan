import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/app_card.dart';
import '../../../app/widgets/empty_state.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const List<String> _filters = [
    'Semua',
    'Pengajuan',
    'Aktif',
    'Selesai',
  ];

  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: const Key('history_screen'),
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
            Text('Riwayat', style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Pengajuan dan transaksi gadai sebelumnya.',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final bool selected = index == _selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: ChoiceChip(
                      label: Text(_filters[index]),
                      selected: selected,
                      onSelected: (_) {
                        setState(() => _selectedFilter = index);
                      },
                      selectedColor: AppColors.primarySoft,
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                      labelStyle: AppTextStyles.labelMedium.copyWith(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              child: EmptyState(
                icon: Icons.history_rounded,
                title: 'Riwayat masih kosong',
                description:
                    'Pengajuan yang sudah dibuat akan muncul di sini beserta statusnya.',
                actionLabel: 'Buat Pengajuan',
                onAction: () => context.go(AppRoutes.applications),
                padding: const EdgeInsets.all(AppSpacing.lg),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
