import 'package:flutter/material.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_cards.dart';
import '../../../core/widgets/state_views.dart';
import '../../pawn/screens/application_detail_screen.dart';
import '../../transactions/screens/transaction_detail_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static const String routeName = '/notifications';

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final items = appState.notifications;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: SafeArea(
        child: items.isEmpty
            ? const EmptyState(
                icon: Icons.notifications_off_outlined,
                title: 'Belum Ada Notifikasi',
                subtitle:
                    'Pemberitahuan perubahan status pengajuan dan transaksi akan muncul di sini.',
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.md,
                ),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm + 4),
                itemBuilder: (context, index) {
                  final notif = items[index];
                  return AppCard(
                    backgroundColor: notif.isRead
                        ? AppColors.surface
                        : AppColors.primarySoft,
                    borderColor: notif.isRead
                        ? AppColors.border
                        : AppColors.primary.withValues(alpha: 0.25),
                    onTap: () async {
                      await appState.markNotificationRead(notif.id);
                      if (!context.mounted) return;
                      if (notif.applicationId != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ApplicationDetailScreen(
                              applicationId: notif.applicationId!,
                            ),
                          ),
                        );
                      } else if (notif.transactionId != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => TransactionDetailScreen(
                              transactionId: notif.transactionId!,
                            ),
                          ),
                        );
                      }
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: notif.isRead
                                ? AppColors.background
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.notifications_outlined,
                            size: 20,
                            color: notif.isRead
                                ? AppColors.textSecondary
                                : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notif.title,
                                      style: AppTextStyles.cardTitle,
                                    ),
                                  ),
                                  if (!notif.isRead)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.accentGold,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(notif.body, style: AppTextStyles.bodySecondary),
                              const SizedBox(height: 6),
                              Text(
                                AppFormatters.formatDateTime(notif.createdAt),
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
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
