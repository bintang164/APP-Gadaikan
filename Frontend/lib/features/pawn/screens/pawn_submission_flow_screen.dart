import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/config/app_config.dart';
import '../../../core/models/gadaikan_models.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/services/document_upload_service.dart';
import '../../../core/storage/pawn_draft_store.dart';
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
  final _identityFormKey = GlobalKey<FormState>();
  final _conditionFormKey = GlobalKey<FormState>();

  late final PawnCategory _category;
  int _stepIndex = 0;
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
  final _vehicleBrandCtrl = TextEditingController();
  final _vehicleModelCtrl = TextEditingController();
  final _vehicleYearCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();

  // Pilihan terstruktur lintas kategori.
  String? _deviceTypeChoice;
  String? _physicalChoice;
  String? _functionChoice;
  List<String> _accessories = <String>[];
  String? _goldTypeChoice;
  String? _goldConditionChoice;
  String? _vehicleTypeChoice;

  // Uploaded documents keyed by slot id
  final Map<String, PawnDocument> _uploadedDocs = {};
  final Map<String, String> _selectionErrors = <String, String>{};
  PawnApplication? _submittedApp;
  final PawnDraftStore _draftStore = PawnDraftStore();
  final ImagePicker _imagePicker = ImagePicker();
  final DocumentUploadService _uploadService = AppConfig.useMockAuth
      ? MockDocumentUploadService()
      : ApiDocumentUploadService();

  bool get _isRevisionMode => widget.existingApplication != null;

  bool _isDocumentReady(PawnDocument? doc) {
    if (doc == null || doc.hasUploadError) return false;
    if (doc.uploadProgress != null && doc.uploadProgress! < 1) return false;
    // Berkas lama (mode perbaikan) tidak punya path lokal dan tetap valid.
    if (doc.localPath == null) return true;
    return doc.isDemo || doc.isUploadedToServer;
  }

  int get _uploadStep => _category == PawnCategory.elektronik ? 2 : 1;
  int get _reviewStep => _category == PawnCategory.elektronik ? 3 : 2;
  int get _stepCount => _category == PawnCategory.elektronik ? 4 : 3;

  List<String> get _stepTitles => _category == PawnCategory.elektronik
      ? const ['Identitas Perangkat', 'Kondisi & Kelengkapan', 'Unggah Berkas', 'Tinjau & Kirim']
      : const ['Data Barang', 'Unggah Berkas', 'Tinjau & Kirim'];

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
          // Kompatibilitas dengan draf lama yang menggabungkan merek & model.
          final List<String> legacyParts = (d['Merek & Model'] ?? '')
              .toString()
              .split(RegExp(r'\s+'))
              .where((String part) => part.isNotEmpty)
              .toList();
          _vehicleBrandCtrl.text =
              d['Merek'] ?? (legacyParts.isEmpty ? '' : legacyParts.first);
          _vehicleModelCtrl.text = d['Model/Tipe'] ??
              (legacyParts.length < 2 ? '' : legacyParts.sublist(1).join(' '));
          _vehicleYearCtrl.text = d['Tahun Kendaraan'] ?? '';
          _plateCtrl.text = d['Nomor Polisi'] ?? '';
          _ownerNameCtrl.text = d['Nama Pemilik Dokumen'] ?? '';
      }
    } else {
      _loadDraft();
    }
  }

  Future<void> _loadDraft() async {
    try {
      final PawnDraft? draft = await _draftStore.read();
      if (!mounted || draft == null) return;
      if (draft.categoryId != null &&
          draft.categoryId != _category.apiId) {
        return;
      }
      _estimatedValueCtrl.text = draft.text('estimatedValue') ?? '';
      _notesCtrl.text = draft.text('notes') ?? '';

      if (_category == PawnCategory.elektronik) {
        _deviceTypeChoice = draft.text('deviceTypeChoice');
        _physicalChoice = draft.text('physicalChoice');
        _functionChoice = draft.text('functionChoice');
        _accessories = draft.list('accessories');
        _deviceTypeCtrl.text = draft.text('deviceType') ?? '';
        _brandCtrl.text = draft.text('brand') ?? '';
        _modelCtrl.text = draft.text('model') ?? '';
        _purchaseYearCtrl.text = draft.text('purchaseYear') ?? '';
        _physicalCondCtrl.text = draft.text('physicalCondition') ?? '';
        _funcCondCtrl.text = draft.text('functionCondition') ?? '';
        _accessoriesCtrl.text = draft.text('accessoriesText') ?? '';
        _serialCtrl.text = draft.text('serial') ?? '';
      } else if (_category == PawnCategory.emas) {
        _goldTypeChoice = draft.text('goldTypeChoice');
        _goldConditionChoice = draft.text('goldConditionChoice');
        _goldTypeCtrl.text = draft.text('goldType') ?? '';
        _karatCtrl.text = draft.text('karat') ?? '';
        _weightCtrl.text = draft.text('weight') ?? '';
        _goldCondCtrl.text = draft.text('goldCondition') ?? '';
      } else {
        _vehicleTypeChoice = draft.text('vehicleTypeChoice');
        _vehicleTypeCtrl.text = draft.text('vehicleType') ?? '';
        _vehicleBrandModelCtrl.text = draft.text('vehicleBrandModel') ?? '';
        _vehicleBrandCtrl.text = draft.text('vehicleBrand') ?? '';
        _vehicleModelCtrl.text = draft.text('vehicleModel') ?? '';
        _vehicleYearCtrl.text = draft.text('vehicleYear') ?? '';
        _plateCtrl.text = draft.text('plate') ?? '';
        _ownerNameCtrl.text = draft.text('ownerName') ?? '';
      }
      setState(() {});
    } catch (_) {
      // Draft lokal opsional; gagal membaca tidak menghalangi form.
    }
  }

  Future<void> _saveDraft() async {
    if (_isRevisionMode) return;
    final Map<String, dynamic> data = <String, dynamic>{
      'estimatedValue': _estimatedValueCtrl.text,
      'notes': _notesCtrl.text,
      if (_category == PawnCategory.elektronik)
        'deviceType': _deviceTypeCtrl.text
      else
        'goldType': _goldTypeCtrl.text,
    };
    if (_category == PawnCategory.elektronik) {
      data.addAll(<String, dynamic>{
        'deviceTypeChoice': _deviceTypeChoice,
        'physicalChoice': _physicalChoice,
        'functionChoice': _functionChoice,
        'accessories': _accessories,
        'accessoriesText': _accessoriesCtrl.text,
        'brand': _brandCtrl.text,
        'model': _modelCtrl.text,
        'purchaseYear': _purchaseYearCtrl.text,
        'physicalCondition': _physicalCondCtrl.text,
        'functionCondition': _funcCondCtrl.text,
        'serial': _serialCtrl.text,
      });
    } else if (_category == PawnCategory.emas) {
      data.addAll(<String, dynamic>{
        'goldTypeChoice': _goldTypeChoice,
        'goldConditionChoice': _goldConditionChoice,
        'karat': _karatCtrl.text,
        'weight': _weightCtrl.text,
        'goldCondition': _goldCondCtrl.text,
      });
    } else {
      data.addAll(<String, dynamic>{
        'vehicleTypeChoice': _vehicleTypeChoice,
        'vehicleType': _vehicleTypeCtrl.text,
        'vehicleBrandModel': _vehicleBrandModelCtrl.text,
        'vehicleBrand': _vehicleBrandCtrl.text,
        'vehicleModel': _vehicleModelCtrl.text,
        'vehicleYear': _vehicleYearCtrl.text,
        'plate': _plateCtrl.text,
        'ownerName': _ownerNameCtrl.text,
      });
    }
    try {
      await _draftStore.write(
        PawnDraft(categoryId: _category.apiId, data: data),
      );
    } catch (_) {
      // Draft lokal opsional.
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
    _vehicleBrandCtrl.dispose();
    _vehicleModelCtrl.dispose();
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
              subtitle: 'Ambil dari beberapa sisi: depan, belakang, dan detail',
              required: true,
              sampleFile: 'emas_barang.jpg',
            ),
            _DocSlotConfig(
              title: 'Foto Emas (Sisi Tambahan)',
              subtitle: 'Opsional, membantu verifikasi bagian lain barang',
              required: false,
              sampleFile: 'emas_sisi.jpg',
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
            _DocSlotConfig(
              title: 'Dokumen Pendukung (Opsional)',
              subtitle: 'Misalnya bukti kepemilikan tambahan bila tersedia',
              required: false,
              sampleFile: 'bpkb_pendukung.jpg',
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
        details['Deskripsi Tambahan'] = _notesCtrl.text.trim();
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
        details['Merek'] = _vehicleBrandCtrl.text.trim();
        details['Model/Tipe'] = _vehicleModelCtrl.text.trim();
        details['Tahun Kendaraan'] = _vehicleYearCtrl.text.trim();
        details['Nomor Polisi'] = _plateCtrl.text.trim().toUpperCase();
        details['Nama Pemilik Dokumen'] = _ownerNameCtrl.text.trim();
    }
    if (_category != PawnCategory.elektronik &&
        _notesCtrl.text.trim().isNotEmpty) {
      details['Catatan Tambahan'] = _notesCtrl.text.trim();
    }
    return details;
  }

  bool get _isCurrentStepValid {
    switch (_stepIndex) {
      case 0:
        if (_category == PawnCategory.elektronik) {
          return _deviceTypeCtrl.text.trim().isNotEmpty &&
              _brandCtrl.text.trim().isNotEmpty &&
              _modelCtrl.text.trim().isNotEmpty;
        }
        if (_category == PawnCategory.emas) {
          return _goldTypeCtrl.text.trim().isNotEmpty &&
              AppValidators.positiveDecimal(
                    _weightCtrl.text,
                    label: 'Berat',
                    min: 0.01,
                    max: 10000,
                  ) ==
                  null &&
              AppValidators.karat(_karatCtrl.text) == null &&
              _goldCondCtrl.text.trim().isNotEmpty;
        }
        return _vehicleTypeCtrl.text.trim().isNotEmpty &&
            _vehicleBrandCtrl.text.trim().isNotEmpty &&
            _vehicleModelCtrl.text.trim().isNotEmpty &&
            AppValidators.vehicleYear(_vehicleYearCtrl.text) == null &&
            AppValidators.plateNumber(_plateCtrl.text) == null &&
            _ownerNameCtrl.text.trim().isNotEmpty;
      case 1:
        if (_category == PawnCategory.elektronik) {
          return _physicalCondCtrl.text.trim().isNotEmpty &&
              _funcCondCtrl.text.trim().isNotEmpty &&
              _accessories.isNotEmpty &&
              _notesCtrl.text.trim().isNotEmpty;
        }
        return true;
      case 2:
        return _docSlots
            .where((slot) => slot.required)
            .every((slot) => _isDocumentReady(_uploadedDocs[slot.title]));
      default:
        return true;
    }
  }

  void _nextStep() {
    if (_stepIndex == 0) {
      final GlobalKey<FormState> key = _category == PawnCategory.elektronik
          ? _identityFormKey
          : _step1FormKey;
      if (!(key.currentState?.validate() ?? false)) return;
      _saveDraft();
      setState(() => _stepIndex = 1);
      return;
    }
    if (_category == PawnCategory.elektronik && _stepIndex == 1) {
      if (!(_conditionFormKey.currentState?.validate() ?? false)) return;
      _saveDraft();
      setState(() => _stepIndex = _uploadStep);
      return;
    }
    if (_stepIndex == _uploadStep) {
      final missingRequired = _docSlots
          .where(
            (slot) =>
                slot.required && !_isDocumentReady(_uploadedDocs[slot.title]),
          )
          .isNotEmpty;
      if (missingRequired) {
        setState(() => _showUploadValidation = true);
        return;
      }
      setState(() {
        _showUploadValidation = false;
        _stepIndex = _reviewStep;
      });
    }
  }

  Future<void> _pickDocument(_DocSlotConfig slot) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
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
                'Format JPG/PNG/PDF, ukuran maksimal 5 MB. Berkas sensitif '
                'disimpan privat.',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined,
                    color: AppColors.primary),
                title: const Text('Ambil Foto dari Kamera'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined,
                    color: AppColors.primary),
                title: const Text('Pilih dari Galeri / Berkas'),
                onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null || !mounted) return;

    try {
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2400,
      );
      if (file == null || !mounted) return;

      final int size = await file.length();
      final PickedDocument picked = PickedDocument(
        path: file.path,
        name: file.name,
        sizeBytes: size,
        mimeType: file.mimeType,
      );
      final String? validationError = DocumentValidation.validate(picked);
      if (validationError != null) {
        if (!mounted) return;
        setState(() => _selectionErrors[slot.title] = validationError);
        return;
      }

      final Uint8List preview = await file.readAsBytes();
      if (!mounted) return;
      final PawnDocument document = PawnDocument(
        id: 'doc-${DateTime.now().microsecondsSinceEpoch}',
        label: slot.title,
        fileName: file.name,
        sizeLabel: '${(size / 1024 / 1024).toStringAsFixed(2)} MB',
        isSensitive: slot.isSensitive,
        localPath: file.path,
        mimeType: file.mimeType,
        fileSizeBytes: size,
        previewBytes: preview,
        uploadProgress: 0,
        isDemo: _uploadService.isMock,
      );
      setState(() {
        _selectionErrors.remove(slot.title);
        _uploadedDocs[slot.title] = document;
      });
      await _uploadDocument(slot, picked);
    } catch (_) {
      if (!mounted) return;
      setState(() => _selectionErrors[slot.title] =
          'Berkas tidak dapat dibaca. Pilih berkas lain.');
    }
  }

  Future<void> _uploadDocument(
    _DocSlotConfig slot,
    PickedDocument picked,
  ) async {
    final PawnDocument? current = _uploadedDocs[slot.title];
    if (current == null) return;

    setState(() {
      _uploadedDocs[slot.title] = current.copyWith(
        clearUploadError: true,
        uploadProgress: 0,
      );
    });

    try {
      final UploadedDocumentMeta meta = await _uploadService.upload(
        file: picked,
        isSensitive: slot.isSensitive,
        onProgress: (double progress) {
          if (!mounted) return;
          setState(() {
            final PawnDocument? doc = _uploadedDocs[slot.title];
            if (doc != null) {
              _uploadedDocs[slot.title] = doc.copyWith(uploadProgress: progress);
            }
          });
        },
      );
      if (!mounted) return;
      setState(() {
        final PawnDocument? doc = _uploadedDocs[slot.title];
        if (doc != null) {
          _uploadedDocs[slot.title] = doc.copyWith(
            clearUploadProgress: true,
            clearUploadError: true,
            isUploadedToServer: !meta.isDemo,
            isDemo: meta.isDemo,
            serverId: meta.serverId,
          );
        }
      });
    } on DocumentUploadException catch (error) {
      _setUploadError(slot.title, error.message);
    } catch (_) {
      _setUploadError(slot.title, 'Gagal mengunggah berkas. Coba lagi.');
    }
  }

  void _setUploadError(String slotTitle, String message) {
    if (!mounted) return;
    setState(() {
      final PawnDocument? doc = _uploadedDocs[slotTitle];
      if (doc != null) {
        _uploadedDocs[slotTitle] = doc.copyWith(
          uploadError: message,
          clearUploadProgress: true,
        );
      }
    });
  }

  Future<void> _retryUpload(_DocSlotConfig slot) async {
    final PawnDocument? doc = _uploadedDocs[slot.title];
    if (doc?.localPath == null) return;
    await _uploadDocument(
      slot,
      PickedDocument(
        path: doc!.localPath!,
        name: doc.fileName,
        sizeBytes: doc.fileSizeBytes ?? 0,
        mimeType: doc.mimeType,
      ),
    );
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
      try {
        await _draftStore.clear();
      } catch (_) {
        // Draft lokal opsional.
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
            _StepHeader(
              currentStep: _stepIndex,
              totalSteps: _stepCount,
              titles: _stepTitles,
            ),
            Expanded(
              child: IndexedStack(
                index: _stepIndex,
                children: _category == PawnCategory.elektronik
                    ? <Widget>[
                        _buildElektronikIdentityStep(),
                        _buildElektronikConditionStep(),
                        _buildStep2Upload(),
                        _buildStep3Review(),
                      ]
                    : <Widget>[
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
                        'Berat dan kadar yang kamu masukkan adalah perkiraan sebelum pemeriksaan. Aplikasi tidak menampilkan harga emas real-time. Nilai taksiran final hanya ditentukan setelah pemeriksaan fisik dan persetujuan.',
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
                        'Privasi dokumen: BPKB dan dokumen pendukung hanya dipakai untuk verifikasi, disimpan privat di backend, dan hanya dapat diakses petugas berwenang. Aplikasi tidak melakukan pengecekan legalitas kendaraan otomatis.',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
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

  Widget _buildElektronikIdentityStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      child: Form(
        key: _identityFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepIntro(
              title: 'Identitas Perangkat',
              subtitle:
                  'Pilih jenis perangkat, lalu isi merek dan model sesuai label di perangkat.',
            ),
            _ChoiceChips(
              label: 'Jenis Perangkat *',
              helper: 'Pilih salah satu. Pilih Lainnya untuk jenis di luar daftar.',
              choices: const ['Smartphone', 'Laptop', 'Kamera', 'Tablet', 'Lainnya'],
              selected: _deviceTypeChoice,
              onSelected: (String value) {
                setState(() {
                  _deviceTypeChoice = value;
                  _deviceTypeCtrl.text = value == 'Lainnya' ? '' : value;
                  _saveDraft();
                });
              },
            ),
            if (_deviceTypeChoice == 'Lainnya') ...[
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Jenis Perangkat Lainnya *',
                controller: _deviceTypeCtrl,
                hint: 'Contoh: Smartwatch, Drone',
                helperText: 'Wajib diisi bila memilih Lainnya.',
                validator: (v) => AppValidators.requiredField(
                  v,
                  label: 'Jenis perangkat',
                ),
                onChanged: (_) {
                  setState(() {});
                  _saveDraft();
                },
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Merek *',
              controller: _brandCtrl,
              hint: 'Contoh: Apple, Samsung, Asus',
              helperText: 'Nama produsen perangkat.',
              validator: (v) =>
                  AppValidators.requiredField(v, label: 'Merek'),
              onChanged: (_) {
                  setState(() {});
                  _saveDraft();
                },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Model / Tipe *',
              controller: _modelCtrl,
              hint: 'Contoh: MacBook Air M2 256GB',
              helperText: 'Lihat label perangkat atau pengaturan sistem.',
              validator: (v) =>
                  AppValidators.requiredField(v, label: 'Model/tipe'),
              onChanged: (_) {
                  setState(() {});
                  _saveDraft();
                },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Tahun Pembelian (Opsional)',
              controller: _purchaseYearCtrl,
              hint: 'Contoh: 2023',
              helperText: 'Tidak wajib; kosongkan bila tidak diketahui.',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _saveDraft(),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildElektronikConditionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.md,
      ),
      child: Form(
        key: _conditionFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _StepIntro(
              title: 'Kondisi & Kelengkapan',
              subtitle:
                  'Jujurkan kondisi perangkat agar penaksiran tidak terhambat.',
            ),
            _ChoiceChips(
              label: 'Kondisi Fisik *',
              helper: 'Pilih kondisi fisik yang paling sesuai.',
              choices: const [
                'Mulus',
                'Ada lecet ringan',
                'Ada penyok/retak',
                'Lainnya',
              ],
              selected: _physicalChoice,
              onSelected: (String value) {
                setState(() {
                  _physicalChoice = value;
                  _physicalCondCtrl.text = value == 'Lainnya' ? '' : value;
                  _saveDraft();
                });
              },
            ),
            if (_physicalChoice == 'Lainnya') ...[
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Kondisi Fisik Lainnya *',
                controller: _physicalCondCtrl,
                hint: 'Jelaskan kondisi fisik perangkat',
                validator: (v) => AppValidators.requiredField(
                  v,
                  label: 'Kondisi fisik',
                ),
                onChanged: (_) {
                  setState(() {});
                  _saveDraft();
                },
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            _ChoiceChips(
              label: 'Kondisi Fungsi *',
              helper: 'Pilih kondisi fungsi perangkat saat ini.',
              choices: const [
                'Normal 100%',
                'Ada kendala kecil',
                'Sebagian tidak berfungsi',
                'Lainnya',
              ],
              selected: _functionChoice,
              onSelected: (String value) {
                setState(() {
                  _functionChoice = value;
                  _funcCondCtrl.text = value == 'Lainnya' ? '' : value;
                  _saveDraft();
                });
              },
            ),
            if (_functionChoice == 'Lainnya') ...[
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Kondisi Fungsi Lainnya *',
                controller: _funcCondCtrl,
                hint: 'Jelaskan fungsi perangkat',
                validator: (v) => AppValidators.requiredField(
                  v,
                  label: 'Kondisi fungsi',
                ),
                onChanged: (_) {
                  setState(() {});
                  _saveDraft();
                },
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            _MultiChoiceChips(
              label: 'Kelengkapan *',
              helper: 'Pilih semua yang disertakan saat pengajuan.',
              choices: const [
                'Unit',
                'Charger',
                'Dus',
                'Kabel',
                'Headset',
                'Aksesori lain',
              ],
              selected: _accessories,
              onToggle: (String value) {
                setState(() {
                  if (_accessories.contains(value)) {
                    _accessories.remove(value);
                  } else {
                    _accessories.add(value);
                  }
                  _accessoriesCtrl.text = _accessories.join(', ');
                  _saveDraft();
                });
              },
              errorText: _accessories.isEmpty
                  ? 'Pilih minimal satu kelengkapan.'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Deskripsi Tambahan *',
              controller: _notesCtrl,
              hint: 'Contoh: Baterai 90%, layar tanpa goresan',
              helperText: 'Jelangkan detail yang belum tercakup di atas.',
              maxLines: 3,
              validator: (v) => AppValidators.requiredField(
                v,
                label: 'Deskripsi tambahan',
              ),
              onChanged: (_) {
                  setState(() {});
                  _saveDraft();
                },
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Nomor Seri / IMEI (Opsional)',
              controller: _serialCtrl,
              hint: 'Untuk membantu proses verifikasi',
              helperText: 'Data sensitif hanya dipakai untuk verifikasi.',
              onChanged: (_) => _saveDraft(),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Perkiraan Nilai Barang (Opsional)',
              controller: _estimatedValueCtrl,
              hint: 'Contoh: 5000000',
              helperText: 'Input kamu sendiri; aplikasi tidak menaksir otomatis.',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _saveDraft(),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEmasFields() {
    return [
      _ChoiceChips(
        label: 'Jenis Emas / Perhiasan *',
        helper: 'Pilih jenis yang paling sesuai.',
        choices: const [
          'Cincin',
          'Kalung',
          'Gelang',
          'Anting',
          'Logam Mulia',
          'Lainnya',
        ],
        selected: _goldTypeChoice,
        onSelected: (String value) {
          setState(() {
            _goldTypeChoice = value;
            _goldTypeCtrl.text = value == 'Lainnya' ? '' : value;
            _saveDraft();
          });
        },
      ),
      if (_goldTypeChoice == 'Lainnya') ...[
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Jenis Emas Lainnya *',
          controller: _goldTypeCtrl,
          hint: 'Contoh: Bros, Liontin',
          helperText: 'Wajib diisi bila memilih Lainnya.',
          validator: (v) =>
              AppValidators.requiredField(v, label: 'Jenis emas'),
          onChanged: (_) {
            setState(() {});
            _saveDraft();
          },
        ),
      ],
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Kadar / Karat (Opsional)',
        controller: _karatCtrl,
        hint: 'Contoh: 22 Karat / 99.9%',
        helperText: 'Perkiraan; kosongkan bila tidak diketahui.',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,%A-Za-z ]')),
        ],
        validator: AppValidators.karat,
        onChanged: (_) {
          setState(() {});
          _saveDraft();
        },
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Perkiraan Berat (Gram) *',
        controller: _weightCtrl,
        hint: 'Contoh: 5.5',
        helperText: 'Perkiraan sebelum pemeriksaan; rentang 0,01–10.000 gram.',
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+[.,]?\d*$')),
        ],
        validator: (v) => AppValidators.positiveDecimal(
          v,
          label: 'Berat',
          min: 0.01,
          max: 10000,
        ),
        onChanged: (_) {
          setState(() {});
          _saveDraft();
        },
      ),
      const SizedBox(height: AppSpacing.md),
      _ChoiceChips(
        label: 'Kondisi Barang *',
        helper: 'Pilih kondisi yang paling menggambarkan barang.',
        choices: const [
          'Baik',
          'Ada goresan ringan',
          'Penyok / berubah bentuk',
          'Lainnya',
        ],
        selected: _goldConditionChoice,
        onSelected: (String value) {
          setState(() {
            _goldConditionChoice = value;
            _goldCondCtrl.text = value == 'Lainnya' ? '' : value;
            _saveDraft();
          });
        },
      ),
      if (_goldConditionChoice == 'Lainnya') ...[
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Kondisi Barang Lainnya *',
          controller: _goldCondCtrl,
          hint: 'Jelaskan kondisi barang',
          validator: (v) =>
              AppValidators.requiredField(v, label: 'Kondisi barang'),
          onChanged: (_) {
            setState(() {});
            _saveDraft();
          },
        ),
      ],
    ];
  }

  List<Widget> _buildBpkbFields() {
    return [
      _ChoiceChips(
        label: 'Jenis Kendaraan *',
        helper: 'Pilih jenis kendaraan sesuai BPKB.',
        choices: const ['Sepeda Motor', 'Mobil', 'Lainnya'],
        selected: _vehicleTypeChoice,
        onSelected: (String value) {
          setState(() {
            _vehicleTypeChoice = value;
            _vehicleTypeCtrl.text = value == 'Lainnya' ? '' : value;
            _saveDraft();
          });
        },
      ),
      if (_vehicleTypeChoice == 'Lainnya') ...[
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          label: 'Jenis Kendaraan Lainnya *',
          controller: _vehicleTypeCtrl,
          hint: 'Contoh: Truk, Bus',
          validator: (v) =>
              AppValidators.requiredField(v, label: 'Jenis kendaraan'),
          onChanged: (_) {
            setState(() {});
            _saveDraft();
          },
        ),
      ],
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Merek *',
        controller: _vehicleBrandCtrl,
        hint: 'Contoh: Honda, Toyota',
        helperText: 'Merek sesuai dokumen kendaraan.',
        validator: (v) => AppValidators.requiredField(v, label: 'Merek'),
        onChanged: (_) {
          setState(() {});
          _saveDraft();
        },
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Model / Tipe *',
        controller: _vehicleModelCtrl,
        hint: 'Contoh: Vario 160 CBS, Avanza G',
        validator: (v) => AppValidators.requiredField(v, label: 'Model/tipe'),
        onChanged: (_) {
          setState(() {});
          _saveDraft();
        },
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Tahun Kendaraan *',
        controller: _vehicleYearCtrl,
        hint: 'Contoh: 2024',
        helperText: '4 digit, antara 1980 dan tahun berjalan + 1.',
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: AppValidators.vehicleYear,
        onChanged: (_) {
          setState(() {});
          _saveDraft();
        },
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Nomor Polisi *',
        controller: _plateCtrl,
        hint: 'Contoh: B 4123 DEMO',
        helperText:
            'Format B 4123 DEMO. Di ringkasan ditampilkan sebagian saja.',
        textCapitalization: TextCapitalization.characters,
        validator: AppValidators.plateNumber,
        onChanged: (_) {
          setState(() {});
          _saveDraft();
        },
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        label: 'Nama Pemilik Sesuai Dokumen *',
        controller: _ownerNameCtrl,
        hint: 'Nama yang tertera pada BPKB',
        helperText: 'Samakan dengan kepemilikan pada dokumen.',
        validator: (v) => AppValidators.requiredField(
          v,
          label: 'Nama pemilik dokumen',
        ),
        onChanged: (_) {
          setState(() {});
          _saveDraft();
        },
      ),
    ];
  }

  Widget _buildStep2Upload() {
    final int requiredCount =
        _docSlots.where((slot) => slot.required).length;
    final int addedCount =
        _docSlots.where((slot) => _uploadedDocs.containsKey(slot.title)).length;
    final int readyCount = _docSlots
        .where((slot) => _isDocumentReady(_uploadedDocs[slot.title]))
        .length;

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
          'Pilih kamera atau galeri/berkas. Format JPG/PNG/PDF, maks 5 MB.',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Icon(
              readyCount >= requiredCount
                  ? Icons.check_circle_outline_rounded
                  : Icons.info_outline_rounded,
              size: 16,
              color: readyCount >= requiredCount
                  ? AppColors.success
                  : AppColors.primary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$addedCount berkas ditambahkan • $readyCount dari '
                '$requiredCount berkas wajib siap',
                style: AppTextStyles.captionBold.copyWith(
                  color: readyCount >= requiredCount
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        if (_uploadService.isMock) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 22),
            child: Text(
              'Mode demo: berkas belum dikirim atau tersimpan di server.',
              style: AppTextStyles.caption.copyWith(color: AppColors.warning),
            ),
          ),
        ],
        if (_category == PawnCategory.bpkb) ...[
          const SizedBox(height: AppSpacing.md),
          AppCard(
            backgroundColor: AppColors.primarySoft,
            borderColor: AppColors.primary.withValues(alpha: 0.2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.lock_outline_rounded,
                    size: 18, color: AppColors.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Berkas sensitif disimpan privat dan hanya diakses petugas '
                    'berwenang. Nomor dokumen penuh tidak ditampilkan di halaman umum.',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        for (final slot in _docSlots) ...[
          DocumentUploadTile(
            title: slot.title,
            subtitle: slot.subtitle,
            isRequired: slot.required,
            isSensitive: slot.isSensitive,
            fileName: _uploadedDocs[slot.title]?.fileName,
            fileSizeLabel: _uploadedDocs[slot.title]?.sizeLabel,
            previewBytes: _uploadedDocs[slot.title]?.previewBytes,
            uploadProgress: _uploadedDocs[slot.title]?.uploadProgress,
            uploadError: _uploadedDocs[slot.title]?.uploadError,
            isDemo: _uploadedDocs[slot.title]?.isDemo ?? false,
            isUploadedToServer:
                _uploadedDocs[slot.title]?.isUploadedToServer ?? false,
            isUploading: _uploadedDocs[slot.title]?.uploadProgress != null &&
                _uploadedDocs[slot.title]!.uploadProgress! < 1,
            errorText: (_showUploadValidation &&
                        slot.required &&
                        !_isDocumentReady(_uploadedDocs[slot.title]))
                    ? 'Berkas ini wajib ditambahkan'
                    : _selectionErrors[slot.title],
            onPick: () => _pickDocument(slot),
            onReplace: () => _pickDocument(slot),
            onRemove: () {
              setState(() {
                _uploadedDocs.remove(slot.title);
                _selectionErrors.remove(slot.title);
              });
            },
            onRetry: _uploadedDocs[slot.title]?.hasUploadError == true
                ? () => _retryUpload(slot)
                : null,
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
                          _category == PawnCategory.bpkb &&
                                  entry.key == 'Nomor Polisi'
                              ? AppFormatters.maskPlate(entry.value)
                              : entry.value,
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
              label: _stepIndex == _reviewStep
                  ? (_isRevisionMode ? 'Kirim Perbaikan' : 'Kirim Pengajuan')
                  : 'Lanjutkan',
              isLoading: _isSubmitting,
              onPressed: _stepIndex == _reviewStep
                  ? (_isCurrentStepValid ? _submitFinal : null)
                  : (_isCurrentStepValid ? _nextStep : null),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIntro extends StatelessWidget {
  const _StepIntro({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.sectionHeading),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.bodySecondary),
        ],
      ),
    );
  }
}

class _ChoiceChips extends StatelessWidget {
  const _ChoiceChips({
    required this.label,
    required this.helper,
    required this.choices,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final String helper;
  final List<String> choices;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        const SizedBox(height: AppSpacing.xs + 2),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final String choice in choices)
              ChoiceChip(
                label: Text(choice),
                selected: selected == choice,
                onSelected: (_) => onSelected(choice),
                selectedColor: AppColors.primarySoft,
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: selected == choice
                      ? AppColors.primary
                      : AppColors.border,
                ),
                labelStyle: AppTextStyles.caption.copyWith(
                  color: selected == choice
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight:
                      selected == choice ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(helper, style: AppTextStyles.caption),
      ],
    );
  }
}

class _MultiChoiceChips extends StatelessWidget {
  const _MultiChoiceChips({
    required this.label,
    required this.helper,
    required this.choices,
    required this.selected,
    required this.onToggle,
    this.errorText,
  });

  final String label;
  final String helper;
  final List<String> choices;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        const SizedBox(height: AppSpacing.xs + 2),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final String choice in choices)
              FilterChip(
                label: Text(choice),
                selected: selected.contains(choice),
                onSelected: (_) => onToggle(choice),
                selectedColor: AppColors.primarySoft,
                backgroundColor: AppColors.surface,
                side: BorderSide(
                  color: selected.contains(choice)
                      ? AppColors.primary
                      : AppColors.border,
                ),
                labelStyle: AppTextStyles.caption.copyWith(
                  color: selected.contains(choice)
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontWeight: selected.contains(choice)
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(errorText ?? helper,
            style: AppTextStyles.caption.copyWith(
              color: errorText == null ? null : AppColors.danger,
            )),
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.currentStep,
    required this.titles,
    required this.totalSteps,
  });

  final int currentStep;
  final List<String> titles;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final int safeStep = currentStep.clamp(0, totalSteps - 1);
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
                'Langkah ${safeStep + 1} dari $totalSteps • ${titles[safeStep]}',
                style: AppTextStyles.captionBold.copyWith(
                  color: AppColors.primary,
                ),
              ),
              Text(
                '${(((safeStep + 1) / totalSteps) * 100).round()}%',
                style: AppTextStyles.captionBold,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (safeStep + 1) / totalSteps,
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
