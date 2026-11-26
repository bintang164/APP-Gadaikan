import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/core/models/gadaikan_models.dart';
import 'package:flutter_application_1/core/services/gadaikan_repository.dart';
import 'package:flutter_application_1/core/state/app_state.dart';
import 'package:flutter_application_1/features/pawn/screens/application_detail_screen.dart';
import 'package:flutter_application_1/features/transactions/screens/transaction_detail_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<void> tapText(WidgetTester tester, String text) async {
    final Finder finder = find.text(text);
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 200));
  }

  AppState buildState() {
    final AppState state = AppState(MockGadaikanRepository());
    state.initialize();
    return state;
  }

  Future<void> pumpWith(WidgetTester tester, AppState state, Widget child) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(home: AppStateScope(state: state, child: child)),
    );
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  group('Model backend', () {
    test('transaksi dan pembayaran dipetakan dari payload server', () {
      final PawnTransaction trx = PawnTransaction.fromApiJson(<String, dynamic>{
        'id': 9,
        'code': 'TRX-SERVER-0009',
        'application_id': 4,
        'item_title': 'Barang Server',
        'category': 'emas',
        'principal_amount': 5000000,
        'fee_amount': 150000,
        'paid_amount': 2000000,
        'tenor_days': 30,
        'start_date': '2026-11-01T00:00:00',
        'due_date': '2026-12-01T00:00:00',
        'status': 'payment_pending',
        'payments': <dynamic>[
          <String, dynamic>{
            'id': 3,
            'amount': 2000000,
            'method': 'Transfer Bank (Simulasi)',
            'paid_at': '2026-11-20T10:00:00',
          },
        ],
      });

      expect(trx.code, 'TRX-SERVER-0009');
      expect(trx.status, TransactionStatus.paymentPending);
      expect(trx.totalDue, 5150000);
      expect(trx.remainingAmount, 3150000);
      expect(trx.payments.length, 1);
      expect(trx.payments.first.method, contains('Simulasi'));
    });

    test('penaksiran dari server memuat rincian dan catatan nasabah', () {
      final PawnApplication app = PawnApplication.fromApiJson(<String, dynamic>{
        'id': 4,
        'code': 'GDK-SERVER-0004',
        'category': 'bpkb',
        'status': 'approved',
        'assessment': <String, dynamic>{
          'assessed_value': 10000000,
          'approved_principal': 7500000,
          'service_fee': 225000,
          'tenor_days': 30,
          'start_date': '2026-11-01T00:00:00',
          'due_date': '2026-12-01T00:00:00',
          'notes': 'Catatan untuk nasabah',
        },
      });

      expect(app.assessment, isNotNull);
      expect(app.assessment!.approvedPrincipal, 7500000);
      expect(app.assessment!.totalRepayment, 7725000);
      expect(app.assessment!.notes, 'Catatan untuk nasabah');
    });
  });

  test('pembayaran demo tercatat dan status lunas mengikuti aturan', () async {
    final MockGadaikanRepository repository = MockGadaikanRepository();
    final PawnTransaction before = (await repository.getTransactions()).first;
    expect(before.paidAmount, 2000000);

    final PawnTransaction partial = await repository.recordDemoPayment(
      transactionId: before.id,
      amount: 1000000,
      method: 'Virtual Account (Simulasi)',
    );
    expect(partial.paidAmount, 3000000);
    expect(partial.payments.length, before.payments.length + 1);
    expect(partial.status, TransactionStatus.active);

    final PawnTransaction paid = await repository.recordDemoPayment(
      transactionId: before.id,
      amount: partial.remainingAmount,
      method: 'Tunai di Outlet (Simulasi)',
    );
    expect(paid.status, TransactionStatus.paidOff);
    expect(paid.remainingAmount, 0);
  });

  testWidgets('detail transaksi menampilkan rincian, riwayat, dan label demo',
      (WidgetTester tester) async {
    await pumpWith(
      tester,
      buildState(),
      const TransactionDetailScreen(transactionId: 'trx-1'),
    );

    expect(find.text('TRX-2026-0001'), findsOneWidget);
    expect(find.text('Pokok Pinjaman'), findsOneWidget);
    expect(find.text('Biaya Layanan'), findsOneWidget);
    expect(find.text('Total Kewajiban'), findsOneWidget);
    expect(find.text('Jatuh Tempo'), findsOneWidget);
    expect(find.text('Riwayat Pembayaran Simulasi'), findsOneWidget);
    expect(find.text('SIMULASI / DEMO'), findsWidgets);
    expect(
      find.text('Catat Pembayaran (Simulasi Demo)'),
      findsOneWidget,
    );
  });

  testWidgets('alur pembayaran memiliki langkah konfirmasi',
      (WidgetTester tester) async {
    await pumpWith(
      tester,
      buildState(),
      const TransactionDetailScreen(transactionId: 'trx-1'),
    );

    await tapText(tester, 'Catat Pembayaran (Simulasi Demo)');

    expect(find.text('Pembayaran Gadai'), findsOneWidget);
    expect(find.text('Lanjut Konfirmasi'), findsOneWidget);
    expect(find.text('Konfirmasi & Catat'), findsNothing);

    await tapText(tester, 'Lanjut Konfirmasi');

    expect(find.text('Konfirmasi Catatan Demo'), findsOneWidget);
    expect(find.text('Konfirmasi & Catat'), findsOneWidget);
    expect(find.textContaining('Status lunas hanya ditetapkan backend'),
        findsOneWidget);
  });

  testWidgets('nasabah melihat penawaran dan dapat menerima/menolak',
      (WidgetTester tester) async {
    await pumpWith(
      tester,
      buildState(),
      const ApplicationDetailScreen(applicationId: 'app-1'),
    );

    expect(find.text('Hasil Taksiran & Penawaran'), findsOneWidget);
    expect(find.text('Terima Penawaran'), findsOneWidget);
    expect(find.text('Tolak Penawaran'), findsOneWidget);
    expect(find.textContaining('langkah selanjutnya'), findsNothing);
  });
}
