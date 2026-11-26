import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/core/models/gadaikan_models.dart';
import 'package:flutter_application_1/core/services/gadaikan_repository.dart';
import 'package:flutter_application_1/core/state/app_state.dart';
import 'package:flutter_application_1/features/pawn/screens/application_detail_screen.dart';

class _RejectedRepository extends MockGadaikanRepository {
  @override
  Future<List<PawnApplication>> getApplications() async {
    final List<PawnApplication> base = await super.getApplications();
    final PawnApplication rejected = PawnApplication(
      id: 'rejected-1',
      code: 'GDK-REJECT-0001',
      category: base.first.category,
      itemTitle: base.first.itemTitle,
      itemDetails: base.first.itemDetails,
      documents: base.first.documents,
      status: ApplicationStatus.rejected,
      createdAt: base.first.createdAt,
      updatedAt: DateTime(2026, 11, 21),
      adminNote: 'Catatan internal yang tidak boleh tampil sebagai alasan publik.',
      statusHistory: <ApplicationStatusHistory>[
        ApplicationStatusHistory(
          status: ApplicationStatus.submitted,
          title: 'Pengajuan Dikirim',
          note: 'Data diterima.',
          timestamp: DateTime(2026, 11, 20),
        ),
        ApplicationStatusHistory(
          status: ApplicationStatus.rejected,
          title: 'Pengajuan Ditolak',
          note: 'Tidak memenuhi persyaratan verifikasi.',
          timestamp: DateTime(2026, 11, 21),
        ),
      ],
    );
    return <PawnApplication>[rejected, ...base];
  }

  @override
  Future<PawnApplication> getApplicationDetail(String id) async {
    return (await getApplications()).firstWhere(
      (PawnApplication app) => app.id == id,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<void> pumpDetail(
    WidgetTester tester,
    GadaikanRepository repository,
    String id,
  ) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final AppState state = AppState(repository);
    state.initialize();
    await tester.pumpWidget(
      MaterialApp(
        home: AppStateScope(
          state: state,
          child: ApplicationDetailScreen(applicationId: id),
        ),
      ),
    );
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  test('riwayat status dari API dipetakan beserta waktu', () {
    final PawnApplication app = PawnApplication.fromApiJson(<String, dynamic>{
      'id': 7,
      'code': 'GDK-SERVER-0007',
      'category': 'emas',
      'status': 'under_review',
      'admin_note': 'Catatan internal',
      'status_history': <dynamic>[
        <String, dynamic>{
          'status': 'submitted',
          'title': 'Dikirim',
          'note': 'Data diterima',
          'timestamp': '2026-11-26T08:15:00',
        },
      ],
    });

    expect(app.statusHistory.length, 1);
    expect(app.statusHistory.first.title, 'Dikirim');
    expect(app.statusHistory.first.timestamp, DateTime(2026, 11, 26, 8, 15));
    expect(app.adminNote, 'Catatan internal');
    expect(app.status, ApplicationStatus.underReview);
  });

  testWidgets('detail menampilkan timeline dan menyembunyikan berkas sensitif',
      (WidgetTester tester) async {
    await pumpDetail(tester, MockGadaikanRepository(), 'app-1');

    expect(find.text('GDK-2026-0001'), findsOneWidget);
    expect(find.text('Disetujui'), findsWidgets);
    expect(find.text('Timeline Status'), findsOneWidget);
    expect(find.text('Pengajuan Dikirim'), findsOneWidget);
    expect(find.text('Sedang Ditinjau'), findsOneWidget);
    expect(find.text('Penawaran Tersedia'), findsOneWidget);
    expect(find.textContaining('macbook_depan.jpg'), findsOneWidget);
    expect(find.textContaining('Simulasi Pemeriksaan Petugas'), findsNothing);
    expect(
      find.textContaining('Mode demo: status dan timeline'),
      findsOneWidget,
    );
  });

  testWidgets('dokumen sensitif BPKB tidak menampilkan nama berkas publik',
      (WidgetTester tester) async {
    await pumpDetail(tester, MockGadaikanRepository(), 'app-3');

    expect(find.textContaining('Tersimpan privat'), findsOneWidget);
    expect(find.textContaining('bpkb_dokumen.jpg'), findsNothing);
  });

  testWidgets('status revision_required menampilkan tombol perbaiki',
      (WidgetTester tester) async {
    await pumpDetail(tester, MockGadaikanRepository(), 'app-2');

    expect(find.text('Perlu Perbaikan'), findsWidgets);
    expect(find.text('Perbaiki Data Pengajuan'), findsOneWidget);
  });

  testWidgets('status rejected menampilkan alasan aman tanpa tombol simulasi',
      (WidgetTester tester) async {
    await pumpDetail(tester, _RejectedRepository(), 'rejected-1');

    expect(
      find.text('Pengajuan Belum Disetujui'),
      findsOneWidget,
    );
    expect(
      find.textContaining('hubungi outlet terdekat'),
      findsOneWidget,
    );
    expect(find.text('Simulasikan Disetujui'), findsNothing);
    expect(find.text('Terima Penawaran'), findsNothing);
  });
}
