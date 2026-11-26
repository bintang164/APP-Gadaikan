import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/core/models/gadaikan_models.dart';
import 'package:flutter_application_1/core/services/gadaikan_repository.dart';
import 'package:flutter_application_1/core/state/app_state.dart';
import 'package:flutter_application_1/core/storage/pawn_draft_store.dart';
import 'package:flutter_application_1/core/widgets/app_buttons.dart';
import 'package:flutter_application_1/core/widgets/app_text_fields.dart';
import 'package:flutter_application_1/features/pawn/screens/category_selection_screen.dart';
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

  AppState buildState() {
    final AppState state = AppState(MockGadaikanRepository());
    // Di widget test, Future.delayed hanya berjalan saat tester.pump().
    state.initialize();
    return state;
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    final Finder finder = find.text(text);
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 200));
  }

  Future<void> pumpWith(WidgetTester tester, AppState state, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AppStateScope(state: state, child: child),
      ),
    );
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  testWidgets(
      'kategori harus dipilih sebelum lanjut dan persyaratan ditampilkan',
      (WidgetTester tester) async {
    final AppState state = buildState();
    await pumpWith(tester, state, const CategorySelectionScreen());

    expect(find.text('Mau gadai apa hari ini?'), findsOneWidget);
    expect(find.text('Persyaratan Elektronik'), findsNothing);
    expect(
      tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed,
      isNull,
    );

    await tester.tap(find.text('Elektronik'));
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Persyaratan Elektronik'), findsOneWidget);
    expect(
      find.text(
        'Pengajuan tetap memerlukan pemeriksaan data dan persetujuan petugas. '
        'Pilihan kategori tidak menjamin persetujuan.',
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed,
      isNotNull,
    );

    await tapText(tester, 'Lanjut');
    for (int i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }

    expect(find.byType(PawnSubmissionFlowScreen), findsOneWidget);
    expect(find.text('Gadai Elektronik'), findsOneWidget);
    expect(
      find.text('Langkah 1 dari 4 • Identitas Perangkat'),
      findsOneWidget,
    );

    final PawnDraft? draft = await PawnDraftStore().read();
    expect(draft?.categoryId, 'elektronik');
  });

  testWidgets(
      'form elektronik valid bertahap dan draft bertahan saat kembali',
      (WidgetTester tester) async {
    final AppState state = buildState();
    await pumpWith(
      tester,
      state,
      const PawnSubmissionFlowScreen(initialCategory: PawnCategory.elektronik),
    );

    // Tombol Lanjut nonaktif sampai field wajib terisi.
    expect(
      tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed,
      isNull,
    );

    await tapText(tester, 'Smartphone');
    await tester.enterText(field('Merek *'), 'Samsung');
    await tester.enterText(field('Model / Tipe *'), 'Galaxy S24');
    await tester.pump(const Duration(milliseconds: 800));

    expect(
      tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed,
      isNotNull,
    );
    await tapText(tester, 'Lanjutkan');
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Langkah 2 dari 4 • Kondisi & Kelengkapan'), findsOneWidget);

    await tapText(tester, 'Mulus');
    await tapText(tester, 'Normal 100%');
    await tapText(tester, 'Unit');
    await tapText(tester, 'Charger');
    await tester.enterText(field('Deskripsi Tambahan *'), 'Baterai 90 persen');
    await tester.pump(const Duration(milliseconds: 800));

    final PawnDraft? draft = await PawnDraftStore().read();
    expect(draft?.text('brand'), 'Samsung');
    expect(draft?.text('physicalChoice'), 'Mulus');
    expect(draft?.list('accessories'), contains('Charger'));

    await tester.tap(find.text('Kembali'));
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Langkah 1 dari 4 • Identitas Perangkat'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(field('Merek *')).controller?.text,
      'Samsung',
    );
    expect(
      tester.widget<TextFormField>(field('Model / Tipe *')).controller?.text,
      'Galaxy S24',
    );
  });

  testWidgets('perkiraan nilai tidak dihitung otomatis', (WidgetTester tester) async {
    final AppState state = buildState();
    await pumpWith(
      tester,
      state,
      const PawnSubmissionFlowScreen(initialCategory: PawnCategory.elektronik),
    );

    // Tidak ada angka taksiran yang dihasilkan form sebelum pengguna mengisi.
    expect(find.textContaining('Estimasi pinjaman'), findsNothing);
    expect(find.text('Perkiraan Nilai Barang (Opsional)'), findsNothing);

    await tapText(tester, 'Smartphone');
    await tester.enterText(field('Merek *'), 'Samsung');
    await tester.enterText(field('Model / Tipe *'), 'Galaxy S24');
    await tester.pump(const Duration(milliseconds: 800));
    await tapText(tester, 'Lanjutkan');
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('Perkiraan Nilai Barang (Opsional)'), findsOneWidget);
    expect(
      find.text('Input kamu sendiri; aplikasi tidak menaksir otomatis.'),
      findsOneWidget,
    );
    final TextFormField valueField =
        tester.widget<TextFormField>(field('Perkiraan Nilai Barang (Opsional)'));
    expect(valueField.controller?.text, isEmpty);
  });
}
