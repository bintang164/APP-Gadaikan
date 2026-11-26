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
import 'application_detail_screen.dart';
import 'category_selection_screen.dart';

class ApplicationListScreen extends StatefulWidget {
  const ApplicationListScreen({super.key});

  @override
  State<ApplicationListScreen> createState() => _ApplicationListScreenState();
}

class _ApplicationListScreenState extends State<ApplicationListScreen> {
  static const List<_Filter> _filters = <_Filter>[
    _Filter(key: 'all', label: 'Semua'),
    _Filter(key: 'pending', label: 'Menunggu'),
    _Filter(key: 'processing', label: 'Diproses'),
    _Filter(key: 'revision_required', label: 'Perlu Perbaikan'),
    _Filter(key: 'approved', label: 'Disetujui'),
    _Filter(key: 'rejected', label: 'Ditolak'),
  ];

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppStateScope.of(context).loadApplicationsPage(status: 'all', page: 1);
    });
  }

  Future<void> _refresh(AppState state) async {
    await state.loadApplicationsPage(
      status: state.applicationFilter,
      page: 1,
    );
    await state.refreshAllData();
  }

  void _openDetail(PawnApplication application) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ApplicationDetailScreen(applicationId: application.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppState state = AppStateScope.of(context);
    final PagedApplications? page = state.applicationPage;
    final List<PawnApplication> items = page?.items ?? const <PawnApplication>[];
    final bool initialLoading = state.isLoadingApplications && page == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengajuan Saya'),
        actions: [
          IconButton(
            onPressed: () => _refresh(state),
            tooltip: 'Muat ulang daftar',
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(CategorySelectionScreen.routeName);
            },
            tooltip: 'Ajukan Gadai Baru',
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.primary),
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
                      selected: state.applicationFilter == filter.key,
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: state.applicationFilter == filter.key
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      onSelected: (_) {
                        state.setApplicationFilter(filter.key);
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
                    'Mode demo: daftar ini berasal dari data lokal, bukan server.',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.warning),
                  ),
                ),
              ),
            Expanded(
              child: initialLoading
                  ? const LoadingView(message: 'Memuat daftar pengajuan...')
                  : state.applicationListError != null
                      ? ErrorState(
                          message: state.applicationListError!,
                          onRetry: () => state.loadApplicationsPage(
                            status: state.applicationFilter,
                            page: 1,
                          ),
                        )
                      : items.isEmpty
                          ? EmptyState(
                              icon: Icons.assignment_outlined,
                              title: 'Belum Ada Pengajuan',
                              subtitle:
                                  'Ajukan gadai elektronik, emas, atau BPKB untuk memantau statusnya di sini.',
                              actionLabel: 'Ajukan Gadai',
                              onAction: () {
                                Navigator.of(context).pushNamed(
                                  CategorySelectionScreen.routeName,
                                );
                              },
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
                                  final PawnApplication app = items[index];
                                  return TransactionListTile(
                                    code: app.code,
                                    title: app.itemTitle,
                                    categoryLabel: app.category.label,
                                    categoryIcon: app.category.icon,
                                    dateLabel:
                                        AppFormatters.formatDate(app.updatedAt),
                                    statusLabel: app.status.label,
                                    statusTone: app.status.tone,
                                    amountLabel: app.assessment != null
                                        ? AppFormatters.formatRupiah(
                                            app.assessment!.approvedPrincipal,
                                          )
                                        : null,
                                    onTap: () => _openDetail(app),
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

  Widget _buildFooter(AppState state, PagedApplications page) {
    if (!page.hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(
          child: Text(
            'Menampilkan ${page.items.length} dari ${page.total} pengajuan',
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
            label: state.isLoadingApplications
                ? 'Memuat...'
                : 'Muat Lebih Banyak',
            isLoading: state.isLoadingApplications,
            onPressed: state.isLoadingApplications
                ? null
                : state.loadMoreApplications,
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
