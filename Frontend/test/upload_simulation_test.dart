import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/core/models/gadaikan_models.dart';
import 'package:flutter_application_1/core/services/document_upload_service.dart';
import 'package:flutter_application_1/core/services/gadaikan_repository.dart';
import 'package:flutter_application_1/core/state/app_state.dart';
import 'package:flutter_application_1/core/utils/formatters.dart';
import 'package:flutter_application_1/core/widgets/app_buttons.dart';
import 'package:flutter_application_1/core/widgets/app_text_fields.dart';
import 'package:flutter_application_1/core/widgets/document_upload_tile.dart';
import 'package:flutter_application_1/features/simulation/screens/simulation_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('Validasi berkas', () {
    test('tipe dan ukuran berkas divalidasi', () {
      final PickedDocument jpg = PickedDocument(
        path: '/tmp/foto.jpg',
        name: 'foto.jpg',
        sizeBytes: 1024,
      );
      expect(DocumentValidation.validate(jpg), isNull);

      expect(
        DocumentValidation.validate(
          PickedDocument(
            path: '/tmp/script.exe',
            name: 'script.exe',
            sizeBytes: 1024,
          ),
        ),
        contains('Format berkas tidak didukung'),
      );
      expect(
        DocumentValidation.validate(
          PickedDocument(
            path: '/tmp/kosong.jpg',
            name: 'kosong.jpg',
            sizeBytes: 0,
          ),
        ),
        contains('kosong'),
      );
      expect(
        DocumentValidation.validate(
          PickedDocument(
            path: '/tmp/besar.jpg',
            name: 'besar.jpg',
            sizeBytes: DocumentValidation.maxBytes + 1,
          ),
        ),
        contains('5 MB'),
      );
    });

    test('mock upload melaporkan progres dan tidak mengklaim tersimpan',
        () async {
      final MockDocumentUploadService service =
          MockDocumentUploadService(stepDelay: Duration.zero);
      final List<double> progresses = <double>[];
      final UploadedDocumentMeta meta = await service.upload(
        file: const PickedDocument(
          path: '/tmp/foto.jpg',
          name: 'foto.jpg',
          sizeBytes: 1024,
        ),
        isSensitive: true,
        onProgress: progresses.add,
      );

      expect(service.isMock, isTrue);
      expect(progresses, isNotEmpty);
      expect(progresses.last, 1.0);
      expect(meta.isDemo, isTrue);
      expect(meta.privateReference, isNull);
    });
  });

  testWidgets('tile upload menampilkan preview, ganti/hapus, dan retry',
      (WidgetTester tester) async {
    bool removed = false;
    bool retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocumentUploadTile(
            title: 'Foto Barang',
            subtitle: 'JPG/PNG, maks 5 MB',
            onPick: () {},
            fileName: 'foto.jpg',
            fileSizeLabel: '1.20 MB',
            isRequired: true,
            isDemo: true,
            isSensitive: true,
            uploadError: 'Gagal terhubung ke server.',
            onRetry: () => retried = true,
            onReplace: () {},
            onRemove: () => removed = true,
          ),
        ),
      ),
    );

    expect(find.text('Foto Barang'), findsOneWidget);
    expect(find.text('foto.jpg'), findsOneWidget);
    expect(find.text('Gagal terhubung ke server.'), findsOneWidget);
    expect(find.text('Gagal mengunggah — coba lagi.'), findsOneWidget);

    await tester.tap(find.byTooltip('Hapus berkas'));
    expect(removed, isTrue);

    await tester.tap(find.text('Coba lagi'));
    expect(retried, isTrue);
  });

  testWidgets('tile upload menampilkan indikator progres',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DocumentUploadTile(
            title: 'Foto Emas',
            subtitle: 'JPG/PNG',
            onPick: () {},
            fileName: 'emas.png',
            uploadProgress: 0.5,
            isUploading: true,
            isRequired: false,
          ),
        ),
      ),
    );

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.textContaining('Mengunggah...'), findsOneWidget);
  });

  group('Simulasi gadai', () {
    test('perhitungan mengikuti konfigurasi dan input', () async {
      final SimulationConfig config =
          await MockGadaikanRepository().getSimulationConfig();
      expect(config.isDemo, isTrue);

      final SimulationResult result = config.calculate(
        category: PawnCategory.elektronik,
        estimatedValue: 10000000,
        tenorDays: 30,
      );
      expect(result.estimatedPrincipal, 7000000);
      expect(result.estimatedFee, 210000);
      expect(result.estimatedTotal, 7210000);

      final SimulationResult emas = config.calculate(
        category: PawnCategory.emas,
        estimatedValue: 10000000,
        tenorDays: 30,
      );
      expect(emas.estimatedPrincipal, greaterThan(result.estimatedPrincipal));

      final SimulationResult nol = config.calculate(
        category: PawnCategory.elektronik,
        estimatedValue: 0,
        tenorDays: 30,
      );
      expect(nol.estimatedTotal, 0);

      expect(
        AppFormatters.formatRupiah(1234567),
        'Rp 1.234.567',
      );
    });

    Future<void> pumpSimulation(WidgetTester tester) async {
      final AppState state = AppState(MockGadaikanRepository());
      state.initialize();
      await tester.pumpWidget(
        MaterialApp(
          home: AppStateScope(state: state, child: const SimulationScreen()),
        ),
      );
      for (int i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
    }

    Finder valueField() => find.descendant(
          of: find.byWidgetPredicate(
            (Widget w) =>
                w is AppTextField && w.label == 'Perkiraan Nilai Barang (Rp)',
          ),
          matching: find.byType(TextFormField),
        );

    testWidgets('validasi kosong, nol, dan angka besar; CTA ikut berubah',
        (WidgetTester tester) async {
      await pumpSimulation(tester);

      expect(find.textContaining('Parameter demo'), findsOneWidget);
      expect(find.text('Nilai Barang yang Diinput'), findsOneWidget);

      await tester.enterText(valueField(), '');
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('Nilai barang wajib diisi.'), findsOneWidget);
      expect(
        tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed,
        isNull,
      );

      await tester.enterText(valueField(), '0');
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.text('Nilai barang harus lebih dari 0.'), findsOneWidget);

      await tester.enterText(valueField(), '999999999999');
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.textContaining('Nilai maksimal'), findsOneWidget);

      await tester.enterText(valueField(), '5000000');
      await tester.pump(const Duration(milliseconds: 150));
      expect(
        tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed,
        isNotNull,
      );
      expect(find.text('Rp 5.000.000'), findsWidgets);
    });

    testWidgets('hasil berubah saat kategori diganti',
        (WidgetTester tester) async {
      await pumpSimulation(tester);

      final Finder cta = find.byType(PrimaryButton);
      expect(cta, findsOneWidget);

      await tester.tap(find.text('Emas'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Persentase Plafon (Emas)'), findsOneWidget);
    });
  });
}
