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
import '../../../core/widgets/document_upload_tile.dart';
import 'application_detail_screen.dart';

class PawnSubmissionFlowScreen extends StatefulWidget {
  const PawnSubmissionFlowScreen({
    super.key,
    required this.initialCategory,
    this.initialEstimatedValue,
    this.initialTenorDays,
    this.existingApplication,
  });

  final PawnCategory initialCategory;
  final double? initialEstimatedValue;
  final int? initialTenorDays;
  final PawnApplication? existingApplication;

  @override
  State<PawnSubmissionFlowScreen> createState() =>
      _PawnSubmissionFlowScreenState();
}

class _PawnSubmissionFlowScreenState extends State<PawnSubmissionFlowScreen> {
  final _step1FormKey = GlobalKey<FormState>();

  late final PawnCategory _category;
  int _stepIndex = 0; // 0: Form, 1: Upload, 2: Review
  bool _isSubmitting = false;
  bool _truthConfirmed = false;
  bool _showTruthError = false;
  bool _showUploadValidation = false;

  // Shared controllers
  final _estimatedValueCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Elektronik controllers
  final _deviceTypeCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _purchaseYearCtrl = TextEditingController();
  final _physicalCondCtrl = TextEditingController();
  final _funcCondCtrl = TextEditingController();
  final _accessoriesCtrl = TextEditingController();
  final _serialCtrl = TextEditingController();

  // Emas controllers
  final _goldTypeCtrl = TextEditingController();
  final _karatCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _goldCondCtrl = TextEditingController();

  // BPKB controllers
  final _vehicleTypeCtrl = TextEditingController();
  final _vehicleBrandModelCtrl = TextEditingController();
  final _vehicleYearCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();

  // Uploaded documents keyed by slot id
  final Map<String, PawnDocument> _uploadedDocs = {};
  PawnApplication? _submittedApp;

  bool get _isRevisionMode => widget.existingApplication != null;

  @override
  void initState() {
    super.initState();
    _category = widget.existingApplication?.category ?? widget.initialCategory;

    if (widget.initialEstimatedValue != null) {
      _estimatedValueCtrl.text =
          widget.initialEstimatedValue!.round().toString();
    }

    final existing = widget.existingApplication;
    if (existing != null) {
      final d = existing.itemDetails;
      _estimatedValueCtrl.text =
          existing.estimatedUserValue?.round().toString() ?? '';
      _notesCtrl.text = d['Catatan Tambahan'] ?? '';
      for (final doc in existing.documents) {
        _uploadedDocs[doc.label] = doc;
      }

      switch (_category) {
        case PawnCategory.elektronik:
          _deviceTypeCtrl.text = d['Jenis Perangkat'] ?? '';
          _brandCtrl.text = d['Merek'] ?? '';
          _modelCtrl.text = d['Model/Tipe'] ?? '';
          _purchaseYearCtrl.text = d['Tahun Pembelian'] ?? '';
          _physicalCondCtrl.text = d['Kondisi Fisik'] ?? '';
          _funcCondCtrl.text = d['Kondisi Fungsi'] ?? '';
          _accessoriesCtrl.text = d['Kelengkapan'] ?? '';
          _serialCtrl.text = d['Nomor Seri/IMEI'] ?? '';
        case PawnCategory.emas:
          _goldTypeCtrl.text = d['Jenis Emas'] ?? '';
          _karatCtrl.text = d['Kadar/Karat'] ?? '';
          _weightCtrl.text = d['Berat (gram)'] ?? '';
          _goldCondCtrl.text = d['Kondisi'] ?? '';
        case PawnCategory.bpkb:
          _vehicleTypeCtrl.text = d['Jenis Kendaraan'] ?? '';
          _vehicleBrandModelCtrl.text = d['Merek & Model'] ?? '';
          _vehicleYearCtrl.text = d['Tahun Kendaraan'] ?? '';
          _plateCtrl.text = d['Nomor Polisi'] ?? '';
          _ownerNameCtrl.text = d['Nama Pemilik Dokumen'] ?? '';
      }
    }
  }

  @override
  void dispose() {
    _estimatedValueCtrl.dispose();
    _notesCtrl.dispose();
    _deviceTypeCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _purchaseYearCtrl.dispose();
    _physicalCondCtrl.dispose();
    _funcCondCtrl.dispose();
    _accessoriesCtrl.dispose();
    _serialCtrl.dispose();
    _goldTypeCtrl.dispose();
    _karatCtrl.dispose();
    _weightCtrl.dispose();
    _goldCondCtrl.dispose();
    _vehicleTypeCtrl.dispose();
    _vehicleBrandModelCtrl.dispose();
    _vehicleYearCtrl.dispose();
    _plateCtrl.dispose();
    _ownerNameCtrl.dispose();
    super.dispose();
  }

  List<_DocSlotConfig> get _docSlots => switch (_category) {
        PawnCategory.elektronik => const [
            _DocSlotConfig(
              title: 'Foto Barang (Tampak Depan)',
              subtitle: 'Format JPG/PNG, maksimal 5 MB',
              required: true,
              sampleFile: 'elektronik_depan.jpg',
            ),
            _DocSlotConfig(
              title: 'Foto Kelengkapan',
              subtitle: 'Charger, dus, atau aksesori pendukung',
              required: true,
              sampleFile: 'elektronik_kelengkapan.jpg',
            ),
            _DocSlotConfig(
              title: 'Foto Nomor Seri / IMEI (Opsional)',
              subtitle: 'Membantu percepatan verifikasi perangkat',
              required: false,
              sampleFile: 'elektronik_sn.jpg',
            ),
          ],
        PawnCategory.emas => const [
            _DocSlotConfig(
              title: 'Foto Emas / Perhiasan',
              subtitle: 'Pastikan foto jelas dengan pencahayaan cukup',
              required: true,
              sampleFile: 'emas_barang.jpg',
            ),
            _DocSlotConfig(
              title: 'Foto Bukti Pembelian / Sertifikat',
              subtitle: 'Opsional bila tersedia untuk referensi',
              required: false,
              sampleFile: 'emas_sertifikat.jpg',
            ),
          ],
        PawnCategory.bpkb => const [
            _DocSlotConfig(
              title: 'Foto BPKB (Halaman Identitas)',
              subtitle: 'Disimpan privat hanya untuk verifikasi petugas',
              required: true,
              isSensitive: true,
              sampleFile: 'bpkb_dokumen.jpg',
            ),
            _DocSlotConfig(
              title: 'Foto Kendaraan',
              subtitle: 'Tampak samping atau depan beserta pelat nomor',
              required: true,
              sampleFile: 'kendaraan_tampak.jpg',
            ),
          ],
      };

  String _buildItemTitle() {
    switch (_category) {
      case PawnCategory.elektronik:
        return '${_brandCtrl.text.trim()} ${_modelCtrl.text.trim()}'.trim();
      case PawnCategory.emas:
        return '${_goldTypeCtrl.text.trim()} (${_weightCtrl.text.trim()}g)';
      case PawnCategory.bpkb:
        return '${_vehicleBrandModelCtrl.text.trim()} (${_vehicleYearCtrl.text.trim()})';
    }
  }

  Map<String, String> _buildItemDetails() {
    final details = <String, String>{};
    switch (_category) {
      case PawnCategory.elektronik:
        details['Jenis Perangkat'] = _deviceTypeCtrl.text.trim();
        details['Merek'] = _brandCtrl.text.trim();
        details['Model/Tipe'] = _modelCtrl.text.trim();
        if (_purchaseYearCtrl.text.trim().isNotEmpty) {
          details['Tahun Pembelian'] = _purchaseYearCtrl.text.trim();
        }
        details['Kondisi Fisik'] = _physicalCondCtrl.text.trim();
        details['Kondisi Fungsi'] = _funcCondCtrl.text.trim();
        details['Kelengkapan'] = _accessoriesCtrl.text.trim();
        if (_serialCtrl.text.trim().isNotEmpty) {
          details['Nomor Seri/IMEI'] = _serialCtrl.text.trim();
        }
      case PawnCategory.emas:
        details['Jenis Emas'] = _goldTypeCtrl.text.trim();
        if (_karatCtrl.text.trim().isNotEmpty) {
          details['Kadar/Karat'] = _karatCtrl.text.trim();
        }
        details['Berat (gram)'] = _weightCtrl.text.trim();
        details['Kondisi'] = _goldCondCtrl.text.trim();
      case PawnCategory.bpkb:
        details['Jenis Kendaraan'] = _vehicleTypeCtrl.text.trim();
        details['Merek & Model'] = _vehicleBrandModelCtrl.text.trim();
        details['Tahun Kendaraan'] = _vehicleYearCtrl.text.trim();
        details['Nomor Polisi'] = _plateCtrl.text.trim().toUpperCase();
        details['Nama Pemilik Dokumen'] = _ownerNameCtrl.text.trim();
    }
    if (_notesCtrl.text.trim().isNotEmpty) {
      details['Catatan Tambahan'] = _notesCtrl.text.trim();
    }
    return details;
  }

  void _nextStep() {
    if (_stepIndex == 0) {
      if (!_step1FormKey.currentState!.validate()) return;
      setState(() => _stepIndex = 1);
      return;
    }
    if (_stepIndex == 1) {
      final missingRequired = _docSlots
          .where((slot) => slot.required && !_uploadedDocs.containsKey(slot.title))
          .isNotEmpty;
      if (missingRequired) {
        setState(() => _showUploadValidation = true);
        return;
      }
      setState(() {
        _showUploadValidation = false;
        _stepIndex = 2;
      });
    }
  }

  Future<void> _pickDocument(_DocSlotConfig slot) async {
    final source = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pilih Sumber Berkas', style: AppTextStyles.sectionHeading),
              const SizedBox(height: 4),
              const Text(
                'Format JPG/PNG/PDF, ukuran maksimal 5 MB.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined,
                    color: AppColors.primary),
                title: const Text('Ambil Foto dari Kamera (Demo)'),
                onTap: () => Navigator.of(ctx).pop('kamera_${slot.sampleFile}'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppColors.primary),
                title: const Text('Pilih dari Galeri (Demo)'),
                onTap: () => Navigator.of(ctx).pop('galeri_${slot.sampleFile}'),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null || !mounted) return;
    setState(() {
      _uploadedDocs[slot.title] = PawnDocument(
        id: 'doc-${DateTime.now().millisecondsSinceEpoch}',
        label: slot.title,
        fileName: source,
        sizeLabel: '1.1 MB',
        isSensitive: slot.isSensitive,
      );
    });
  }

  Future<void> _submitFinal() async {
    if (!_truthConfirmed) {
      setState(() => _showTruthError = true);
      return;
    }

    setState(() {
      _showTruthError = false;
      _isSubmitting = true;
    });

    try {
      final appState = AppStateScope.of(context);
      final docs = _uploadedDocs.values.toList();
      final itemTitle = _buildItemTitle();
      final details = _buildItemDetails();

      PawnApplication result;
      if (_isRevisionMode) {
        result = await appState.reviseApplication(
          applicationId: widget.existingApplication!.id,
          itemTitle: itemTitle,
          itemDetails: details,
          documents: docs,
        );
      } else {
        result = await appState.submitApplication(
          category: _category,
          itemTitle: itemTitle,
          itemDetails: details,
          documents: docs,
          estimatedValue: AppFormatters.parseCurrency(_estimatedValueCtrl.text),
          preferredTenorDays: widget.initialTenorDays,
        );
      }

      if (!mounted) return;
      setState(() => _submittedApp = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_submittedApp != null) {
      return _SuccessSubmittedView(
        application: _submittedApp!,
        isRevision: _isRevisionMode,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isRevisionMode
              ? 'Perbaiki Pengajuan'
              : 'Gadai ${_category.label}',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StepHeader(currentStep: _stepIndex),
            Expanded(
              child: IndexedStack(
                index: _stepIndex,
                children: [
                  _buildStep1Form(),
                  _buildStep2Upload(),
                  _buildStep3Review(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1Form() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      child: Form(
        key: _step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_category == PawnCategory.emas) ...[
              AppCard(
                backgroundColor: AppColors.infoSoft,
                borderColor: AppColors.info.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(14),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Data berat dan kadar yang Anda masukkan merupakan perkiraan awal. Hasil akhir menunggu pemeriksaan fisik.',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (_category == PawnCategory.bpkb) ...[
              AppCard(
                backgroundColor: AppColors.primarySoft,
                borderColor: AppColors.primary.withValues(alpha: 0.25),
                padding: const EdgeInsets.all(14),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.privacy_tip_outlined,
                        color: AppColors.primary, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Peringatan Privasi: Dokumen BPKB dan data kendaraan hanya digunakan untuk proses verifikasi dan tidak ditampilkan secara publik.',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (_category == PawnCategory.elektronik) ..._buildElektronikFields(),
            if (_category == PawnCategory.emas) ..._buildEmasFields(),
            if (_category == PawnCategory.bpkb) ..._buildBpkbFields(),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Perkiraan Nilai Barang (Opsional)',
              controller: _estimatedValueCtrl,
              hint: 'Contoh: 5000000',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              prefixIcon: Icons.payments_outlined,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Catatan Tambahan (Opsional)',
              controller: _notesCtrl,
              hint: 'Tambahkan informasi penting mengenai barang',
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildElektronikFields() {
    return [
      AppTextField(
        label: 'Jenis Perangkat',
        controller: _deviceTypeCtrl,
        hint: 'Contoh: Smartphone, Laptop, Kamera',
        validator: (v) =>
            AppValidators.requiredField(v, label: 'Jenis perangkat'),
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Merek',
        controller: _brandCtrl,
        hint: 'Contoh: Apple, Samsung, Asus',
        validator: (v) => AppValidators.requiredField(v, label: 'Merek'),
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Model / Tipe',
        controller: _modelCtrl,
        hint: 'Contoh: MacBook Air M2 256GB',
        validator: (v) => AppValidators.requiredField(v, label: 'Model/tipe'),
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Tahun Pembelian (Opsional)',
        controller: _purchaseYearCtrl,
        hint: 'Contoh: 2023',
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Kondisi Fisik',
        controller: _physicalCondCtrl,
        hint: 'Contoh: Mulus, tidak ada retak',
        validator: (v) =>
            AppValidators.requiredField(v, label: 'Kondisi fisik'),
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Kondisi Fungsi',
        controller: _funcCondCtrl,
        hint: 'Contoh: Semua fitur berfungsi normal',
        validator: (v) =>
            AppValidators.requiredField(v, label: 'Kondisi fungsi'),
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Kelengkapan',
        controller: _accessoriesCtrl,
        hint: 'Contoh: Unit, charger ori, dus',
        validator: (v) => AppValidators.requiredField(v, label: 'Kelengkapan'),
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Nomor Seri / IMEI (Opsional)',
        controller: _serialCtrl,
        hint: 'Untuk membantu proses verifikasi',
      ),
    ];
  }

  List<Widget> _buildEmasFields() {
    return [
      AppTextField(
        label: 'Jenis Emas / Perhiasan',
        controller: _goldTypeCtrl,
        hint: 'Contoh: Cincin, Kalung, Logam Mulia',
        validator: (v) => AppValidators.requiredField(v, label: 'Jenis emas'),
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Kadar / Karat (Opsional)',
        controller: _karatCtrl,
        hint: 'Contoh: 22 Karat / 99.9%',
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Perkiraan Berat (Gram)',
        controller: _weightCtrl,
        hint: 'Contoh: 5.5',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (v) => AppValidators.requiredField(v, label: 'Berat emas'),
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Kondisi Barang',
        controller: _goldCondCtrl,
        hint: 'Contoh: Baik, tidak patah/penyok',
        validator: (v) => AppValidators.requiredField(v, label: 'Kondisi'),
      ),
    ];
  }

  List<Widget> _buildBpkbFields() {
    return [
      AppTextField(
        label: 'Jenis Kendaraan',
        controller: _vehicleTypeCtrl,
        hint: 'Contoh: Sepeda Motor / Mobil',
        validator: (v) =>
            AppValidators.requiredField(v, label: 'Jenis kendaraan'),
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Merek & Model Kendaraan',
        controller: _vehicleBrandModelCtrl,
        hint: 'Contoh: Honda Vario 160 CBS',
        validator: (v) =>
            AppValidators.requiredField(v, label: 'Merek & model'),
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Tahun Kendaraan',
        controller: _vehicleYearCtrl,
        hint: 'Contoh: 2024',
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (v) =>
            AppValidators.requiredField(v, label: 'Tahun kendaraan'),
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Nomor Polisi',
        controller: _plateCtrl,
        hint: 'Contoh: B 4123 DEMO',
        validator: (v) =>
            AppValidators.requiredField(v, label: 'Nomor polisi'),
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Nama Pemilik Sesuai Dokumen',
        controller: _ownerNameCtrl,
        hint: 'Nama yang tertera pada BPKB',
        validator: (v) =>
            AppValidators.requiredField(v, label: 'Nama pemilik dokumen'),
      ),
    ];
  }

  Widget _buildStep2Upload() {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      children: [
        const Text(
          'Unggah Foto & Dokumen',
          style: AppTextStyles.sectionHeading,
        ),
        const SizedBox(height: 4),
        const Text(
          'Pastikan gambar tidak buram dan informasi terlihat jelas. Format JPG/PNG, maks 5 MB.',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: AppSpacing.md),
        for (final slot in _docSlots) ...[
          DocumentUploadTile(
            title: slot.title,
            subtitle: slot.subtitle,
            isRequired: slot.required,
            fileName: _uploadedDocs[slot.title]?.fileName,
            fileSizeLabel: _uploadedDocs[slot.title]?.sizeLabel,
            errorText: (_showUploadValidation &&
                    slot.required &&
                    !_uploadedDocs.containsKey(slot.title))
                ? 'Berkas ini wajib diunggah'
                : null,
            onPick: () => _pickDocument(slot),
            onReplace: () => _pickDocument(slot),
            onRemove: () {
              setState(() => _uploadedDocs.remove(slot.title));
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  Widget _buildStep3Review() {
    final details = _buildItemDetails();
    final estVal = AppFormatters.parseCurrency(_estimatedValueCtrl.text);

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      children: [
        const Text(
          'Tinjau Ringkasan Pengajuan',
          style: AppTextStyles.sectionHeading,
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_category.icon, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Kategori ${_category.label}',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              for (final entry in details.entries) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(entry.key, style: AppTextStyles.caption),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 6,
                        child: Text(
                          entry.value,
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (estVal != null) ...[
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Perkiraan Nilai Barang',
                      style: AppTextStyles.caption,
                    ),
                    Text(
                      AppFormatters.formatRupiah(estVal),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Berkas Terlampir (${_uploadedDocs.length})',
                style: AppTextStyles.cardTitle,
              ),
              const SizedBox(height: 10),
              for (final doc in _uploadedDocs.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${doc.label}: ${doc.fileName}',
                          style: AppTextStyles.body,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        CheckboxListTile(
          value: _truthConfirmed,
          onChanged: (val) {
            setState(() {
              _truthConfirmed = val ?? false;
              if (_truthConfirmed) _showTruthError = false;
            });
          },
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.primary,
          title: const Text(
            'Saya menyatakan bahwa data barang dan dokumen yang dikirim adalah benar dan milik saya/dikuasakan secara sah.',
            style: AppTextStyles.caption,
          ),
        ),
        if (_showTruthError)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              'Centang pernyataan kebenaran data sebelum mengirim pengajuan.',
              style: AppTextStyles.caption.copyWith(color: AppColors.danger),
            ),
          ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (_stepIndex > 0) ...[
            Expanded(
              child: SecondaryButton(
                label: 'Kembali',
                onPressed: _isSubmitting
                    ? null
                    : () => setState(() => _stepIndex -= 1),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            flex: 2,
            child: PrimaryButton(
              label: _stepIndex == 2
                  ? (_isRevisionMode ? 'Kirim Perbaikan' : 'Kirim Pengajuan')
                  : 'Lanjutkan',
              isLoading: _isSubmitting,
              onPressed: _stepIndex == 2 ? _submitFinal : _nextStep,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const titles = ['Data Barang', 'Unggah Berkas', 'Tinjau & Kirim'];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Langkah ${currentStep + 1} dari 3 • ${titles[currentStep]}',
                style: AppTextStyles.captionBold.copyWith(
                  color: AppColors.primary,
                ),
              ),
              Text(
                '${(((currentStep + 1) / 3) * 100).round()}%',
                style: AppTextStyles.captionBold,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (currentStep + 1) / 3,
              minHeight: 6,
              backgroundColor: AppColors.primarySoft,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessSubmittedView extends StatelessWidget {
  const _SuccessSubmittedView({
    required this.application,
    required this.isRevision,
  });

  final PawnApplication application;
  final bool isRevision;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  size: 48,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                isRevision
                    ? 'Perbaikan Data Terkirim'
                    : 'Pengajuan Berhasil Dikirim!',
                style: AppTextStyles.pageHeading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Pengajuan Anda telah masuk ke antrean verifikasi. Pantau perkembangan status secara berkala.',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                backgroundColor: AppColors.primarySoft,
                borderColor: AppColors.primary.withValues(alpha: 0.25),
                child: Column(
                  children: [
                    const Text(
                      'Nomor Pengajuan',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      application.code,
                      style: AppTextStyles.nominalMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      application.itemTitle,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: 'Lihat Status Pengajuan',
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => ApplicationDetailScreen(
                        applicationId: application.id,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),
              SecondaryButton(
                label: 'Kembali ke Beranda',
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocSlotConfig {
  const _DocSlotConfig({
    required this.title,
    required this.subtitle,
    required this.required,
    required this.sampleFile,
    this.isSensitive = false,
  });

  final String title;
  final String subtitle;
  final bool required;
  final String sampleFile;
  final bool isSensitive;
}
