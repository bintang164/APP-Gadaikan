import 'package:flutter/material.dart';
import '../../../core/models/gadaikan_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_cards.dart';
import '../../../core/widgets/state_views.dart';

class OutletsScreen extends StatefulWidget {
  const OutletsScreen({super.key});

  static const String routeName = '/outlets';

  @override
  State<OutletsScreen> createState() => _OutletsScreenState();
}

class _OutletsScreenState extends State<OutletsScreen> {
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

  @override
  Widget build(BuildContext context) {
    final AppState state = AppStateScope.of(context);
    final List<OutletInfo> outlets = state.outlets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Outlet'),
        actions: [
          IconButton(
            onPressed: state.loadInfoData,
            tooltip: 'Muat ulang outlet',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoadingInfo && outlets.isEmpty
            ? const LoadingView(message: 'Memuat daftar outlet...')
            : state.infoError != null && outlets.isEmpty
                ? ErrorState(
                    message: state.infoError!,
                    onRetry: state.loadInfoData,
                  )
                : outlets.isEmpty
                    ? const EmptyState(
                        icon: Icons.storefront_outlined,
                        title: 'Belum Ada Data Outlet',
                        subtitle:
                            'Informasi cabang belum tersedia dari backend/admin. '
                            'Tidak ada alamat outlet nyata yang dibuat oleh aplikasi.',
                      )
                    : RefreshIndicator(
                        onRefresh: state.loadInfoData,
                        color: AppColors.primary,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenHorizontal,
                            vertical: AppSpacing.md,
                          ),
                          itemCount: outlets.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, index) {
                            final OutletInfo outlet = outlets[index];
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.location_on_outlined,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              outlet.name,
                                              style: AppTextStyles.cardTitle,
                                            ),
                                            Text(
                                              outlet.city,
                                              style: AppTextStyles.captionBold
                                                  .copyWith(
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (outlet.isDemo)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.warningSoft,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'DEMO',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.warning,
                                            ),
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
                                    text: outlet.phone.isEmpty
                                        ? 'Kontak tidak tersedia'
                                        : outlet.phone,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    // Tombol peta sengaja tidak ditampilkan:
                                    // belum ada integrasi peta yang sah.
                                    'Peta belum tersedia pada versi ini.',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
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
