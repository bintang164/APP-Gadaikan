import 'package:flutter/material.dart';
import '../../../core/models/gadaikan_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_cards.dart';
import '../../../core/widgets/application_timeline.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_badge.dart';
import '../../transactions/screens/transaction_detail_screen.dart';
import 'pawn_submission_flow_screen.dart';

class ApplicationDetailScreen extends StatefulWidget {
  const ApplicationDetailScreen({
    super.key,
    required this.applicationId,
  });

  final String applicationId;

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  bool _isProcessing = false;

  Future<void> _acceptOffer(PawnApplication app) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Terima Penawaran?'),
        content: Text(
          'Anda akan menyetujui plafon ${AppFormatters.formatRupiah(app.assessment!.approvedPrincipal)} dengan tenor ${app.assessment!.tenorDays} hari (simulasi demo).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Ya, Terima'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      final trx = await AppStateScope.of(context).acceptOffer(app.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Penawaran diterima. Transaksi ${trx.code} aktif.'),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => TransactionDetailScreen(transactionId: trx.id),
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _declineOffer(PawnApplication app) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak Penawaran?'),
        content: const Text(
          'Jika ditolak, pengajuan ini akan ditutup dengan status Penawaran Ditolak.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Tolak Penawaran'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      await AppStateScope.of(context).declineOffer(app.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Penawaran ditolak.')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _simulateAdminAction(
    PawnApplication app,
    ApplicationStatus nextStatus,
  ) async {
    setState(() => _isProcessing = true);
    try {
      await AppStateScope.of(context).simulateReviewDecision(
        applicationId: app.id,
        nextStatus: nextStatus,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Simulasi status diubah ke "${nextStatus.label}".'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final app = appState.findApplicationById(widget.applicationId);

    if (app == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pengajuan')),
        body: ErrorState(
          title: 'Pengajuan Tidak Ditemukan',
          message: 'Data pengajuan tidak tersedia atau telah dihapus.',
          onRetry: appState.refreshAllData,
        ),
      );
    }

    final timelineSteps = app.statusHistory.map((item) {
      final isError = item.status == ApplicationStatus.rejected ||
          item.status == ApplicationStatus.offerDeclined;
      final isCurrent = item.status == app.status;
      return TimelineStepItem(
        title: item.title,
        subtitle: item.note,
        timestampLabel: AppFormatters.formatDate(item.timestamp),
        isCompleted: !isError && !isCurrent,
        isActive: isCurrent && !isError,
        isError: isError,
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengajuan')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: appState.refreshAllData,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: AppSpacing.md,
            ),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          app.code,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        StatusBadge(
                          label: app.status.label,
                          tone: app.status.tone,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm + 4),
                    Text(app.itemTitle, style: AppTextStyles.sectionHeading),
                    const SizedBox(height: 4),
                    Text(
                      '${app.category.label} • Diajukan ${AppFormatters.formatDate(app.createdAt)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              if (app.adminNote != null && app.adminNote!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                AppCard(
                  backgroundColor: app.status == ApplicationStatus.revisionRequired
                      ? AppColors.warningSoft
                      : AppColors.infoSoft,
                  borderColor: (app.status == ApplicationStatus.revisionRequired
                          ? AppColors.warning
                          : AppColors.info)
                      .withValues(alpha: 0.35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Catatan Pemeriksaan',
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 4),
                      Text(app.adminNote!, style: AppTextStyles.body),
                    ],
                  ),
                ),
              ],
              if (app.status == ApplicationStatus.revisionRequired) ...[
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Perbaiki Data Pengajuan',
                  icon: Icons.edit_outlined,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PawnSubmissionFlowScreen(
                          initialCategory: app.category,
                          existingApplication: app,
                        ),
                      ),
                    );
                  },
                ),
              ],
              if (app.assessment != null) ...[
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Hasil Taksiran & Penawaran',
                  style: AppTextStyles.sectionHeading,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  backgroundColor: AppColors.primarySoft,
                  borderColor: AppColors.primary.withValues(alpha: 0.25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Plafon Pinjaman Disetujui (Simulasi)',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppFormatters.formatRupiah(
                          app.assessment!.approvedPrincipal,
                        ),
                        style: AppTextStyles.nominalLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      _DetailRow(
                        label: 'Nilai Taksiran',
                        value: AppFormatters.formatRupiah(
                          app.assessment!.assessedValue,
                        ),
                      ),
                      _DetailRow(
                        label: 'Biaya Layanan',
                        value: AppFormatters.formatRupiah(
                          app.assessment!.serviceFee,
                        ),
                      ),
                      _DetailRow(
                        label: 'Tenor',
                        value: '${app.assessment!.tenorDays} Hari',
                      ),
                      _DetailRow(
                        label: 'Jatuh Tempo',
                        value: AppFormatters.formatDate(app.assessment!.dueDate),
                      ),
                      if (app.status == ApplicationStatus.approved) ...[
                        const SizedBox(height: AppSpacing.md),
                        PrimaryButton(
                          label: 'Terima Penawaran',
                          isLoading: _isProcessing,
                          onPressed: () => _acceptOffer(app),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SecondaryButton(
                          label: 'Tolak Penawaran',
                          foregroundColor: AppColors.danger,
                          borderColor: AppColors.danger,
                          onPressed:
                              _isProcessing ? null : () => _declineOffer(app),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Timeline Status',
                style: AppTextStyles.sectionHeading,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                child: ApplicationTimeline(steps: timelineSteps),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Detail Barang & Berkas',
                style: AppTextStyles.sectionHeading,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in app.itemDetails.entries)
                      _DetailRow(label: entry.key, value: entry.value),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Berkas Diunggah (${app.documents.length})',
                      style: AppTextStyles.cardTitle,
                    ),
                    const SizedBox(height: 8),
                    for (final doc in app.documents)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(
                              doc.isSensitive
                                  ? Icons.lock_outline
                                  : Icons.image_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                doc.isSensitive
                                    ? '${doc.label} (Tersimpan privat)'
                                    : '${doc.label}: ${doc.fileName}',
                                style: AppTextStyles.body,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (app.status == ApplicationStatus.submitted ||
                  app.status == ApplicationStatus.underReview) ...[
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  backgroundColor: AppColors.accentGoldSoft,
                  borderColor: AppColors.accentGold.withValues(alpha: 0.45),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Simulasi Pemeriksaan Petugas (Mode Demo Frontend)',
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Karena backend Laravel belum dihubungkan, Anda dapat menguji transisi status dari sini.',
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: _isProcessing
                                ? null
                                : () => _simulateAdminAction(
                                      app,
                                      ApplicationStatus.approved,
                                    ),
                            child: const Text('Simulasikan Disetujui'),
                          ),
                          OutlinedButton(
                            onPressed: _isProcessing
                                ? null
                                : () => _simulateAdminAction(
                                      app,
                                      ApplicationStatus.revisionRequired,
                                    ),
                            child: const Text('Minta Perbaikan'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: AppTextStyles.caption),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
