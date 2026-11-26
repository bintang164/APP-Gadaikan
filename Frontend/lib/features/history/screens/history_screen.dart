import 'package:flutter/material.dart';
import '../../../core/models/gadaikan_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/transaction_list_tile.dart';
import '../../pawn/screens/application_detail_screen.dart';
import '../../transactions/screens/transaction_detail_screen.dart';

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
  static const List<_Filter> _filters = <_Filter>[
    _Filter(key: 'all', label: 'Semua'),
    _Filter(key: 'applications', label: 'Pengajuan'),
    _Filter(key: 'active', label: 'Aktif'),
    _Filter(key: 'paid_off', label: 'Lunas'),
    _Filter(key: 'rejected', label: 'Ditolak / Dibatalkan'),
  ];

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppStateScope.of(context).loadHistoryPage(filter: 'all', page: 1);
    });
  }

  void _openDetail(HistoryItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => item.kind == HistoryKind.application
            ? ApplicationDetailScreen(applicationId: item.id)
            : TransactionDetailScreen(transactionId: item.id),
      ),
    );
  }

  Future<void> _refresh(AppState state) async {
    await state.loadHistoryPage(filter: state.historyFilter, page: 1);
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppStateScope.of(context);
    final PagedHistory? page = state.historyPage;
    final List<HistoryItem> items = page?.items ?? const <HistoryItem>[];
    final bool initialLoading = state.isLoadingHistory && page == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          IconButton(
            onPressed: () => _refresh(state),
            tooltip: 'Muat ulang riwayat',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          ),
        ],
      ),
      body: SafeArea(
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
                  for (final _Filter filter in _filters) ...[
                    ChoiceChip(
                      label: Text(filter.label),
                      selected: state.historyFilter == filter.key,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: state.historyFilter == filter.key
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      onSelected: (_) {
                        state.setHistoryFilter(filter.key);
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            if (page?.isDemo ?? false)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Mode demo: riwayat ini berasal dari data lokal, bukan server.',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.warning),
                  ),
                ),
              ),
            Expanded(
              child: initialLoading
                  ? const LoadingView(message: 'Memuat riwayat...')
                  : state.historyError != null
                      ? ErrorState(
                          message: state.historyError!,
                          onRetry: () => state.loadHistoryPage(page: 1),
                        )
                      : items.isEmpty && !state.isLoadingHistory
                          ? EmptyState(
                              icon: Icons.history_toggle_off_rounded,
                              title: 'Belum Ada Riwayat',
                              subtitle:
                                  'Riwayat pengajuan dan transaksi akun Anda akan muncul di sini.',
                              actionLabel: 'Buat Pengajuan',
                              onAction: widget.onStartNewApplication,
                            )
                          : RefreshIndicator(
                              onRefresh: () => _refresh(state),
                              color: AppColors.primary,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.screenHorizontal,
                                  vertical: AppSpacing.sm,
                                ),
                                itemCount: items.length + 1,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: AppSpacing.sm + 4),
                                itemBuilder: (context, index) {
                                  if (index == items.length) {
                                    return _buildFooter(state, page!);
                                  }
                                  final HistoryItem item = items[index];
                                  return TransactionListTile(
                                    code: item.code,
                                    title: item.title,
                                    categoryLabel: item.category.label,
                                    categoryIcon: item.category.icon,
                                    dateLabel:
                                        AppFormatters.formatDate(item.date),
                                    statusLabel: item.statusLabel,
                                    statusTone: item.statusTone,
                                    amountLabel: item.amountLabel,
                                    onTap: () => _openDetail(item),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(AppState state, PagedHistory page) {
    if (!page.hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: Text(
            'Menampilkan ${page.items.length} dari ${page.total} riwayat',
            style: AppTextStyles.caption,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Center(
        child: SizedBox(
          width: 220,
          child: SecondaryButton(
            label: state.isLoadingHistory ? 'Memuat...' : 'Muat Lebih Banyak',
            isLoading: state.isLoadingHistory,
            onPressed: state.isLoadingHistory ? null : state.loadMoreHistory,
          ),
        ),
      ),
    );
  }
}

class _Filter {
  const _Filter({required this.key, required this.label});

  final String key;
  final String label;
}
