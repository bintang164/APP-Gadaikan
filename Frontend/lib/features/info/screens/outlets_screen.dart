import 'package:flutter/material.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_cards.dart';
import '../../../core/widgets/state_views.dart';

class OutletsScreen extends StatelessWidget {
  const OutletsScreen({super.key});

  static const String routeName = '/outlets';

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final outlets = appState.outlets;

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Outlet')),
      body: SafeArea(
        child: outlets.isEmpty
            ? const EmptyState(
                icon: Icons.storefront_outlined,
                title: 'Belum Ada Data Outlet',
                subtitle: 'Informasi lokasi cabang belum tersedia saat ini.',
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.md,
                ),
                itemCount: outlets.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final outlet = outlets[index];
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primarySoft,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    outlet.name,
                                    style: AppTextStyles.cardTitle,
                                  ),
                                  Text(
                                    outlet.city,
                                    style: AppTextStyles.captionBold.copyWith(
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 10),
                        _OutletDetailRow(
                          icon: Icons.place_outlined,
                          text: outlet.address,
                        ),
                        const SizedBox(height: 6),
                        _OutletDetailRow(
                          icon: Icons.schedule_outlined,
                          text: outlet.hours,
                        ),
                        const SizedBox(height: 6),
                        _OutletDetailRow(
                          icon: Icons.phone_outlined,
                          text: outlet.phone,
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _OutletDetailRow extends StatelessWidget {
  const _OutletDetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: AppTextStyles.bodySecondary),
        ),
      ],
    );
  }
}
