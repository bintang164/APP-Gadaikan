import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../core/models/gadaikan_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_cards.dart';
import '../../../core/widgets/state_views.dart';
import '../../pawn/screens/application_detail_screen.dart';
import '../../transactions/screens/transaction_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  static const String routeName = '/notifications';

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _initialized = false;
  bool _markingAll = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppStateScope.of(context).loadNotifications();
    });
  }

  Future<void> _markAll(AppState state) async {
    if (_markingAll) return;
    setState(() => _markingAll = true);
    await state.markAllNotificationsRead();
    if (mounted) setState(() => _markingAll = false);
  }

  Future<void> _openNotification(
    AppState state,
    AppNotification notification,
  ) async {
    await state.markNotificationRead(notification.id);
    if (!mounted) return;
    if (notification.applicationId != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ApplicationDetailScreen(
            applicationId: notification.applicationId!,
          ),
        ),
      );
    } else if (notification.transactionId != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TransactionDetailScreen(
            transactionId: notification.transactionId!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppStateScope.of(context);
    final List<AppNotification> sorted = List<AppNotification>.from(
      state.notifications.where(
        (AppNotification notification) =>
            AppConfig.remindersEnabled ||
            notification.type != NotificationType.dueReminder,
      ),
    )..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final bool hasUnread = sorted.any((AppNotification n) => !n.isRead);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: _markingAll ? null : () => _markAll(state),
              child: _markingAll
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Tandai semua dibaca'),
            ),
        ],
      ),
      body: SafeArea(
        child: state.isLoadingNotifications && sorted.isEmpty
            ? const LoadingView(message: 'Memuat notifikasi...')
            : state.notificationsError != null && sorted.isEmpty
                ? ErrorState(
                    message: state.notificationsError!,
                    onRetry: state.loadNotifications,
                  )
                : sorted.isEmpty
                    ? const EmptyState(
                        icon: Icons.notifications_off_outlined,
                        title: 'Belum Ada Notifikasi',
                        subtitle:
                            'Pemberitahuan status pengajuan, penawaran, dan catatan pembayaran demo akan muncul di sini.',
                      )
                    : RefreshIndicator(
                        onRefresh: state.loadNotifications,
                        color: AppColors.primary,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.screenHorizontal,
                            vertical: AppSpacing.md,
                          ),
                          itemCount: sorted.length + 1,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.sm + 4),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return const Padding(
                                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                                child: Text(
                                  'Notifikasi dalam aplikasi dari backend. Tidak ada push notification sungguhan.',
                                  style: AppTextStyles.caption,
                                ),
                              );
                            }
                            final AppNotification notification = sorted[index - 1];
                            return AppCard(
                              backgroundColor: notification.isRead
                                  ? AppColors.surface
                                  : AppColors.primarySoft,
                              borderColor: notification.isRead
                                  ? AppColors.border
                                  : AppColors.primary.withValues(alpha: 0.25),
                              onTap: () =>
                                  _openNotification(state, notification),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: notification.isRead
                                          ? AppColors.background
                                          : AppColors.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      notification.type.icon,
                                      size: 20,
                                      color: notification.isRead
                                          ? AppColors.textSecondary
                                          : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                notification.title,
                                                style: AppTextStyles.cardTitle,
                                              ),
                                            ),
                                            if (!notification.isRead)
                                              const Icon(
                                                Icons.circle,
                                                size: 8,
                                                color: AppColors.accentGold,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          notification.type.label,
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notification.body,
                                          style: AppTextStyles.bodySecondary,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          AppFormatters.formatDateTime(
                                            notification.createdAt,
                                          ),
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
      ),
    );
  }
}
