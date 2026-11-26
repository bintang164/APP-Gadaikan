import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/core/models/gadaikan_models.dart';
import 'package:flutter_application_1/core/services/gadaikan_repository.dart';
import 'package:flutter_application_1/core/state/app_state.dart';
import 'package:flutter_application_1/core/utils/formatters.dart';
import 'package:flutter_application_1/core/widgets/app_buttons.dart';
import 'package:flutter_application_1/core/widgets/app_text_fields.dart';
import 'package:flutter_application_1/features/pawn/screens/pawn_submission_flow_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Finder field(String label) {
    return find.descendant(
      of: find.byWidgetPredicate(
        (Widget widget) => widget is AppTextField && widget.label == label,
      ),
      matching: find.byType(TextFormField),
    );
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final Finder finder = find.text(text);
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 150));
  }

  Future<void> pumpFlow(
    WidgetTester tester,
    PawnCategory category,
  ) async {
    final AppState state = AppState(MockGadaikanRepository());
    state.initialize();
    await tester.pumpWidget(
      MaterialApp(
        home: AppStateScope(
          state: state,
          child: PawnSubmissionFlowScreen(initialCategory: category),
        ),
      ),
    );
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  group('Validasi numerik & format', () {
    test('berat emas harus positif dan dalam batas wajar', () {
      String? error(String value) => AppValidators.positiveDecimal(
            value,
            label: 'Berat',
            min: 0.01,
            max: 10000,
          );

      expect(error(''), contains('wajib diisi'));
      expect(error('abc'), contains('angka'));
      expect(error('0'), contains('lebih dari 0'));
      expect(error('-2'), contains('lebih dari 0'));
      expect(error('12000'), contains('antara'));
      expect(error('5.5'), isNull);
    });

    test('kadar opsional, tahun kendaraan, dan nomor polisi', () {
      expect(AppValidators.karat(''), isNull);
      expect(AppValidators.karat('22 Karat'), isNull);
      expect(AppValidators.karat('150'), contains('antara'));
      expect(AppValidators.vehicleYear('1970'), contains('1980'));
      expect(AppValidators.vehicleYear('abc'), contains('4 digit'));
      expect(AppValidators.vehicleYear('2024'), isNull);
      expect(AppValidators.plateNumber('INVALID!'), contains('Format'));
      expect(AppValidators.plateNumber('B 4123 DEMO'), isNull);
    });

    test('nomor polisi disamarkan di tampilan umum', () {
      final String masked = AppFormatters.maskPlate('B 4123 DEMO');
      expect(masked, contains('••••'));
      expect(masked, isNot(contains('4123')));
    });
  });

  testWidgets('form emas valid, berlabel perkiraan, dan data tetap ada',
      (WidgetTester tester) async {
    await pumpFlow(tester, PawnCategory.emas);

    expect(
      find.textContaining('Berat dan kadar yang kamu masukkan adalah perkiraan'),
      findsOneWidget,
    );
    expect(
      find.textContaining('harga emas real-time'),
      findsOneWidget,
    );
    expect(
      tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed,
      isNull,
    );

    await tapText(tester, 'Cincin');
    await tapText(tester, 'Baik');
    await tester.enterText(field('Perkiraan Berat (Gram) *'), '5.5');
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed,
      isNotNull,
    );
    await tapText(tester, 'Lanjutkan');
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Unggah Foto & Dokumen'), findsOneWidget);
    expect(find.text('Foto Emas (Sisi Tambahan)'), findsOneWidget);

    await tapText(tester, 'Kembali');
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester.widget<TextFormField>(field('Perkiraan Berat (Gram) *'))
          .controller
          ?.text,
      '5.5',
    );
  });

  testWidgets('form BPKB memuat pemberitahuan privasi dan valid',
      (WidgetTester tester) async {
    await pumpFlow(tester, PawnCategory.bpkb);

    expect(
      find.textContaining('disimpan privat di backend'),
      findsOneWidget,
    );
    expect(
      find.textContaining(
        'tidak melakukan pengecekan legalitas kendaraan otomatis',
      ),
      findsOneWidget,
    );

    await tapText(tester, 'Sepeda Motor');
    await tester.enterText(field('Merek *'), 'Honda');
    await tester.enterText(field('Model / Tipe *'), 'Vario 160');
    await tester.enterText(field('Tahun Kendaraan *'), '2024');
    await tester.enterText(field('Nomor Polisi *'), 'B 4123 DEMO');
    await tester.enterText(field('Nama Pemilik Sesuai Dokumen *'), 'Budi');
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed,
      isNotNull,
    );
    await tapText(tester, 'Lanjutkan');
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Unggah Foto & Dokumen'), findsOneWidget);
    expect(
      find.textContaining('Berkas sensitif disimpan privat'),
      findsOneWidget,
    );
    expect(find.text('Foto BPKB (Halaman Identitas)'), findsOneWidget);
    expect(find.text('Foto Kendaraan'), findsOneWidget);
  });
}
