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
import '../../../core/widgets/app_text_fields.dart';
import '../../../core/widgets/state_views.dart';
import '../../pawn/screens/pawn_submission_flow_screen.dart';

class SimulationScreen extends StatefulWidget {
  const SimulationScreen({super.key});

  static const String routeName = '/simulation';

  @override
  State<SimulationScreen> createState() => _SimulationScreenState();
}

class _SimulationScreenState extends State<SimulationScreen> {
  final _valueController = TextEditingController(text: '5000000');
  PawnCategory _selectedCategory = PawnCategory.elektronik;
  int _selectedTenor = 30;
  double _estimatedValue = 5000000;

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _onValueChanged(String raw) {
    final parsed = AppFormatters.parseCurrency(raw);
    setState(() {
      _estimatedValue = parsed ?? 0;
    });
  }

  void _applyPreset(double value) {
    _valueController.text = value.round().toString();
    setState(() => _estimatedValue = value);
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final config = appState.simulationConfig;

    return Scaffold(
      appBar: AppBar(title: const Text('Simulasi Gadai')),
      body: SafeArea(
        child: config == null
            ? const LoadingView(message: 'Memuat parameter simulasi...')
            : _buildContent(context, config),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SimulationConfig config) {
    if (!config.allowedTenorDays.contains(_selectedTenor)) {
      _selectedTenor = config.allowedTenorDays.first;
    }

    final isValidValue = _estimatedValue >= config.minEstimatedValue &&
        _estimatedValue <= config.maxEstimatedValue;
    final result = isValidValue
        ? config.calculate(
            category: _selectedCategory,
            estimatedValue: _estimatedValue,
            tenorDays: _selectedTenor,
          )
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            backgroundColor: AppColors.warningSoft,
            borderColor: AppColors.warning.withValues(alpha: 0.35),
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    config.disclaimer,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Kategori Barang', style: AppTextStyles.sectionHeading),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PawnCategory.values.map((category) {
              final selected = category == _selectedCategory;
              return ChoiceChip(
                label: Text(category.label),
                avatar: Icon(
                  category.icon,
                  size: 18,
                  color: selected ? Colors.white : AppColors.primary,
                ),
                selected: selected,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) => setState(() => _selectedCategory = category),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'Perkiraan Nilai Barang (Rp)',
            controller: _valueController,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.payments_outlined,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: _onValueChanged,
            helperText:
                'Rentang simulasi: ${AppFormatters.formatRupiah(config.minEstimatedValue)} - ${AppFormatters.formatRupiah(config.maxEstimatedValue)}',
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [2000000.0, 5000000.0, 10000000.0, 20000000.0]
                .map(
                  (preset) => ActionChip(
                    label: Text(AppFormatters.formatRupiah(preset)),
                    onPressed: () => _applyPreset(preset),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('Pilihan Tenor', style: AppTextStyles.sectionHeading),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: config.allowedTenorDays.map((tenor) {
              final selected = tenor == _selectedTenor;
              return ChoiceChip(
                label: Text('$tenor Hari'),
                selected: selected,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) => setState(() => _selectedTenor = tenor),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!isValidValue)
            AppCard(
              backgroundColor: AppColors.dangerSoft,
              borderColor: AppColors.danger.withValues(alpha: 0.3),
              child: Text(
                'Masukkan perkiraan nilai barang antara ${AppFormatters.formatRupiah(config.minEstimatedValue)} dan ${AppFormatters.formatRupiah(config.maxEstimatedValue)}.',
                style: AppTextStyles.body.copyWith(color: AppColors.danger),
              ),
            )
          else if (result != null)
            AppCard(
              backgroundColor: AppColors.primarySoft,
              borderColor: AppColors.primary.withValues(alpha: 0.25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Estimasi Plafon Pinjaman',
                        style: AppTextStyles.bodySecondary,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Simulasi',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppFormatters.formatRupiah(result.estimatedPrincipal),
                    style: AppTextStyles.nominalLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  _SummaryRow(
                    label: 'Persentase Plafon (${_selectedCategory.label})',
                    value: '${(result.plafonPercentage * 100).round()}%',
                  ),
                  const SizedBox(height: 6),
                  _SummaryRow(
                    label: 'Estimasi Biaya Layanan ($_selectedTenor hari)',
                    value: AppFormatters.formatRupiah(result.estimatedFee),
                  ),
                  const SizedBox(height: 6),
                  _SummaryRow(
                    label: 'Estimasi Total Pelunasan',
                    value: AppFormatters.formatRupiah(result.estimatedTotal),
                    highlight: true,
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Lanjutkan Pengajuan',
            icon: Icons.arrow_forward_rounded,
            onPressed: !isValidValue
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PawnSubmissionFlowScreen(
                          initialCategory: _selectedCategory,
                          initialEstimatedValue: _estimatedValue,
                          initialTenorDays: _selectedTenor,
                        ),
                      ),
                    );
                  },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: highlight
                ? AppTextStyles.bodyMedium
                : AppTextStyles.bodySecondary,
          ),
        ),
        Text(
          value,
          style: highlight
              ? AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)
              : AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}
