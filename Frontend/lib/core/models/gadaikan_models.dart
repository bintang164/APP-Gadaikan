import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../widgets/status_badge.dart';

enum PawnCategory {
  elektronik,
  emas,
  bpkb;

  String get label => switch (this) {
        PawnCategory.elektronik => 'Elektronik',
        PawnCategory.emas => 'Emas',
        PawnCategory.bpkb => 'BPKB Kendaraan',
      };

  String get shortSubtitle => switch (this) {
        PawnCategory.elektronik => 'Smartphone, laptop, kamera, dan gadget',
        PawnCategory.emas => 'Perhiasan emas atau logam mulia',
        PawnCategory.bpkb => 'BPKB motor atau mobil atas nama pribadi',
      };

  IconData get icon => switch (this) {
        PawnCategory.elektronik => Icons.devices_rounded,
        PawnCategory.emas => Icons.diamond_outlined,
        PawnCategory.bpkb => Icons.directions_car_outlined,
      };

  /// ID stabil untuk API dan draft lokal.
  String get apiId => name;

  static PawnCategory? fromId(String? id) {
    if (id == null) return null;
    for (final PawnCategory category in PawnCategory.values) {
      if (category.apiId == id) return category;
    }
    return null;
  }

  /// Persyaratan yang ditampilkan sebelum form dimulai.
  List<String> get requirements => switch (this) {
        PawnCategory.elektronik => const [
            'Jenis, merek, dan model perangkat',
            'Kondisi fisik dan fungsi perangkat',
            'Kelengkapan (charger, dus, aksesori)',
            'Foto barang dari beberapa sisi',
          ],
        PawnCategory.emas => const [
            'Jenis emas/perhiasan dan perkiraan berat',
            'Kadar/karat bila diketahui',
            'Foto barang dengan pencahayaan jelas',
            'Bukti pembelian/sertifikat bila tersedia',
          ],
        PawnCategory.bpkb => const [
            'Jenis kendaraan, merek/model, dan tahun',
            'Nomor polisi serta nama pemilik sesuai dokumen',
            'Foto BPKB dan dokumen pendukung',
            'Foto kendaraan tampak depan/samping',
          ],
      };
}

/// Kategori gadai dari API (atau mock berlabel). Ikon dipetakan dari [category]
/// agar tidak bergantung pada aset/icon dari backend.
class PawnCategoryInfo {
  const PawnCategoryInfo({
    required this.category,
    required this.name,
    required this.description,
    required this.requirements,
    this.isDemo = false,
  });

  final PawnCategory category;
  final String name;
  final String description;
  final List<String> requirements;
  final bool isDemo;

  factory PawnCategoryInfo.fromJson(Map<String, dynamic> json) {
    final String id = '${json['id'] ?? json['code'] ?? ''}';
    final PawnCategory category =
        PawnCategory.fromId(id) ?? PawnCategory.elektronik;
    final Object? rawRequirements = json['requirements'];
    final List<String> requirements = rawRequirements is List
        ? rawRequirements.map((Object? item) => '$item').toList()
        : category.requirements;
    return PawnCategoryInfo(
      category: category,
      name: '${json['name'] ?? json['label'] ?? category.label}',
      description: '${json['description'] ?? category.shortSubtitle}',
      requirements: requirements,
      isDemo: json['is_demo'] == true,
    );
  }
}

enum ApplicationStatus {
  draft,
  submitted,
  underReview,
  revisionRequired,
  approved,
  rejected,
  offerAccepted,
  offerDeclined,
  cancelled;

  String get label => switch (this) {
        ApplicationStatus.draft => 'Draf',
        ApplicationStatus.submitted => 'Dikirim',
        ApplicationStatus.underReview => 'Sedang Ditinjau',
        ApplicationStatus.revisionRequired => 'Perlu Perbaikan',
        ApplicationStatus.approved => 'Disetujui',
        ApplicationStatus.rejected => 'Ditolak',
        ApplicationStatus.offerAccepted => 'Penawaran Diterima',
        ApplicationStatus.offerDeclined => 'Penawaran Ditolak',
        ApplicationStatus.cancelled => 'Dibatalkan',
      };

  StatusTone get tone => switch (this) {
        ApplicationStatus.draft => StatusTone.neutral,
        ApplicationStatus.submitted => StatusTone.info,
        ApplicationStatus.underReview => StatusTone.warning,
        ApplicationStatus.revisionRequired => StatusTone.warning,
        ApplicationStatus.approved => StatusTone.success,
        ApplicationStatus.rejected => StatusTone.danger,
        ApplicationStatus.offerAccepted => StatusTone.success,
        ApplicationStatus.offerDeclined => StatusTone.neutral,
        ApplicationStatus.cancelled => StatusTone.neutral,
      };

  bool get isPendingAction =>
      this == ApplicationStatus.submitted ||
      this == ApplicationStatus.underReview ||
      this == ApplicationStatus.revisionRequired ||
      this == ApplicationStatus.approved;
}

enum TransactionStatus {
  active,
  paymentPending,
  paidOff,
  overdue,
  closed;

  String get label => switch (this) {
        TransactionStatus.active => 'Aktif',
        TransactionStatus.paymentPending => 'Menunggu Konfirmasi',
        TransactionStatus.paidOff => 'Lunas',
        TransactionStatus.overdue => 'Jatuh Tempo',
        TransactionStatus.closed => 'Ditutup',
      };

  StatusTone get tone => switch (this) {
        TransactionStatus.active => StatusTone.info,
        TransactionStatus.paymentPending => StatusTone.warning,
        TransactionStatus.paidOff => StatusTone.success,
        TransactionStatus.overdue => StatusTone.danger,
        TransactionStatus.closed => StatusTone.neutral,
      };
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
  });

  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;

  UserProfile copyWith({
    String? name,
    String? phone,
    String? email,
    String? address,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }
}

class PawnDocument {
  const PawnDocument({
    required this.id,
    required this.label,
    required this.fileName,
    required this.sizeLabel,
    this.isSensitive = false,
    this.localPath,
    this.mimeType,
    this.fileSizeBytes,
    this.uploadProgress,
    this.uploadError,
    this.isUploadedToServer = false,
    this.isDemo = false,
    this.previewBytes,
    this.serverId,
  });

  final String id;
  final String label;
  final String fileName;
  final String sizeLabel;
  final bool isSensitive;

  /// Path lokal (privat) dari picker; tidak pernah dipublikasikan di UI.
  final String? localPath;
  final String? mimeType;
  final int? fileSizeBytes;

  /// Progres 0..1 saat mengunggah; null bila tidak dalam proses.
  final double? uploadProgress;
  final String? uploadError;

  /// True hanya jika server benar-benar menyimpan berkas.
  final bool isUploadedToServer;

  /// True untuk berkas mode demo yang belum tersimpan di server.
  final bool isDemo;

  /// Preview thumbnail dari picker (tidak dipublikasikan).
  final Uint8List? previewBytes;

  /// ID metadata berkas dari server (bukan URL publik).
  final String? serverId;

  bool get hasUploadError => uploadError != null && uploadError!.isNotEmpty;

  PawnDocument copyWith({
    String? fileName,
    String? sizeLabel,
    String? localPath,
    String? mimeType,
    int? fileSizeBytes,
    double? uploadProgress,
    String? uploadError,
    bool? isUploadedToServer,
    bool? isDemo,
    Uint8List? previewBytes,
    String? serverId,
    bool clearUploadProgress = false,
    bool clearUploadError = false,
  }) {
    return PawnDocument(
      id: id,
      label: label,
      fileName: fileName ?? this.fileName,
      sizeLabel: sizeLabel ?? this.sizeLabel,
      isSensitive: isSensitive,
      localPath: localPath ?? this.localPath,
      mimeType: mimeType ?? this.mimeType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      uploadProgress:
          clearUploadProgress ? null : (uploadProgress ?? this.uploadProgress),
      uploadError: clearUploadError ? null : (uploadError ?? this.uploadError),
      isUploadedToServer: isUploadedToServer ?? this.isUploadedToServer,
      isDemo: isDemo ?? this.isDemo,
      previewBytes: previewBytes ?? this.previewBytes,
      serverId: serverId ?? this.serverId,
    );
  }
}

/// Halaman daftar pengajuan (bisa dari API atau mock berlabel).
class PagedApplications {
  const PagedApplications({
    required this.items,
    required this.page,
    required this.perPage,
    required this.total,
    this.isDemo = false,
  });

  final List<PawnApplication> items;
  final int page;
  final int perPage;
  final int total;
  final bool isDemo;

  bool get hasMore => page * perPage < total;
}

class PawnAssessment {
  const PawnAssessment({
    required this.assessedValue,
    required this.approvedPrincipal,
    required this.serviceFee,
    required this.tenorDays,
    required this.startDate,
    required this.dueDate,
    this.notes,
  });

  final double assessedValue;
  final double approvedPrincipal;
  final double serviceFee;
  final int tenorDays;
  final DateTime startDate;
  final DateTime dueDate;
  final String? notes;

  double get totalRepayment => approvedPrincipal + serviceFee;
}

class ApplicationStatusHistory {
  const ApplicationStatusHistory({
    required this.status,
    required this.title,
    required this.note,
    required this.timestamp,
  });

  final ApplicationStatus status;
  final String title;
  final String note;
  final DateTime timestamp;
}

class PawnApplication {
  const PawnApplication({
    required this.id,
    required this.code,
    required this.category,
    required this.itemTitle,
    required this.itemDetails,
    required this.documents,
    required this.status,
    required this.statusHistory,
    required this.createdAt,
    required this.updatedAt,
    this.estimatedUserValue,
    this.preferredTenorDays,
    this.adminNote,
    this.assessment,
  });

  final String id;
  final String code;
  final PawnCategory category;
  final String itemTitle;
  final Map<String, String> itemDetails;
  final List<PawnDocument> documents;
  final ApplicationStatus status;
  final List<ApplicationStatusHistory> statusHistory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? estimatedUserValue;
  final int? preferredTenorDays;
  final String? adminNote;
  final PawnAssessment? assessment;

  factory PawnApplication.fromApiJson(Map<String, dynamic> json) {
    final Object? rawDetails = json['item_details'] ?? json['details'];
    final Map<String, String> details = <String, String>{};
    if (rawDetails is Map) {
      rawDetails.forEach((Object? key, Object? value) {
        details['$key'] = '$value';
      });
    }

    final Object? rawDocs = json['documents'];
    final List<PawnDocument> documents = <PawnDocument>[];
    if (rawDocs is List) {
      for (final Object? item in rawDocs) {
        if (item is! Map) continue;
        final Map<String, dynamic> doc = Map<String, dynamic>.from(item);
        documents.add(
          PawnDocument(
            id: '${doc['id'] ?? doc['document_id'] ?? ''}',
            label: '${doc['label'] ?? doc['type'] ?? 'Berkas'}',
            fileName: '${doc['file_name'] ?? doc['name'] ?? 'berkas'}',
            sizeLabel: '${doc['size_label'] ?? doc['size'] ?? ''}',
            isSensitive: doc['is_sensitive'] == true,
            serverId: doc['id']?.toString(),
          ),
        );
      }
    }

    final Object? rawHistory = json['status_history'];
    final List<ApplicationStatusHistory> history = <ApplicationStatusHistory>[];
    if (rawHistory is List) {
      for (final Object? item in rawHistory) {
        if (item is! Map) continue;
        final Map<String, dynamic> entry = Map<String, dynamic>.from(item);
        history.add(
          ApplicationStatusHistory(
            status: _statusFromApi('${entry['status'] ?? 'submitted'}'),
            title: '${entry['title'] ?? entry['status'] ?? 'Diperbarui'}',
            note: '${entry['note'] ?? ''}',
            timestamp: DateTime.tryParse('${entry['timestamp'] ?? ''}') ??
                DateTime.now(),
          ),
        );
      }
    }

    final DateTime now = DateTime.now();
    return PawnApplication(
      id: '${json['id'] ?? json['application_id'] ?? ''}',
      code: '${json['code'] ?? json['number'] ?? ''}',
      category: PawnCategory.fromId(
            '${json['category'] ?? json['category_id'] ?? ''}',
          ) ??
          PawnCategory.elektronik,
      itemTitle: '${json['item_title'] ?? json['title'] ?? ''}',
      itemDetails: details,
      documents: documents,
      status: _statusFromApi('${json['status'] ?? 'submitted'}'),
      statusHistory: history,
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}') ?? now,
      updatedAt: DateTime.tryParse('${json['updated_at'] ?? ''}') ?? now,
      estimatedUserValue: (json['estimated_value'] is num)
          ? (json['estimated_value'] as num).toDouble()
          : null,
      preferredTenorDays: json['preferred_tenor_days'] is num
          ? (json['preferred_tenor_days'] as num).toInt()
          : null,
      adminNote: json['admin_note']?.toString(),
      assessment: json['assessment'] is Map
          ? _assessmentFromApi(Map<String, dynamic>.from(json['assessment'] as Map))
          : null,
    );
  }

  static PawnAssessment _assessmentFromApi(Map<String, dynamic> json) {
    final DateTime now = DateTime.now();
    return PawnAssessment(
      assessedValue: (json['assessed_value'] is num)
          ? (json['assessed_value'] as num).toDouble()
          : 0,
      approvedPrincipal: (json['approved_principal'] is num)
          ? (json['approved_principal'] as num).toDouble()
          : 0,
      serviceFee: (json['service_fee'] is num)
          ? (json['service_fee'] as num).toDouble()
          : 0,
      tenorDays: json['tenor_days'] is num ? (json['tenor_days'] as num).toInt() : 0,
      startDate: DateTime.tryParse('${json['start_date'] ?? ''}') ?? now,
      dueDate: DateTime.tryParse('${json['due_date'] ?? ''}') ?? now,
      notes: json['notes']?.toString(),
    );
  }

  static ApplicationStatus _statusFromApi(String raw) {
    final String normalized = raw
        .replaceAll('-', '_')
        .replaceAll(' ', '_')
        .toLowerCase();
    for (final ApplicationStatus status in ApplicationStatus.values) {
      if (_toSnake(status.name) == normalized || status.name == normalized) {
        return status;
      }
    }
    return ApplicationStatus.submitted;
  }

  static String _toSnake(String value) {
    final RegExp regex = RegExp(r'(?<!^)(?=[A-Z])');
    return value.replaceAllMapped(regex, (Match m) => '_').toLowerCase();
  }

  PawnApplication copyWith({
    String? itemTitle,
    Map<String, String>? itemDetails,
    List<PawnDocument>? documents,
    ApplicationStatus? status,
    List<ApplicationStatusHistory>? statusHistory,
    DateTime? updatedAt,
    double? estimatedUserValue,
    int? preferredTenorDays,
    String? adminNote,
    PawnAssessment? assessment,
  }) {
    return PawnApplication(
      id: id,
      code: code,
      category: category,
      itemTitle: itemTitle ?? this.itemTitle,
      itemDetails: itemDetails ?? this.itemDetails,
      documents: documents ?? this.documents,
      status: status ?? this.status,
      statusHistory: statusHistory ?? this.statusHistory,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      estimatedUserValue: estimatedUserValue ?? this.estimatedUserValue,
      preferredTenorDays: preferredTenorDays ?? this.preferredTenorDays,
      adminNote: adminNote ?? this.adminNote,
      assessment: assessment ?? this.assessment,
    );
  }
}

class DemoPayment {
  const DemoPayment({
    required this.id,
    required this.amount,
    required this.method,
    required this.paidAt,
    this.note,
  });

  final String id;
  final double amount;
  final String method;
  final DateTime paidAt;
  final String? note;
}

class PawnTransaction {
  const PawnTransaction({
    required this.id,
    required this.code,
    required this.applicationId,
    required this.itemTitle,
    required this.category,
    required this.principalAmount,
    required this.feeAmount,
    required this.paidAmount,
    required this.tenorDays,
    required this.startDate,
    required this.dueDate,
    required this.status,
    required this.payments,
  });

  final String id;
  final String code;
  final String applicationId;
  final String itemTitle;
  final PawnCategory category;
  final double principalAmount;
  final double feeAmount;
  final double paidAmount;
  final int tenorDays;
  final DateTime startDate;
  final DateTime dueDate;
  final TransactionStatus status;
  final List<DemoPayment> payments;

  double get totalDue => principalAmount + feeAmount;
  double get remainingAmount =>
      (totalDue - paidAmount).clamp(0, double.infinity).toDouble();

  PawnTransaction copyWith({
    double? paidAmount,
    TransactionStatus? status,
    List<DemoPayment>? payments,
  }) {
    return PawnTransaction(
      id: id,
      code: code,
      applicationId: applicationId,
      itemTitle: itemTitle,
      category: category,
      principalAmount: principalAmount,
      feeAmount: feeAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      tenorDays: tenorDays,
      startDate: startDate,
      dueDate: dueDate,
      status: status ?? this.status,
      payments: payments ?? this.payments,
    );
  }
}

class SimulationConfig {
  const SimulationConfig({
    required this.plafonPercentageByCategory,
    required this.feeRatePerPeriod,
    required this.periodDays,
    required this.allowedTenorDays,
    required this.minEstimatedValue,
    required this.maxEstimatedValue,
    required this.disclaimer,
    this.isDemo = false,
  });

  final Map<PawnCategory, double> plafonPercentageByCategory;
  final double feeRatePerPeriod;
  final int periodDays;
  final List<int> allowedTenorDays;
  final double minEstimatedValue;
  final double maxEstimatedValue;
  final String disclaimer;

  /// True bila parameter berasal dari simulasi demo, bukan kebijakan
  /// bisnis resmi/backend.
  final bool isDemo;

  SimulationResult calculate({
    required PawnCategory category,
    required double estimatedValue,
    required int tenorDays,
  }) {
    final pct = plafonPercentageByCategory[category] ?? 0.75;
    final principal = estimatedValue * pct;
    final periods = tenorDays / periodDays;
    final fee = principal * feeRatePerPeriod * periods;
    final total = principal + fee;
    return SimulationResult(
      estimatedPrincipal: principal,
      estimatedFee: fee,
      estimatedTotal: total,
      plafonPercentage: pct,
    );
  }
}

class SimulationResult {
  const SimulationResult({
    required this.estimatedPrincipal,
    required this.estimatedFee,
    required this.estimatedTotal,
    required this.plafonPercentage,
  });

  final double estimatedPrincipal;
  final double estimatedFee;
  final double estimatedTotal;
  final double plafonPercentage;
}

class OutletInfo {
  const OutletInfo({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.hours,
    required this.phone,
  });

  final String id;
  final String name;
  final String address;
  final String city;
  final String hours;
  final String phone;
}

class PromoInfo {
  const PromoInfo({
    required this.id,
    required this.title,
    required this.period,
    required this.summary,
    required this.terms,
    this.badgeText = 'Simulasi Demo',
  });

  final String id;
  final String title;
  final String period;
  final String summary;
  final String terms;
  final String badgeText;
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.applicationId,
    this.transactionId,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? applicationId;
  final String? transactionId;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      applicationId: applicationId,
      transactionId: transactionId,
    );
  }
}

class FaqItem {
  const FaqItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}
