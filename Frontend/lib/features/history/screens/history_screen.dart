import 'package:flutter/material.dart';
import '../../../core/models/gadaikan_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/transaction_list_tile.dart';
import '../../pawn/screens/application_detail_screen.dart';
import '../../transactions/screens/transaction_detail_screen.dart';

enum _HistoryFilter { all, applications, active, completed }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.onStartNewApplication,
  });

  final VoidCallback onStartNewApplication;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _HistoryFilter _filter = _HistoryFilter.all;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final entries = <_HistoryEntry>[];

    if (_filter == _HistoryFilter.all || _filter == _HistoryFilter.applications) {
      for (final app in appState.applications) {
        entries.add(
          _HistoryEntry(
            code: app.code,
            title: app.itemTitle,
            categoryLabel: app.category.label,
            categoryIcon: app.category.icon,
            date: app.updatedAt,
            statusLabel: app.status.label,
            statusTone: app.status.tone,
            amountLabel: app.assessment != null
                ? AppFormatters.formatRupiah(app.assessment!.approvedPrincipal)
                : null,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      ApplicationDetailScreen(applicationId: app.id),
                ),
              );
            },
          ),
        );
      }
    }

    for (final trx in appState.transactions) {
      final isActive = trx.status == TransactionStatus.active ||
          trx.status == TransactionStatus.paymentPending ||
          trx.status == TransactionStatus.overdue;
      final isDone = trx.status == TransactionStatus.paidOff ||
          trx.status == TransactionStatus.closed;

      final include = switch (_filter) {
        _HistoryFilter.all => true,
        _HistoryFilter.applications => false,
        _HistoryFilter.active => isActive,
        _HistoryFilter.completed => isDone,
      };

      if (include) {
        entries.add(
          _HistoryEntry(
            code: trx.code,
            title: trx.itemTitle,
            categoryLabel: trx.category.label,
            categoryIcon: trx.category.icon,
            date: trx.startDate,
            statusLabel: trx.status.label,
            statusTone: trx.status.tone,
            amountLabel: AppFormatters.formatRupiah(trx.principalAmount),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      TransactionDetailScreen(transactionId: trx.id),
                ),
              );
            },
          ),
        );
      }
    }

    entries.sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: appState.refreshAllData,
          color: AppColors.primary,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.sm + 4,
                ),
                child: Row(
                  children: [
                    _Chip(
                      label: 'Semua',
                      selected: _filter == _HistoryFilter.all,
                      onTap: () => setState(() => _filter = _HistoryFilter.all),
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      label: 'Pengajuan',
                      selected: _filter == _HistoryFilter.applications,
                      onTap: () => setState(
                          () => _filter = _HistoryFilter.applications),
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      label: 'Aktif',
                      selected: _filter == _HistoryFilter.active,
                      onTap: () =>
                          setState(() => _filter = _HistoryFilter.active),
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      label: 'Selesai',
                      selected: _filter == _HistoryFilter.completed,
                      onTap: () =>
                          setState(() => _filter = _HistoryFilter.completed),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: entries.isEmpty
                    ? EmptyState(
                        icon: Icons.history_toggle_off_rounded,
                        title: 'Belum Ada Riwayat',
                        subtitle:
                            'Riwayat pengajuan dan transaksi gadai Anda akan muncul di sini.',
                        actionLabel: 'Buat Pengajuan',
                        onAction: widget.onStartNewApplication,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                          vertical: AppSpacing.sm,
                        ),
                        itemCount: entries.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm + 4),
                        itemBuilder: (context, index) {
                          final item = entries[index];
                          return TransactionListTile(
                            code: item.code,
                            title: item.title,
                            categoryLabel: item.categoryLabel,
                            categoryIcon: item.categoryIcon,
                            dateLabel: AppFormatters.formatDate(item.date),
                            statusLabel: item.statusLabel,
                            statusTone: item.statusTone,
                            amountLabel: item.amountLabel,
                            onTap: item.onTap,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

class _HistoryEntry {
  const _HistoryEntry({
    required this.code,
    required this.title,
    required this.categoryLabel,
    required this.categoryIcon,
    required this.date,
    required this.statusLabel,
    required this.statusTone,
    required this.onTap,
    this.amountLabel,
  });

  final String code;
  final String title;
  final String categoryLabel;
  final IconData categoryIcon;
  final DateTime date;
  final String statusLabel;
  final StatusTone statusTone;
  final VoidCallback onTap;
  final String? amountLabel;
}
