import '../auth/auth_repository.dart';
import '../models/auth_user.dart';
import '../models/gadaikan_models.dart';

/// Abstraction for Gadaikan data operations.
/// Currently backed by [MockGadaikanRepository]; ready to swap with Laravel REST API.
abstract class GadaikanRepository {
  Future<UserProfile?> restoreSession();
  Future<UserProfile> login({required String identifier, required String password});
  Future<UserProfile> register({
    required String name,
    required String phone,
    String? email,
    required String password,
  });
  Future<void> logout();
  Future<UserProfile> updateProfile(UserProfile profile);

  Future<SimulationConfig> getSimulationConfig();
  Future<List<PawnCategoryInfo>> getCategories();
  Future<List<PawnApplication>> getApplications();

  /// Detail terbaru satu pengajuan (termasuk riwayat status dari server).
  Future<PawnApplication> getApplicationDetail(String id);

  /// True bila data berasal dari backend (bukan mode demo lokal).
  bool get usesBackend;

  /// Daftar pengajuan dengan filter status dan pagination.
  Future<PagedApplications> getApplicationsPage({
    String? status,
    int page = 1,
    int perPage = 10,
  });

  Future<PawnApplication> submitApplication({
    required PawnCategory category,
    required String itemTitle,
    required Map<String, String> itemDetails,
    required List<PawnDocument> documents,
    double? estimatedValue,
    int? preferredTenorDays,
  });
  Future<PawnApplication> reviseApplication({
    required String applicationId,
    required String itemTitle,
    required Map<String, String> itemDetails,
    required List<PawnDocument> documents,
  });
  Future<PawnTransaction> acceptOffer(String applicationId);
  Future<PawnApplication> declineOffer(String applicationId);

  Future<List<PawnTransaction>> getTransactions();
  Future<PawnTransaction> recordDemoPayment({
    required String transactionId,
    required double amount,
    required String method,
  });

  Future<List<OutletInfo>> getOutlets();
  Future<List<PromoInfo>> getPromotions();
  Future<List<AppNotification>> getNotifications();
  Future<void> markNotificationRead(String notificationId);
  Future<List<FaqItem>> getFaqs();
}

class MockGadaikanRepository implements GadaikanRepository {
  /// Jika disediakan, operasi login/register/logout/restoreSession
  /// didelegasikan ke lapisan autentikasi (token aman + dukungan API).
  /// Jika null, sesi demo lokal dipakai (misalnya di widget test).
  final AuthRepository? authRepository;

  MockGadaikanRepository({this.authRepository});

  UserProfile? _currentUser;
  int _sequence = 4;

  static const SimulationConfig _config = SimulationConfig(
    plafonPercentageByCategory: {
      PawnCategory.elektronik: 0.70,
      PawnCategory.emas: 0.85,
      PawnCategory.bpkb: 0.75,
    },
    feeRatePerPeriod: 0.015,
    periodDays: 15,
    allowedTenorDays: [15, 30, 60, 90],
    minEstimatedValue: 300000,
    maxEstimatedValue: 100000000,
    disclaimer:
        'Hasil simulasi, bukan penawaran final. Tarif dan plafon akhir ditentukan setelah pemeriksaan fisik dan dokumen.',
    isDemo: true,
  );

  final List<PawnApplication> _applications = [
    PawnApplication(
      id: 'app-1',
      code: 'GDK-2026-0001',
      category: PawnCategory.elektronik,
      itemTitle: 'MacBook Air M2 2023 256GB',
      itemDetails: const {
        'Jenis Perangkat': 'Laptop',
        'Merek': 'Apple',
        'Model/Tipe': 'MacBook Air M2 (2023)',
        'Tahun Pembelian': '2023',
        'Kondisi Fisik': 'Mulus, minim lecet',
        'Kondisi Fungsi': 'Normal 100%',
        'Kelengkapan': 'Unit, charger original, dus',
        'Nomor Seri': 'SN-DEMO-8821',
      },
      documents: const [
        PawnDocument(
          id: 'doc-1',
          label: 'Foto Barang (Tampak Depan)',
          fileName: 'macbook_depan.jpg',
          sizeLabel: '1.2 MB',
        ),
        PawnDocument(
          id: 'doc-2',
          label: 'Foto Kelengkapan',
          fileName: 'macbook_kelengkapan.jpg',
          sizeLabel: '940 KB',
        ),
      ],
      status: ApplicationStatus.approved,
      estimatedUserValue: 11000000,
      preferredTenorDays: 30,
      adminNote:
          'Barang lolos verifikasi awal. Penawaran plafon dan biaya simulasi siap ditinjau.',
      assessment: PawnAssessment(
        assessedValue: 10500000,
        approvedPrincipal: 7350000,
        serviceFee: 220500,
        tenorDays: 30,
        startDate: DateTime(2026, 11, 25),
        dueDate: DateTime(2026, 12, 25),
        notes: 'Kondisi layar dan baterai baik (simulasi taksiran demo).',
      ),
      statusHistory: [
        ApplicationStatusHistory(
          status: ApplicationStatus.submitted,
          title: 'Pengajuan Dikirim',
          note: 'Data dan foto barang diterima oleh sistem.',
          timestamp: DateTime(2026, 11, 24, 9, 15),
        ),
        ApplicationStatusHistory(
          status: ApplicationStatus.underReview,
          title: 'Sedang Ditinjau',
          note: 'Petugas memeriksa kelengkapan perangkat dan foto.',
          timestamp: DateTime(2026, 11, 24, 13, 40),
        ),
        ApplicationStatusHistory(
          status: ApplicationStatus.approved,
          title: 'Penawaran Tersedia',
          note: 'Penaksiran selesai. Silakan terima atau tolak penawaran.',
          timestamp: DateTime(2026, 11, 25, 10, 20),
        ),
      ],
      createdAt: DateTime(2026, 11, 24, 9, 15),
      updatedAt: DateTime(2026, 11, 25, 10, 20),
    ),
    PawnApplication(
      id: 'app-2',
      code: 'GDK-2026-0002',
      category: PawnCategory.emas,
      itemTitle: 'Cincin Emas 22 Karat (5 Gram)',
      itemDetails: const {
        'Jenis Emas': 'Perhiasan Cincin',
        'Kadar/Karat': '22 Karat (Perkiraan)',
        'Berat (gram)': '5.0 gram',
        'Kondisi': 'Baik, tidak penyok',
      },
      documents: const [
        PawnDocument(
          id: 'doc-3',
          label: 'Foto Emas',
          fileName: 'cincin_emas.jpg',
          sizeLabel: '810 KB',
        ),
      ],
      status: ApplicationStatus.revisionRequired,
      estimatedUserValue: 5500000,
      preferredTenorDays: 30,
      adminNote:
          'Mohon unggah foto nota/sertifikat pembelian atau foto ulang timbangan agar lebih jelas.',
      statusHistory: [
        ApplicationStatusHistory(
          status: ApplicationStatus.submitted,
          title: 'Pengajuan Dikirim',
          note: 'Pengajuan emas diterima.',
          timestamp: DateTime(2026, 11, 23, 11, 0),
        ),
        ApplicationStatusHistory(
          status: ApplicationStatus.revisionRequired,
          title: 'Perlu Perbaikan Data',
          note: 'Foto sertifikat atau bukti timbangan kurang jelas.',
          timestamp: DateTime(2026, 11, 23, 15, 30),
        ),
      ],
      createdAt: DateTime(2026, 11, 23, 11, 0),
      updatedAt: DateTime(2026, 11, 23, 15, 30),
    ),
    PawnApplication(
      id: 'app-3',
      code: 'GDK-2026-0003',
      category: PawnCategory.bpkb,
      itemTitle: 'Honda Vario 160 CBS (2024)',
      itemDetails: const {
        'Jenis Kendaraan': 'Sepeda Motor',
        'Merek & Model': 'Honda Vario 160 CBS',
        'Tahun Kendaraan': '2024',
        'Nomor Polisi': 'B 4123 DEMO',
        'Nama Pemilik Dokumen': 'Budi Santoso (Demo)',
      },
      documents: const [
        PawnDocument(
          id: 'doc-4',
          label: 'Foto BPKB',
          fileName: 'bpkb_halaman_utama.jpg',
          sizeLabel: '1.4 MB',
          isSensitive: true,
        ),
        PawnDocument(
          id: 'doc-5',
          label: 'Foto Kendaraan',
          fileName: 'vario_samping.jpg',
          sizeLabel: '1.1 MB',
        ),
      ],
      status: ApplicationStatus.offerAccepted,
      estimatedUserValue: 20000000,
      preferredTenorDays: 60,
      adminNote: 'Penawaran telah disetujui nasabah dan transaksi aktif.',
      assessment: PawnAssessment(
        assessedValue: 18500000,
        approvedPrincipal: 13000000,
        serviceFee: 780000,
        tenorDays: 60,
        startDate: DateTime(2026, 11, 10),
        dueDate: DateTime(2027, 1, 9),
      ),
      statusHistory: [
        ApplicationStatusHistory(
          status: ApplicationStatus.submitted,
          title: 'Pengajuan Dikirim',
          note: 'Dokumen BPKB diterima secara privat.',
          timestamp: DateTime(2026, 11, 9, 10, 0),
        ),
        ApplicationStatusHistory(
          status: ApplicationStatus.approved,
          title: 'Disetujui',
          note: 'Hasil taksiran BPKB tersedia.',
          timestamp: DateTime(2026, 11, 10, 9, 30),
        ),
        ApplicationStatusHistory(
          status: ApplicationStatus.offerAccepted,
          title: 'Penawaran Diterima',
          note: 'Transaksi gadai aktif dibuat.',
          timestamp: DateTime(2026, 11, 10, 14, 0),
        ),
      ],
      createdAt: DateTime(2026, 11, 9, 10, 0),
      updatedAt: DateTime(2026, 11, 10, 14, 0),
    ),
  ];

  final List<PawnTransaction> _transactions = [
    PawnTransaction(
      id: 'trx-1',
      code: 'TRX-2026-0001',
      applicationId: 'app-3',
      itemTitle: 'Honda Vario 160 CBS (2024)',
      category: PawnCategory.bpkb,
      principalAmount: 13000000,
      feeAmount: 780000,
      paidAmount: 2000000,
      tenorDays: 60,
      startDate: DateTime(2026, 11, 10),
      dueDate: DateTime(2027, 1, 9),
      status: TransactionStatus.active,
      payments: [
        DemoPayment(
          id: 'pay-1',
          amount: 2000000,
          method: 'Transfer Bank (Simulasi Demo)',
          paidAt: DateTime(2026, 11, 20, 16, 10),
          note: 'Cicilan simulasi #1',
        ),
      ],
    ),
  ];

  final List<AppNotification> _notifications = [
    AppNotification(
      id: 'notif-1',
      title: 'Penawaran Gadai Tersedia',
      body:
          'Pengajuan GDK-2026-0001 (MacBook Air M2) telah ditaksir. Silakan tinjau penawaran.',
      createdAt: DateTime(2026, 11, 25, 10, 20),
      isRead: false,
      applicationId: 'app-1',
    ),
    AppNotification(
      id: 'notif-2',
      title: 'Pengajuan Perlu Perbaikan',
      body:
          'Pengajuan GDK-2026-0002 membutuhkan foto tambahan dari petugas verifikasi.',
      createdAt: DateTime(2026, 11, 23, 15, 30),
      isRead: false,
      applicationId: 'app-2',
    ),
    AppNotification(
      id: 'notif-3',
      title: 'Pembayaran Simulasi Dicatat',
      body:
          'Pembayaran demo sebesar Rp 2.000.000 pada TRX-2026-0001 telah tercatat.',
      createdAt: DateTime(2026, 11, 20, 16, 12),
      isRead: true,
      transactionId: 'trx-1',
    ),
  ];

  @override
  Future<UserProfile?> restoreSession() async {
    if (authRepository != null) {
      final AuthUser? user = await authRepository!.restoreSession();
      return user == null ? null : _toProfile(user);
    }
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return _currentUser;
  }

  @override
  Future<UserProfile> login({
    required String identifier,
    required String password,
  }) async {
    if (authRepository != null) {
      final AuthUser user = await authRepository!.login(
        identifier: identifier,
        password: password,
      );
      _currentUser = _toProfile(user);
      return _currentUser!;
    }

    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (password.length < 8) {
      throw Exception('Kata sandi minimal 8 karakter.');
    }
    _currentUser = UserProfile(
      id: 'usr-demo-1',
      name: 'Budi Santoso',
      phone: identifier.contains('@') ? '081234567890' : identifier,
      email: identifier.contains('@') ? identifier : 'budi.demo@gadaikan.id',
      address: 'Jl. Merdeka No. 12, Jakarta Selatan',
    );
    return _currentUser!;
  }

  @override
  Future<UserProfile> register({
    required String name,
    required String phone,
    String? email,
    required String password,
  }) async {
    if (authRepository != null) {
      final AuthUser user = await authRepository!.register(
        name: name,
        phone: phone,
        email: email,
        password: password,
      );
      _currentUser = _toProfile(user);
      return _currentUser!;
    }

    await Future<void>.delayed(const Duration(milliseconds: 600));
    _currentUser = UserProfile(
      id: 'usr-demo-1',
      name: name.trim(),
      phone: phone.trim(),
      email: email?.trim().isEmpty ?? true ? null : email!.trim(),
      address: 'Alamat belum diatur',
    );
    return _currentUser!;
  }

  @override
  Future<void> logout() async {
    if (authRepository != null) {
      await authRepository!.logout();
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _currentUser = null;
  }

  UserProfile _toProfile(AuthUser user) {
    return UserProfile(
      id: user.id,
      name: user.safeName,
      phone: user.phone,
      email: user.email,
      address: user.isDemo ? 'Alamat belum diatur (mode demo)' : null,
    );
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _currentUser = profile;
    return profile;
  }

  @override
  Future<SimulationConfig> getSimulationConfig() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _config;
  }

  @override
  Future<List<PawnCategoryInfo>> getCategories() async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    // Data demo berlabel; implementasi API tinggal mengganti method ini.
    return PawnCategory.values
        .map(
          (PawnCategory category) => PawnCategoryInfo(
            category: category,
            name: category.label,
            description: category.shortSubtitle,
            requirements: category.requirements,
            isDemo: true,
          ),
        )
        .toList(growable: false);
  }

  @override
  bool get usesBackend => false;

  @override
  Future<PawnApplication> getApplicationDetail(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _applications.firstWhere(
      (PawnApplication app) => app.id == id,
      orElse: () => throw Exception('Pengajuan tidak ditemukan.'),
    );
  }

  @override
  Future<List<PawnApplication>> getApplications() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List<PawnApplication>.unmodifiable(_applications);
  }

  @override
  Future<PagedApplications> getApplicationsPage({
    String? status,
    int page = 1,
    int perPage = 10,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final List<PawnApplication> filtered = _applications
        .where((PawnApplication app) => _matchesStatusFilter(app, status))
        .toList();
    final int start = ((page < 1 ? 1 : page) - 1) * perPage;
    final List<PawnApplication> items = start >= filtered.length
        ? <PawnApplication>[]
        : filtered.skip(start).take(perPage).toList();
    return PagedApplications(
      items: items,
      page: page < 1 ? 1 : page,
      perPage: perPage,
      total: filtered.length,
      isDemo: true,
    );
  }

  bool _matchesStatusFilter(PawnApplication app, String? status) {
    if (status == null || status == 'all') return true;
    return switch (status) {
      'pending' => app.status == ApplicationStatus.submitted,
      'processing' => app.status == ApplicationStatus.underReview,
      'revision_required' => app.status == ApplicationStatus.revisionRequired,
      'approved' => app.status == ApplicationStatus.approved ||
          app.status == ApplicationStatus.offerAccepted,
      'rejected' => app.status == ApplicationStatus.rejected ||
          app.status == ApplicationStatus.offerDeclined,
      _ => app.status.name == status,
    };
  }

  @override
  Future<PawnApplication> submitApplication({
    required PawnCategory category,
    required String itemTitle,
    required Map<String, String> itemDetails,
    required List<PawnDocument> documents,
    double? estimatedValue,
    int? preferredTenorDays,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final now = DateTime.now();
    final seq = _sequence++;
    final code = 'GDK-2026-${seq.toString().padLeft(4, '0')}';

    final app = PawnApplication(
      id: 'app-$seq',
      code: code,
      category: category,
      itemTitle: itemTitle,
      itemDetails: Map<String, String>.from(itemDetails),
      documents: List<PawnDocument>.from(documents),
      status: ApplicationStatus.submitted,
      estimatedUserValue: estimatedValue,
      preferredTenorDays: preferredTenorDays ?? 30,
      statusHistory: [
        ApplicationStatusHistory(
          status: ApplicationStatus.submitted,
          title: 'Pengajuan Dikirim',
          note: 'Pengajuan baru berhasil dikirim dan menunggu pemeriksaan.',
          timestamp: now,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );

    _applications.insert(0, app);
    _notifications.insert(
      0,
      AppNotification(
        id: 'notif-${now.millisecondsSinceEpoch}',
        title: 'Pengajuan Berhasil Dikirim',
        body: 'Nomor pengajuan $code untuk $itemTitle sedang menunggu tinjauan.',
        createdAt: now,
        isRead: false,
        applicationId: app.id,
      ),
    );
    return app;
  }

  @override
  Future<PawnApplication> reviseApplication({
    required String applicationId,
    required String itemTitle,
    required Map<String, String> itemDetails,
    required List<PawnDocument> documents,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final index = _applications.indexWhere((a) => a.id == applicationId);
    if (index == -1) throw Exception('Pengajuan tidak ditemukan.');
    final now = DateTime.now();
    final current = _applications[index];
    final updated = current.copyWith(
      itemTitle: itemTitle,
      itemDetails: Map<String, String>.from(itemDetails),
      documents: List<PawnDocument>.from(documents),
      status: ApplicationStatus.underReview,
      updatedAt: now,
      statusHistory: [
        ...current.statusHistory,
        ApplicationStatusHistory(
          status: ApplicationStatus.underReview,
          title: 'Perbaikan Dikirim',
          note: 'Nasabah memperbarui data/berkas dan pengajuan ditinjau ulang.',
          timestamp: now,
        ),
      ],
    );
    _applications[index] = updated;
    return updated;
  }

  @override
  Future<PawnTransaction> acceptOffer(String applicationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final index = _applications.indexWhere((a) => a.id == applicationId);
    if (index == -1) throw Exception('Pengajuan tidak ditemukan.');
    final current = _applications[index];
    final assessment = current.assessment;
    if (assessment == null) {
      throw Exception('Hasil taksiran belum tersedia.');
    }

    final now = DateTime.now();
    _applications[index] = current.copyWith(
      status: ApplicationStatus.offerAccepted,
      updatedAt: now,
      statusHistory: [
        ...current.statusHistory,
        ApplicationStatusHistory(
          status: ApplicationStatus.offerAccepted,
          title: 'Penawaran Diterima',
          note: 'Nasabah menyetujui penawaran dan transaksi aktif dibuat.',
          timestamp: now,
        ),
      ],
    );

    final trxSeq = _transactions.length + 1;
    final trx = PawnTransaction(
      id: 'trx-$trxSeq',
      code: 'TRX-2026-${trxSeq.toString().padLeft(4, '0')}',
      applicationId: current.id,
      itemTitle: current.itemTitle,
      category: current.category,
      principalAmount: assessment.approvedPrincipal,
      feeAmount: assessment.serviceFee,
      paidAmount: 0,
      tenorDays: assessment.tenorDays,
      startDate: assessment.startDate,
      dueDate: assessment.dueDate,
      status: TransactionStatus.active,
      payments: const [],
    );
    _transactions.insert(0, trx);
    return trx;
  }

  @override
  Future<PawnApplication> declineOffer(String applicationId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final index = _applications.indexWhere((a) => a.id == applicationId);
    if (index == -1) throw Exception('Pengajuan tidak ditemukan.');
    final current = _applications[index];
    final now = DateTime.now();
    final updated = current.copyWith(
      status: ApplicationStatus.offerDeclined,
      updatedAt: now,
      statusHistory: [
        ...current.statusHistory,
        ApplicationStatusHistory(
          status: ApplicationStatus.offerDeclined,
          title: 'Penawaran Ditolak',
          note: 'Nasabah menolak penawaran taksiran.',
          timestamp: now,
        ),
      ],
    );
    _applications[index] = updated;
    return updated;
  }

  @override
  Future<List<PawnTransaction>> getTransactions() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List<PawnTransaction>.unmodifiable(_transactions);
  }

  @override
  Future<PawnTransaction> recordDemoPayment({
    required String transactionId,
    required double amount,
    required String method,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index == -1) throw Exception('Transaksi tidak ditemukan.');
    final current = _transactions[index];
    final newPaid = current.paidAmount + amount;
    final isPaidOff = newPaid >= current.totalDue;
    final now = DateTime.now();

    final updated = current.copyWith(
      paidAmount: newPaid,
      status: isPaidOff ? TransactionStatus.paidOff : TransactionStatus.active,
      payments: [
        DemoPayment(
          id: 'pay-${now.millisecondsSinceEpoch}',
          amount: amount,
          method: '$method (Simulasi Demo)',
          paidAt: now,
          note: isPaidOff ? 'Pelunasan simulasi' : 'Pembayaran sebagian simulasi',
        ),
        ...current.payments,
      ],
    );
    _transactions[index] = updated;
    return updated;
  }

  @override
  Future<List<OutletInfo>> getOutlets() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const [
      OutletInfo(
        id: 'out-1',
        name: 'Gadaikan Cabang Sudirman (Demo)',
        address: 'Jl. Jend. Sudirman Kav. 45, Setiabudi',
        city: 'Jakarta Selatan',
        hours: 'Senin - Sabtu, 08.30 - 16.30 WIB',
        phone: '(021) 555-0101',
      ),
      OutletInfo(
        id: 'out-2',
        name: 'Gadaikan Cabang Dago (Demo)',
        address: 'Jl. Ir. H. Juanda No. 88, Coblong',
        city: 'Bandung',
        hours: 'Senin - Jumat, 08.30 - 16.00 WIB',
        phone: '(022) 555-0142',
      ),
      OutletInfo(
        id: 'out-3',
        name: 'Gadaikan Cabang Tunjungan (Demo)',
        address: 'Jl. Tunjungan No. 32, Genteng',
        city: 'Surabaya',
        hours: 'Senin - Sabtu, 09.00 - 17.00 WIB',
        phone: '(031) 555-0199',
      ),
    ];
  }

  @override
  Future<List<PromoInfo>> getPromotions() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return const [
      PromoInfo(
        id: 'promo-1',
        title: 'Potongan Biaya Jasa Awal 15%',
        period: '1 - 31 Desember 2026',
        summary:
            'Simulasi potongan biaya layanan periode pertama untuk pengajuan kategori Elektronik dan Emas.',
        terms:
            'Berlaku pada mode simulasi demo untuk tenor minimal 30 hari. Tidak dapat digabungkan dengan promo lain.',
      ),
      PromoInfo(
        id: 'promo-2',
        title: 'Proses Verifikasi Cepat BPKB',
        period: 'Berlaku Selama Masa Demo',
        summary:
            'Dokumen kendaraan diverifikasi secara privat dengan estimasi respon maksimal 1 hari kerja.',
        terms:
            'Pastikan foto BPKB dan kendaraan jelas serta sesuai nama pemilik dokumen.',
      ),
    ];
  }

  @override
  Future<List<AppNotification>> getNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List<AppNotification>.unmodifiable(_notifications);
  }

  @override
  Future<void> markNotificationRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
    }
  }

  @override
  Future<List<FaqItem>> getFaqs() async {
    return const [
      FaqItem(
        question: 'Apa saja barang yang bisa digadaikan di Gadaikan?',
        answer:
            'Saat ini Gadaikan mendukung tiga kategori utama: Elektronik (smartphone, laptop, kamera), Emas (perhiasan/logam mulia), dan BPKB Kendaraan (motor/mobil).',
      ),
      FaqItem(
        question: 'Apakah nilai di Simulasi Gadai sudah pasti disetujui?',
        answer:
            'Belum. Fitur Simulasi Gadai hanya memberikan perkiraan awal berdasarkan parameter demo. Nilai taksiran dan plafon final ditetapkan setelah pemeriksaan fisik dan dokumen.',
      ),
      FaqItem(
        question: 'Apakah data BPKB dan dokumen saya aman?',
        answer:
            'Dokumen sensitif seperti BPKB hanya digunakan untuk proses verifikasi dan tidak ditampilkan secara publik.',
      ),
      FaqItem(
        question: 'Apakah pembayaran di versi ini memotong saldo asli?',
        answer:
            'Tidak. Seluruh proses pembayaran pada tahap prototipe ini merupakan catatan simulasi demo tanpa transaksi uang sungguhan.',
      ),
    ];
  }
}
