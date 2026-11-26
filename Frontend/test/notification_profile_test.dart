import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_application_1/core/models/gadaikan_models.dart';
import 'package:flutter_application_1/core/services/gadaikan_repository.dart';
import 'package:flutter_application_1/core/state/app_state.dart';
import 'package:flutter_application_1/features/info/screens/faq_screen.dart';
import 'package:flutter_application_1/features/info/screens/notifications_screen.dart';
import 'package:flutter_application_1/features/profile/screens/profile_screen.dart';

class _ProfileRepository extends MockGadaikanRepository {
  @override
  Future<UserProfile?> restoreSession() async {
    return const UserProfile(
      id: 'usr-demo-1',
      name: 'Budi Santoso',
      phone: '081234567890',
      email: 'budi.demo@gadaikan.id',
      address: 'Jl. Merdeka No. 12, Jakarta Selatan',
    );
  }
}

AppState _buildProfileState() {
  final AppState state = AppState(_ProfileRepository());
  state.initialize();
  return state;
}

AppState _buildState() {
  final AppState state = AppState(MockGadaikanRepository());
  state.initialize();
  return state;
}

Future<void> _pump(
  WidgetTester tester,
  AppState state,
  Widget child, {
  Map<String, WidgetBuilder>? routes,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: AppStateScope(state: state, child: child),
      routes: routes ?? const <String, WidgetBuilder>{},
    ),
  );
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('Notifikasi', () {
    test('jenis dan status baca dipetakan dari API', () {
      final AppNotification notification = AppNotification.fromApiJson(
        <String, dynamic>{
          'id': 5,
          'title': 'Penawaran Gadai Tersedia',
          'body': 'Penawaran siap ditinjau.',
          'created_at': '2026-11-26T10:00:00',
          'is_read': false,
          'application_id': 'app-1',
        },
      );
      expect(notification.type, NotificationType.offerAvailable);
      expect(notification.isRead, isFalse);
      expect(notification.applicationId, 'app-1');
    });

    test('tandai satu dan semua notifikasi mengubah status baca', () async {
      final MockGadaikanRepository repository = MockGadaikanRepository();
      List<AppNotification> items = await repository.getNotifications();
      expect(items.any((item) => !item.isRead), isTrue);

      await repository.markNotificationRead(items.first.id);
      items = await repository.getNotifications();
      expect(
        items.firstWhere((item) => item.id == items.first.id).isRead,
        isTrue,
      );

      await repository.markAllNotificationsRead();
      items = await repository.getNotifications();
      expect(items.every((item) => item.isRead), isTrue);
    });

    testWidgets('daftar notifikasi menampilkan label, urutan, dan aksi baca',
        (WidgetTester tester) async {
      final AppState state = _buildState();
      await _pump(tester, state, const NotificationsScreen());

      expect(find.text('Notifikasi'), findsOneWidget);
      expect(
        find.textContaining('Tidak ada push notification sungguhan'),
        findsOneWidget,
      );
      expect(find.text('Tandai semua dibaca'), findsOneWidget);
      expect(find.text('Penawaran Gadai Tersedia'), findsOneWidget);
      expect(find.text('Penawaran tersedia'), findsWidgets);

      await tester.tap(find.text('Tandai semua dibaca'));
      await tester.pump(const Duration(milliseconds: 500));
      expect(state.notifications.every((item) => item.isRead), isTrue);
      expect(find.text('Tandai semua dibaca'), findsNothing);
    });
  });

  group('Profil & FAQ', () {
    testWidgets('profil menampilkan data, menu, dan konfirmasi logout',
        (WidgetTester tester) async {
      final AppState state = _buildProfileState();
      await _pump(
        tester,
        state,
        const ProfileScreen(),
        routes: <String, WidgetBuilder>{
          '/login': (_) => const Scaffold(body: Text('Halaman Masuk')),
        },
      );

      expect(state.user, isNotNull);
      expect(find.text('Budi Santoso'), findsOneWidget);
      expect(find.text('081234567890'), findsWidgets);
      expect(find.text('Ubah Data Profil'), findsOneWidget);
      expect(find.text('Pusat Bantuan & FAQ'), findsOneWidget);
      expect(find.text('Kebijakan Privasi'), findsOneWidget);
      expect(find.text('Syarat & Ketentuan'), findsOneWidget);
      expect(find.text('Tentang Gadaikan'), findsOneWidget);

      await tester.drag(find.byType(ListView).first, const Offset(0, -1200));
      await tester.pump(const Duration(milliseconds: 200));
      final Finder logoutButton = find.text('Keluar');
      await tester.ensureVisible(logoutButton);
      await tester.pump(const Duration(milliseconds: 150));
      await tester.tap(logoutButton);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Keluar dari Akun?'), findsOneWidget);
      await tester.tap(find.text('Keluar').last);
      for (int i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }

      expect(state.user, isNull);
      expect(find.text('Halaman Masuk'), findsOneWidget);
    });

    testWidgets('edit profil tersimpan dan tervalidasi',
        (WidgetTester tester) async {
      final AppState state = _buildProfileState();
      await _pump(tester, state, const ProfileScreen());

      await tester.tap(find.text('Ubah Data Profil'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Ubah Profil'), findsOneWidget);

      final Finder nameField = find.widgetWithText(TextFormField, 'Nama Lengkap');
      await tester.enterText(nameField, 'Nama Baru Demo');
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('Simpan Perubahan'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(state.user?.name, 'Nama Baru Demo');
    });

    testWidgets('FAQ menampilkan penanda konten demo dan jawaban',
        (WidgetTester tester) async {
      final AppState state = _buildState();
      await _pump(tester, state, const FaqScreen());

      expect(
        find.text('Konten demo — bukan informasi layanan resmi.'),
        findsOneWidget,
      );
      final Finder firstFaq = find.text(
        'Apa saja barang yang bisa digadaikan di Gadaikan?',
      );
      await tester.ensureVisible(firstFaq);
      await tester.pump(const Duration(milliseconds: 150));
      await tester.tap(firstFaq);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Jawaban demo'), findsWidgets);
    });
  });
}
