import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/app/app.dart';
import 'package:flutter_application_1/app/theme/app_theme.dart';
import 'package:flutter_application_1/app/widgets/app_logo.dart';
import 'package:flutter_application_1/core/providers/session_providers.dart';
import 'package:flutter_application_1/core/state/session_controller.dart';
import 'package:flutter_application_1/core/storage/local_storage.dart';
import 'package:flutter_application_1/core/storage/session_store.dart';
import 'package:flutter_application_1/features/home/screens/home_screen.dart';
import 'package:flutter_application_1/features/onboarding/screens/onboarding_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('AppLogo', () {
    testWidgets('menampilkan wordmark dan tagline', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: AppLogo()),
          ),
        ),
      );

      expect(find.byType(AppLogo), findsOneWidget);
      expect(
        find.text('Solusi Gadai dalam Genggaman'),
        findsOneWidget,
      );
    });
  });

  group('SessionController', () {
    test('bootstrap, onboarding, login, dan logout', () async {
      final LocalStorage localStorage = LocalStorage();
      final InMemorySessionStore store = InMemorySessionStore();

      final SessionController controller = SessionController(
        localStorage: localStorage,
        sessionStore: store,
      );

      await controller.bootstrap();
      expect(controller.initialized, isTrue);
      expect(controller.onboardingCompleted, isFalse);
      expect(controller.isAuthenticated, isFalse);

      await controller.completeOnboarding();
      expect(controller.onboardingCompleted, isTrue);

      final SessionController second = SessionController(
        localStorage: LocalStorage(),
        sessionStore: store,
      );
      await second.bootstrap();
      expect(second.onboardingCompleted, isTrue);
      expect(second.isAuthenticated, isFalse);

      await second.loginDemo(identifier: '081234567890');
      expect(second.isAuthenticated, isTrue);
      expect(second.userPhone, '081234567890');
      expect(second.displayName, 'Pengguna Gadaikan');

      await second.logout();
      expect(second.isAuthenticated, isFalse);
      expect(second.userPhone, isNull);
      expect(await store.readToken(), isNull);
    });

    test('nama dari email diambil sebagai nama tampilan', () async {
      final SessionController controller = SessionController(
        localStorage: LocalStorage(),
        sessionStore: InMemorySessionStore(),
      );

      await controller.loginDemo(identifier: 'siti@example.com');
      expect(controller.displayName, 'Siti');
    });
  });

  testWidgets('alur splash -> onboarding -> login -> home', (tester) async {
    final InMemorySessionStore store = InMemorySessionStore();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionStoreProvider.overrideWithValue(store),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pump();
    expect(find.byKey(const Key('splash_screen')), findsOneWidget);
    expect(find.text('Solusi Gadai dalam Genggaman'), findsOneWidget);

    // Lewati durasi splash minimum.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('onboarding_screen')), findsOneWidget);
    expect(find.text('Pilih jenis barang'), findsOneWidget);

    await tester.tap(find.text('Lewati'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login_screen')), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      '081234567890',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'password123',
    );
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home_screen')), findsOneWidget);
    expect(find.text('Halo, Pengguna Gadaikan'), findsOneWidget);
  });

  testWidgets('HomeScreen tidak overflow pada layar 320x640', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(body: HomeScreen()),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('home_screen')), findsOneWidget);
  });

  testWidgets('Onboarding tidak overflow pada layar 320x640', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const OnboardingScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const Key('onboarding_screen')), findsOneWidget);
  });
}
