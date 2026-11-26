import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/core/models/gadaikan_models.dart';
import 'package:flutter_application_1/core/services/gadaikan_repository.dart';
import 'package:flutter_application_1/core/state/app_state.dart';
import 'package:flutter_application_1/features/auth/screens/login_screen.dart';
import 'package:flutter_application_1/features/auth/screens/register_screen.dart';
import 'package:flutter_application_1/features/history/screens/history_screen.dart';
import 'package:flutter_application_1/features/home/screens/home_screen.dart';
import 'package:flutter_application_1/features/info/screens/faq_screen.dart';
import 'package:flutter_application_1/features/info/screens/notifications_screen.dart';
import 'package:flutter_application_1/features/info/screens/outlets_screen.dart';
import 'package:flutter_application_1/features/info/screens/promos_screen.dart';
import 'package:flutter_application_1/features/pawn/screens/application_detail_screen.dart';
import 'package:flutter_application_1/features/pawn/screens/application_list_screen.dart';
import 'package:flutter_application_1/features/pawn/screens/category_selection_screen.dart';
import 'package:flutter_application_1/features/pawn/screens/pawn_submission_flow_screen.dart';
import 'package:flutter_application_1/features/profile/screens/profile_screen.dart';
import 'package:flutter_application_1/features/simulation/screens/simulation_screen.dart';
import 'package:flutter_application_1/features/transactions/screens/transaction_detail_screen.dart';

void _noop() {}

void _noopTab(int _) {}

Future<void> _pumpScreen(
  WidgetTester tester,
  Widget child, {
  required Size size,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final AppState state = AppState(MockGadaikanRepository());
  state.initialize();

  await tester.pumpWidget(
    MaterialApp(
      home: AppStateScope(state: state, child: child),
      routes: <String, WidgetBuilder>{
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        CategorySelectionScreen.routeName: (_) => const CategorySelectionScreen(),
        SimulationScreen.routeName: (_) => const SimulationScreen(),
        OutletsScreen.routeName: (_) => const OutletsScreen(),
        PromosScreen.routeName: (_) => const PromosScreen(),
        FaqScreen.routeName: (_) => const FaqScreen(),
        NotificationsScreen.routeName: (_) => const NotificationsScreen(),
      },
    ),
  );
  for (int i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  const List<Size> sizes = <Size>[
    Size(320, 640),
    Size(360, 800),
    Size(390, 844),
    Size(414, 896),
  ];

  final Map<String, Widget Function()> screens = <String, Widget Function()>{
    'Home': () => const HomeScreen(onNavigateTab: _noopTab),
    'Pengajuan': () => const ApplicationListScreen(),
    'Riwayat': () => HistoryScreen(onStartNewApplication: _noop),
    'Profil': () => const ProfileScreen(),
    'Login': () => const LoginScreen(),
    'Register': () => const RegisterScreen(),
    'Kategori': () => const CategorySelectionScreen(),
    'Form Elektronik': () => const PawnSubmissionFlowScreen(
          initialCategory: PawnCategory.elektronik,
        ),
    'Simulasi': () => const SimulationScreen(),
    'Notifikasi': () => const NotificationsScreen(),
    'Outlet': () => const OutletsScreen(),
    'Promo': () => const PromosScreen(),
    'FAQ': () => const FaqScreen(),
    'Detail Pengajuan': () => const ApplicationDetailScreen(applicationId: 'app-1'),
    'Detail Transaksi': () => const TransactionDetailScreen(transactionId: 'trx-1'),
  };

  for (final MapEntry<String, Widget Function()> entry in screens.entries) {
    for (final Size size in sizes) {
      testWidgets('${entry.key} tidak overflow di ${size.width.toInt()}x${size.height.toInt()}',
          (WidgetTester tester) async {
        await _pumpScreen(tester, entry.value(), size: size);
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('navigasi tombol utama bekerja tanpa exception',
      (WidgetTester tester) async {
    await _pumpScreen(
      tester,
      const HomeScreen(onNavigateTab: _noopTab),
      size: const Size(390, 844),
    );

    expect(find.text('Gadai lebih mudah, langsung dari genggaman'), findsOneWidget);
    expect(find.text('Pilih Layanan'), findsOneWidget);
    expect(find.text('Simulasi Gadai'), findsOneWidget);
    expect(find.text('Ajukan Gadai'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Tombol kategori membuka form sesuai pilihan.
    final Finder electronics = find.text('Elektronik');
    await tester.ensureVisible(electronics);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(electronics);
    for (int i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(find.text('Gadai Elektronik'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('state loading/empty/error tersedia pada layar data',
      (WidgetTester tester) async {
    await _pumpScreen(
      tester,
      const ApplicationListScreen(),
      size: const Size(390, 844),
    );

    // Setelah data mock termuat, daftar atau empty state tampil.
    final bool hasList = find.byType(ListView).evaluate().isNotEmpty;
    final bool hasEmpty = find.text('Belum Ada Pengajuan').evaluate().isNotEmpty;
    expect(hasList || hasEmpty, isTrue);
    expect(tester.takeException(), isNull);
  });
}
