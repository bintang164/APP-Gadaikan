import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/gadaikan_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_cards.dart';
import '../../../core/widgets/state_views.dart';
import '../../../core/widgets/status_badge.dart';

class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  final String transactionId;

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  bool _isPaying = false;

  Future<void> _showDemoPaymentSheet(PawnTransaction trx) async {
    final amountCtrl = TextEditingController(
      text: trx.remainingAmount.round().toString(),
    );
    String method = 'Transfer Bank';
    final formKey = GlobalKey<FormState>();

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.screenHorizontal,
            right: AppSpacing.screenHorizontal,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pembayaran Simulasi (Demo)',
                  style: AppTextStyles.sectionHeading,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Fitur ini hanya mencatat simulasi pembayaran demo tanpa memotong saldo atau transaksi uang sungguhan.',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Nominal Pembayaran (Rp)',
                  ),
                  validator: (v) {
                    final parsed = AppFormatters.parseCurrency(v ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Masukkan nominal yang valid';
                    }
                    if (parsed > trx.remainingAmount) {
                      return 'Nominal melebihi sisa kewajiban';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: method,
                  decoration: const InputDecoration(
                    labelText: 'Metode Simulasi',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Transfer Bank',
                      child: Text('Transfer Bank (Simulasi)'),
                    ),
                    DropdownMenuItem(
                      value: 'Virtual Account',
                      child: Text('Virtual Account (Simulasi)'),
                    ),
                    DropdownMenuItem(
                      value: 'Tunai di Outlet',
                      child: Text('Tunai di Outlet (Simulasi)'),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) setSheetState(() => method = val);
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: 'Catat Pembayaran Demo',
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(ctx).pop(true);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;
    final amount = AppFormatters.parseCurrency(amountCtrl.text) ?? 0;

    setState(() => _isPaying = true);
    try {
      await AppStateScope.of(context).recordDemoPayment(
        transactionId: trx.id,
        amount: amount,
        method: method,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pembayaran simulasi ${AppFormatters.formatRupiah(amount)} berhasil dicatat.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final trx = appState.findTransactionById(widget.transactionId);

    if (trx == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Transaksi')),
        body: ErrorState(
          title: 'Transaksi Tidak Ditemukan',
          message: 'Data transaksi tidak tersedia.',
          onRetry: appState.refreshAllData,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Transaksi')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
            vertical: AppSpacing.md,
          ),
          children: [
            AppCard(
              backgroundColor: AppColors.warningSoft,
              borderColor: AppColors.warning.withValues(alpha: 0.35),
              padding: const EdgeInsets.all(12),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mode Demo: Nilai pinjaman, biaya, dan pencatatan pembayaran pada halaman ini adalah simulasi.',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        trx.code,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      StatusBadge(
                        label: trx.status.label,
                        tone: trx.status.tone,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(trx.itemTitle, style: AppTextStyles.sectionHeading),
                  const SizedBox(height: 4),
                  Text(
                    'Kategori ${trx.category.label} • Tenor ${trx.tenorDays} Hari',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Sisa Kewajiban',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.formatRupiah(trx.remainingAmount),
                    style: AppTextStyles.nominalLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _InfoRow(
                    label: 'Pokok Pinjaman',
                    value: AppFormatters.formatRupiah(trx.principalAmount),
                  ),
                  _InfoRow(
                    label: 'Biaya Layanan',
                    value: AppFormatters.formatRupiah(trx.feeAmount),
                  ),
                  _InfoRow(
                    label: 'Total Kewajiban',
                    value: AppFormatters.formatRupiah(trx.totalDue),
                  ),
                  _InfoRow(
                    label: 'Sudah Dibayar',
                    value: AppFormatters.formatRupiah(trx.paidAmount),
                  ),
                  _InfoRow(
                    label: 'Tanggal Mulai',
                    value: AppFormatters.formatDate(trx.startDate),
                  ),
                  _InfoRow(
                    label: 'Jatuh Tempo',
                    value: AppFormatters.formatDate(trx.dueDate),
                  ),
                ],
              ),
            ),
            if (trx.remainingAmount > 0) ...[
              const SizedBox(height: AppSpacing.md),
              PrimaryButton(
                label: 'Catat Pembayaran (Simulasi Demo)',
                icon: Icons.payments_outlined,
                isLoading: _isPaying,
                onPressed: () => _showDemoPaymentSheet(trx),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Riwayat Pembayaran Simulasi',
              style: AppTextStyles.sectionHeading,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (trx.payments.isEmpty)
              const AppCard(
                child: Text(
                  'Belum ada catatan pembayaran pada transaksi ini.',
                  style: AppTextStyles.bodySecondary,
                ),
              )
            else
              AppCard(
                child: Column(
                  children: [
                    for (int i = 0; i < trx.payments.length; i++) ...[
                      if (i > 0) const Divider(height: 20),
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.successSoft,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.receipt_long_outlined,
                              color: AppColors.success,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trx.payments[i].method,
                                  style: AppTextStyles.bodyMedium,
                                ),
                                Text(
                                  AppFormatters.formatDateTime(
                                    trx.payments[i].paidAt,
                                  ),
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            AppFormatters.formatRupiah(trx.payments[i].amount),
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySecondary),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
