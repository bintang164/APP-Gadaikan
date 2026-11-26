import 'package:flutter/material.dart';
import '../../../core/models/gadaikan_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
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
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final filtered = appState.applications.where((app) {
      if (_filter == 'pending') return app.status.isPendingAction;
      if (_filter == 'approved') {
        return app.status == ApplicationStatus.approved ||
            app.status == ApplicationStatus.offerAccepted;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengajuan Saya'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(CategorySelectionScreen.routeName);
            },
            tooltip: 'Ajukan Gadai Baru',
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: AppColors.primary),
          ),
        ],
      ),
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
                    _FilterChipItem(
                      label: 'Semua (${appState.applications.length})',
                      selected: _filter == 'all',
                      onTap: () => setState(() => _filter = 'all'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChipItem(
                      label: 'Perlu Tindakan / Proses',
                      selected: _filter == 'pending',
                      onTap: () => setState(() => _filter = 'pending'),
                    ),
                    const SizedBox(width: 8),
                    _FilterChipItem(
                      label: 'Disetujui',
                      selected: _filter == 'approved',
                      onTap: () => setState(() => _filter = 'approved'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? EmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'Belum Ada Pengajuan',
                        subtitle:
                            'Ajukan gadai barang elektronik, emas, atau BPKB untuk mulai memantau status di sini.',
                        actionLabel: 'Ajukan Gadai',
                        onAction: () {
                          Navigator.of(context)
                              .pushNamed(CategorySelectionScreen.routeName);
                        },
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenHorizontal,
                          vertical: AppSpacing.sm,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm + 4),
                        itemBuilder: (context, index) {
                          final app = filtered[index];
                          return TransactionListTile(
                            code: app.code,
                            title: app.itemTitle,
                            categoryLabel: app.category.label,
                            categoryIcon: app.category.icon,
                            dateLabel: AppFormatters.formatDate(app.updatedAt),
                            statusLabel: app.status.label,
                            statusTone: app.status.tone,
                            amountLabel: app.assessment != null
                                ? AppFormatters.formatRupiah(
                                    app.assessment!.approvedPrincipal,
                                  )
                                : null,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => ApplicationDetailScreen(
                                    applicationId: app.id,
                                  ),
                                ),
                              );
                            },
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

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
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
