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
  bool _detailLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_detailLoaded) return;
    _detailLoaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _reloadDetail();
    });
  }

  Future<void> _reloadDetail() async {
    try {
      await AppStateScope.of(context).loadApplicationDetail(widget.applicationId);
    } catch (_) {
      // Detail lama tetap ditampilkan bila server sedang bermasalah.
    }
  }

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
                        Expanded(
                          child: Text(
                            app.code,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: StatusBadge(
                            label: app.status.label,
                            tone: app.status.tone,
                          ),
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
              _buildStatusInfoCard(app),
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
                      _DetailRow(
                        label: entry.key,
                        value: app.category == PawnCategory.bpkb &&
                                entry.key == 'Nomor Polisi'
                            ? AppFormatters.maskPlate(entry.value)
                            : entry.value,
                      ),
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
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusInfoCard(PawnApplication app) {
    final String title;
    final String message;
    final Color background;
    final Color border;
    final IconData icon;

    switch (app.status) {
      case ApplicationStatus.revisionRequired:
        title = 'Perlu Perbaikan Data';
        message = 'Petugas memerlukan tambahan data atau foto yang lebih jelas. '
            'Perbaiki pengajuan lalu kirim kembali.';
        background = AppColors.warningSoft;
        border = AppColors.warning;
        icon = Icons.edit_note_rounded;
      case ApplicationStatus.approved:
        title = 'Penawaran Siap Ditinjau';
        message = 'Penawaran di bawah adalah hasil pemeriksaan. Terima atau tolak '
            'penawaran untuk melanjutkan. Nilai final tercatat di server.';
        background = AppColors.successSoft;
        border = AppColors.success;
        icon = Icons.check_circle_outline_rounded;
      case ApplicationStatus.rejected:
        title = 'Pengajuan Belum Disetujui';
        message = 'Pengajuan ini tidak dapat dilanjutkan. Silakan periksa kembali '
            'data dan persyaratan, lalu ajukan kembali bila memungkinkan. '
            'Untuk informasi lebih lanjut, hubungi outlet terdekat.';
        background = AppColors.dangerSoft;
        border = AppColors.danger;
        icon = Icons.info_outline_rounded;
      case ApplicationStatus.underReview:
      case ApplicationStatus.submitted:
        title = 'Sedang Diproses';
        message = 'Pengajuan sedang diperiksa petugas. Perubahan status berikutnya '
            'dicatat oleh backend dan akan muncul pada timeline ini.';
        background = AppColors.infoSoft;
        border = AppColors.info;
        icon = Icons.schedule_rounded;
      default:
        title = 'Informasi Pengajuan';
        message = 'Status pengajuan: ${app.status.label}. Semua perubahan status '
            'divalidasi oleh backend, bukan dari aplikasi nasabah.';
        background = AppColors.primarySoft;
        border = AppColors.primary;
        icon = Icons.info_outline_rounded;
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: AppCard(
        backgroundColor: background,
        borderColor: border.withValues(alpha: 0.35),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: border, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.cardTitle),
                  const SizedBox(height: 4),
                  Text(message, style: AppTextStyles.caption),
                  const SizedBox(height: 6),
                  Text(
                    AppStateScope.of(context).usesBackend
                        ? 'Sumber status: server Laravel.'
                        : 'Mode demo: status dan timeline berasal dari data lokal.',
                    style: AppTextStyles.caption.copyWith(color: border),
                  ),
                ],
              ),
            ),
          ],
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
