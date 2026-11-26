import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/core/models/gadaikan_models.dart';
import 'package:flutter_application_1/core/services/gadaikan_repository.dart';
import 'package:flutter_application_1/core/state/app_state.dart';
import 'package:flutter_application_1/features/history/screens/history_screen.dart';
import 'package:flutter_application_1/features/info/screens/outlets_screen.dart';
import 'package:flutter_application_1/features/info/screens/promos_screen.dart';

void _noop() {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<void> pumpScreen(WidgetTester tester, Widget child) async {
    final AppState state = AppState(MockGadaikanRepository());
    state.initialize();
    await tester.pumpWidget(
      MaterialApp(
        home: AppStateScope(state: state, child: child),
      ),
    );
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  group('Riwayat', () {
    test('filter, pagination, dan label demo', () async {
      final MockGadaikanRepository repository = MockGadaikanRepository();

      final PagedHistory all = await repository.getHistoryPage();
      expect(all.isDemo, isTrue);
      expect(all.items.length, 4); // 3 pengajuan + 1 transaksi

      final PagedHistory applications =
          await repository.getHistoryPage(filter: 'applications');
      expect(applications.items.length, 3);
      expect(
        applications.items.every((item) => item.kind == HistoryKind.application),
        isTrue,
      );

      final PagedHistory active = await repository.getHistoryPage(filter: 'active');
      expect(active.items.length, 1);
      expect(active.items.first.code, 'TRX-2026-0001');

      final PagedHistory paid = await repository.getHistoryPage(filter: 'paid_off');
      expect(paid.items, isEmpty);

      final PagedHistory pageTwo =
          await repository.getHistoryPage(page: 2, perPage: 2);
      expect(pageTwo.items.length, 2);
      expect(pageTwo.hasMore, isFalse);
    });

    testWidgets('layar riwayat menampilkan filter dan data akun',
        (WidgetTester tester) async {
      await pumpScreen(
        tester,
        const HistoryScreen(onStartNewApplication: _noop),
      );

      for (final String label in [
        'Semua',
        'Pengajuan',
        'Aktif',
        'Lunas',
        'Ditolak / Dibatalkan',
      ]) {
        expect(find.widgetWithText(ChoiceChip, label), findsOneWidget);
      }
      expect(
        find.text('Mode demo: riwayat ini berasal dari data lokal, bukan server.'),
        findsOneWidget,
      );
      expect(find.text('GDK-2026-0001'), findsOneWidget);
      expect(find.text('TRX-2026-0001'), findsOneWidget);

      final Finder activeChip = find.widgetWithText(ChoiceChip, 'Aktif');
      await tester.ensureVisible(activeChip);
      await tester.pump(const Duration(milliseconds: 150));
      await tester.tap(activeChip);
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('TRX-2026-0001'), findsOneWidget);
      expect(find.text('GDK-2026-0001'), findsNothing);
    });
  });

  group('Outlet & promo', () {
    test('model dari API tidak mengarang promo resmi', () {
      final OutletInfo outlet = OutletInfo.fromApiJson(<String, dynamic>{
        'id': 1,
        'name': 'Cabang API',
        'address': 'Jalan API',
        'city': 'Kota',
        'hours': '08.00 - 16.00',
        'phone': '021',
        'latitude': -6.2,
        'longitude': 106.8,
      });
      expect(outlet.isDemo, isFalse);
      expect(outlet.hasValidCoordinates, isTrue);

      final PromoInfo promo = PromoInfo.fromApiJson(<String, dynamic>{
        'id': 2,
        'title': 'Promo dari Admin',
        'period': 'Januari 2027',
        'description': 'Ringkasan',
        'terms': 'Syarat berlaku',
      });
      expect(promo.isDemo, isFalse);
      expect(promo.badgeText, 'Informasi');
    });

    testWidgets('outlet menampilkan data berlabel demo tanpa tombol peta',
        (WidgetTester tester) async {
      await pumpScreen(tester, const OutletsScreen());

      expect(find.text('Daftar Outlet'), findsOneWidget);
      expect(find.text('Gadaikan Cabang Sudirman (Demo)'), findsOneWidget);
      expect(find.text('DEMO'), findsWidgets);
      expect(find.text('Peta belum tersedia pada versi ini.'), findsWidgets);
      expect(find.byIcon(Icons.map_outlined), findsNothing);
    });

    testWidgets('promo menampilkan banner dan membuka detail',
        (WidgetTester tester) async {
      await pumpScreen(tester, const PromosScreen());

      expect(find.text('Informasi & Promo'), findsOneWidget);
      expect(find.text('Potongan Biaya Jasa Awal 15%'), findsOneWidget);
      expect(find.text('DEMO'), findsWidgets);

      final Finder firstCard = find.text('Potongan Biaya Jasa Awal 15%');
      await tester.ensureVisible(firstCard);
      await tester.pump(const Duration(milliseconds: 150));
      await tester.tap(firstCard);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Syarat & Ketentuan'), findsOneWidget);
    });
  });
}
