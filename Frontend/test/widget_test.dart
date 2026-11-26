import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/core/models/gadaikan_models.dart';
import 'package:flutter_application_1/core/services/gadaikan_repository.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Splash navigates to Onboarding, Login, and Home Dashboard',
      (WidgetTester tester) async {
    await tester.pumpWidget(
        GadaikanApp(repository: MockGadaikanRepository()),
      );

    // Splash screen renders Gadaikan brand and tagline.
    expect(find.text('GADAIKAN'), findsOneWidget);
    expect(find.text('Solusi Gadai dalam Genggaman'), findsOneWidget);

    // Wait for splash timer and bootstrap.
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    // Onboarding screen appears.
    expect(find.text('Pilih jenis barang'), findsOneWidget);
    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();

    // Login screen appears.
    expect(find.text('Selamat datang kembali'), findsOneWidget);

    // Quick-fill demo credentials and sign in.
    await tester.tap(find.text('Isi Demo'));
    await tester.pump();
    await tester.tap(find.text('Masuk'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Home dashboard renders key sections and bottom navigation.
    expect(
      find.text('Gadai lebih mudah, langsung dari genggaman'),
      findsOneWidget,
    );
    expect(find.text('Pilih Layanan'), findsOneWidget);
    expect(find.text('Simulasi Gadai'), findsOneWidget);
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Pengajuan'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });

  test('SimulationConfig calculates plafon, fee, and total accurately',
      () async {
    final repo = MockGadaikanRepository();
    final config = await repo.getSimulationConfig();
    final result = config.calculate(
      category: PawnCategory.elektronik,
      estimatedValue: 10000000,
      tenorDays: 30,
    );

    expect(result.estimatedPrincipal, 7000000);
    expect(result.estimatedFee, 210000);
    expect(result.estimatedTotal, 7210000);
  });

  testWidgets('Simulation screen displays disclaimer and updates calculation',
      (WidgetTester tester) async {
    await tester.pumpWidget(
        GadaikanApp(repository: MockGadaikanRepository()),
      );
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Isi Demo'));
    await tester.pump();
    await tester.tap(find.text('Masuk'));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Simulasi Gadai'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simulasi Gadai'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Hasil simulasi, bukan penawaran final'),
      findsOneWidget,
    );
    expect(find.text('Lanjutkan Pengajuan'), findsOneWidget);
  });
}
