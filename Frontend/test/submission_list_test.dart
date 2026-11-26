import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/core/auth/auth_repository.dart';
import 'package:flutter_application_1/core/auth/mock_auth_service.dart';
import 'package:flutter_application_1/core/models/gadaikan_models.dart';
import 'package:flutter_application_1/core/services/api_gadaikan_repository.dart';
import 'package:flutter_application_1/core/services/gadaikan_repository.dart';
import 'package:flutter_application_1/core/state/app_state.dart';
import 'package:flutter_application_1/core/storage/local_storage.dart';
import 'package:flutter_application_1/core/storage/session_store.dart';
import 'package:flutter_application_1/features/pawn/screens/application_list_screen.dart';

class _FailingRepository extends MockGadaikanRepository {
  @override
  Future<PagedApplications> getApplicationsPage({
    String? status,
    int page = 1,
    int perPage = 10,
  }) async {
    throw Exception('Tidak dapat terhubung ke server.');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  AppState buildState(GadaikanRepository repository) {
    final AppState state = AppState(repository);
    state.initialize();
    return state;
  }

  Future<void> pumpList(WidgetTester tester, AppState state) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppStateScope(state: state, child: const ApplicationListScreen()),
      ),
    );
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  group('Repository pengajuan', () {
    test('mock memberi label demo dan filter/pagination bekerja', () async {
      final MockGadaikanRepository repository = MockGadaikanRepository();
      expect(repository.usesBackend, isFalse);

      final PagedApplications all = await repository.getApplicationsPage();
      expect(all.isDemo, isTrue);
      expect(all.items.length, 3);

      final PagedApplications approved = await repository.getApplicationsPage(
        status: 'approved',
      );
      expect(approved.items.length, 2);
      expect(approved.items.first.status, ApplicationStatus.approved);

      final PagedApplications rejected = await repository.getApplicationsPage(
        status: 'rejected',
      );
      expect(rejected.items, isEmpty);

      final PagedApplications pageTwo = await repository.getApplicationsPage(
        page: 2,
        perPage: 2,
      );
      expect(pageTwo.items.length, 1);
      expect(pageTwo.hasMore, isFalse);
    });

    test('API repository menandai data sebagai backend', () async {
      final LocalStorage localStorage = LocalStorage();
      final AuthRepository auth = AuthRepository(
        service: MockAuthService(localStorage: localStorage, delay: Duration.zero),
        sessionStore: InMemorySessionStore(),
        localStorage: localStorage,
      );
      final ApiGadaikanRepository repository =
          ApiGadaikanRepository(authRepository: auth);
      expect(repository.usesBackend, isTrue);
    });

    test('nomor pengajuan berasal dari payload server, bukan dibuat lokal',
        () async {
      final PawnApplication fromApi = PawnApplication.fromApiJson(
        <String, dynamic>{
          'id': 42,
          'code': 'GDK-SERVER-0099',
          'category': 'emas',
          'item_title': 'Cincin Emas',
          'status': 'under_review',
          'created_at': '2026-11-27T08:00:00',
          'updated_at': '2026-11-27T09:00:00',
        },
      );
      expect(fromApi.code, 'GDK-SERVER-0099');
      expect(fromApi.category, PawnCategory.emas);
      expect(fromApi.status, ApplicationStatus.underReview);

      final PawnApplication noCode = PawnApplication.fromApiJson(
        <String, dynamic>{'id': 43, 'item_title': 'Tanpa nomor'},
      );
      expect(noCode.code, isEmpty);
    });
  });

  testWidgets('daftar pengajuan menampilkan enam filter dan item demo',
      (WidgetTester tester) async {
    final AppState state = buildState(MockGadaikanRepository());
    await pumpList(tester, state);

    for (final String label in [
      'Semua',
      'Menunggu',
      'Diproses',
      'Perlu Perbaikan',
      'Disetujui',
      'Ditolak',
    ]) {
      expect(find.widgetWithText(ChoiceChip, label), findsOneWidget);
    }
    expect(
      find.text('Mode demo: daftar ini berasal dari data lokal, bukan server.'),
      findsOneWidget,
    );
    expect(find.text('GDK-2026-0001'), findsOneWidget);

    final Finder rejectedChip = find.widgetWithText(ChoiceChip, 'Ditolak');
    await tester.ensureVisible(rejectedChip);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(rejectedChip);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('GDK-2026-0001'), findsNothing);
    expect(
      find.text('Belum Ada Pengajuan'),
      findsOneWidget,
    );
  });

  testWidgets('error daftar menampilkan pesan dan tombol coba lagi',
      (WidgetTester tester) async {
    final AppState state = buildState(_FailingRepository());
    await pumpList(tester, state);

    expect(find.text('Tidak dapat terhubung ke server.'), findsOneWidget);
    expect(state.applicationListError, contains('Tidak dapat terhubung'));
  });
}
