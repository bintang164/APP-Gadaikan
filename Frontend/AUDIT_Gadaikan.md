# Audit & Rencana Implementasi — Gadaikan

> **Status:** Tahap 1 & 2 **selesai dan terverifikasi** · Tahap 3–8 belum dikerjakan
> **Tanggal:** 26 November 2026
> **Lingkup:** Audit workspace, konfigurasi, dependency, routing, kondisi kode, kesiapan Android, serta implementasi Tahap 1 (Prompt 01) dan Tahap 2 (Prompt 02)
> **Dokumen acuan:** `PRD_Gadaikan.md`, `DESIGN_Gadaikan.md`, serta teks Prompt 01 & 02 yang diberikan di chat

---

## 0. Hasil Implementasi Tahap 1 & 2

| Pemeriksaan | Hasil |
|---|---|
| `flutter analyze` | ✅ **No issues found** |
| `flutter test` | ✅ **6 test lulus** |
| `flutter build web --release` | ✅ Berhasil (`build/web`) |
| `flutter build apk --debug` | ✅ Berhasil (`build/app/outputs/flutter-apk/app-debug.apk`) |
| Uji manual emulator Android | ⚠️ Belum — belum ada AVD/system image di mesin |
| Uji alur splash → onboarding → login → home | ✅ Terverifikasi lewat widget test |
| Persistensi onboarding | ✅ Terverifikasi lewat unit test |
| Overflow 320×640 | ✅ Terverifikasi lewat widget test Home & Onboarding |

**Yang sudah dibuat:** theme lengkap, 12+ widget reusable, bottom navigation
4 tab, routing guard, environment config, splash, onboarding 3 halaman,
login/registrasi demo, SessionController, LocalStorage, SessionStore, dan
halaman tab minimal.

**Yang belum dibuat:** backend Laravel, MySQL, Sanctum, form pengajuan,
upload dokumen, simulasi, riwayat transaksi, panel admin, notifikasi, outlet,
promo, FAQ, dan pembayaran demo. Rencana Tahap 3–8 tetap berlaku di bawah.

---

## 1. Ringkasan Eksekutif

Workspace **bukan kosong**, tetapi juga **belum siap dijalankan**. Yang ada:

- Satu project Flutter di `flutter_application_1/`.
- Implementasi parsial design system: `AppColors`, `AppTextStyles`, `AppSpacing`, `AppTheme`, `PrimaryButton`, `SecondaryButton`, `AppRouter`, dan `HomeScreen`.
- **Tidak ada backend Laravel** dan **tidak ada database project**.
- `flutter analyze` menghasilkan **14 error, 1 warning, 1 info**. Aplikasi **tidak bisa di-build** karena router dan home merujuk file/kelas yang belum ada.
- `PROMPT_Antigravity_Gadaikan.md` **tidak ditemukan** di workspace maupun folder Downloads. Prompt 01 & 02 yang dipakai adalah teks yang diberikan di chat.

**Kesimpulan:** jangan lanjut membuat fitur sebelum Tahap 1 membereskan build yang rusak. Rencana yang diusulkan mempertahankan struktur `lib/app` + `lib/features` yang sudah ada, tanpa menghapus file.

---

## 2. Bukti Audit yang Dijalankan

| Pemeriksaan | Hasil |
|---|---|
| `flutter --version` | Flutter 3.47.2 stable, Dart 3.13.2 |
| `flutter doctor -v` | Android SDK 36.0.0 terdeteksi, tetapi **cmdline-tools hilang**, **status lisensi belum diketahui** |
| `flutter devices` | Windows, Chrome, Edge. **Tidak ada perangkat Android** |
| `flutter emulators` | **Tidak ada emulator/AVD** |
| `flutter analyze` | **14 error**, 1 warning, 1 info |
| `flutter pub add ... --dry-run` | `shared_preferences 2.5.6`, `flutter_secure_storage 11.2.0`, `intl 0.20.3` dapat di-resolve |
| `php --version` | PHP 8.3.33 (Laragon) |
| `composer --version` | Composer 2.10.3 |
| MySQL | Binary MySQL 8.4.3 ada di Laragon, tetapi **port 3306 tertutup** (server belum jalan) |
| Git | **Tidak ada repository Git** di workspace |

---

## 3. Struktur Workspace Saat Ini

```text
Project Akhir APP Mobile/
└── flutter_application_1/                 ← satu-satunya project
    ├── android/
    │   ├── app/build.gradle.kts           AGP 9.1.0, Kotlin 2.4.0, JVM 17
    │   ├── settings.gradle.kts            AGP 9.1.0, Kotlin 2.4.0
    │   └── gradle/wrapper/                Gradle 9.3.1
    ├── lib/
    │   ├── main.dart                      ProviderScope + MyApp
    │   ├── app/
    │   │   ├── app.dart                   MaterialApp.router
    │   │   ├── routes/app_router.dart     ⚠️ rusak (parameter `builder` tidak valid)
    │   │   ├── theme/
    │   │   │   ├── app_colors.dart        ✅ token sesuai DESIGN
    │   │   │   ├── app_text_styles.dart   ⚠️ parsial, Inter via google_fonts
    │   │   │   ├── app_spacing.dart       ⚠️ minimal, import tidak terpakai
    │   │   │   └── app_theme.dart         ⚠️ parsial, ada API deprecated
    │   │   └── widgets/
    │   │       ├── primary_button.dart    ⚠️ dasar
    │   │       └── secondary_button.dart  ⚠️ dasar
    │   └── features/
    │       └── home/screens/home_screen.dart  ⚠️ import file yang belum ada
    ├── test/widget_test.dart              ❌ test counter default, tidak valid
    ├── pubspec.yaml                       ⚠️ dependency parsial
    ├── PRD_Gadaikan.md                    ✅
    ├── DESIGN_Gadaikan.md                 ✅
    └── PROMPT_Antigravity_Gadaikan.md     ❌ tidak ditemukan
```

**Tidak ada folder Laravel** di workspace. Folder induk hanya berisi `flutter_application_1/`.

> Catatan: ada file `AUDIT_Gadaikan.md` lama di folder `C:\Users\fauzanbintang\.gemini\antigravity\brain\...` yang masih menganggap `lib/` hanya berisi `main.dart`. Audit tersebut **stale** dan tidak dipakai; dokumen ini menggantikannya.

---

## 4. Kondisi Kode Flutter

### 4.1 Hasil `flutter analyze`

**14 error** yang memblokir build:

| # | File | Masalah |
|---|---|---|
| 1–3 | `lib/app/routes/app_router.dart` | Import `pawn_screen.dart`, `history_screen.dart`, `profile_screen.dart` tidak ada |
| 4–6 | `lib/app/routes/app_router.dart` | Kelas `PawnScreen`, `HistoryScreen`, `ProfileScreen` tidak ada |
| 7 | `lib/app/routes/app_router.dart:40` | `GoRouter` tidak punya parameter `builder` di go_router 14.8.1 |
| 8–9 | `lib/features/home/screens/home_screen.dart` | Import `app_card.dart`, `section_header.dart` tidak ada |
| 10–11 | `lib/features/home/screens/home_screen.dart` | `SectionHeader` tidak ada; list `const` gagal |
| 12–13 | `lib/features/home/screens/home_screen.dart` | `AppCard` tidak ada; list `const` gagal |
| 14 | `test/widget_test.dart` | `MyApp` tidak diekspor dari `main.dart` |

Warning/info:

- `lib/app/theme/app_spacing.dart` — import `material.dart` tidak terpakai.
- `lib/app/theme/app_theme.dart` — `ColorScheme.background` deprecated.

### 4.2 Masalah arsitektur yang terlihat

1. **Router belum memakai shell route yang benar.** `GoRouter.builder` tidak ada; bottom navigation harus memakai `StatefulShellRoute.indexedStack` agar tiap tab punya state sendiri dan splash/onboarding/login tidak ikut memakai bottom nav.
2. **Double Scaffold/SafeArea.** Router membungkus semua route dengan `Scaffold` + `SafeArea`, lalu `HomeScreen` membuat `Scaffold` + `SafeArea` lagi.
3. **Bottom navigation global.** Saat ini semua route (termasuk nanti splash/onboarding) akan mendapat bottom nav karena pembungkus di level router.
4. **Belum ada environment config.** Base URL API belum ada; nanti tidak boleh di-hard-code di banyak file.
5. **Belum ada layer storage.** Onboarding flag dan token belum punya tempat.
6. **Belum ada auth guard.** Splash belum bisa menentukan tujuan.
7. **Test default tidak relevan** dan tidak bisa dikompilasi.

### 4.3 Dependency saat ini

| Package | Constraint | Ter-resolve | Catatan |
|---|---|---|---|
| `flutter_riverpod` | `^2.4.1` | 2.6.1 | Bisa dipakai; Riverpod 3.5 tersedia tetapi upgrade bukan prioritas |
| `go_router` | `^14.8.1` | 14.8.1 | `StatefulShellRoute` tersedia; `builder` root tidak ada |
| `google_fonts` | `^6.2.1` | 6.3.3 | Mengunduh font saat runtime; risiko demo offline |
| `dio` | `^5.8.0` | 5.11.1 | Siap dipakai untuk API |
| `cupertino_icons` | `^1.0.8` | 1.0.9 | Tidak penting untuk Material |
| `flutter_lints` | `^6.0.0` | 6.0.0 | Aktif |

**Belum ada:** `shared_preferences`, `flutter_secure_storage`, `intl`, `image_picker`, `cached_network_image`, `flutter_svg`.

---

## 5. Backend, Database, dan Lingkungan

| Komponen | Kondisi | Dampak |
|---|---|---|
| Laravel project | **Tidak ada** | Semua endpoint PRD belum ada |
| PHP | 8.3.33 | Cukup untuk Laravel 12/13 |
| Composer | 2.10.3 | Siap membuat project |
| MySQL | 8.4.3 terpasang via Laragon, **server belum jalan** | Perlu start Laragon + buat database `gadaikan` |
| Laravel lain di mesin | `C:\laragon\www\kopi-kangenan-api` memakai Laravel 13.17 + Sanctum 4.3 | Bukti lingkungan mampu menjalankan Laravel 13 |
| Git | Tidak ada | Tidak ada checkpoint sebelum perubahan besar |

**Rekomendasi backend:** Laravel 13.x + Sanctum 4.x + MySQL 8.4, di folder **sibling** `gadaikan-api/` (bukan di dalam `flutter_application_1/`). Ini menjaga Flutter dan Laravel terpisah, sesuai PRD.

---

## 6. Kesiapan Android

### 6.1 Konfigurasi yang ada

| Item | Nilai | Status |
|---|---|---|
| `compileSdk` | 36 (default Flutter 3.47.2) | ⚠️ Platform 36 belum terlihat; yang terpasang `android-37.0` |
| `minSdk` | 24 (default Flutter 3.47.2) | ✅ Cukup untuk shared_preferences/secure storage |
| `targetSdk` | 36 | ✅ |
| AGP | 9.1.0 | ✅ Sesuai template Flutter |
| Gradle | 9.3.1 | ✅ |
| Kotlin | 2.4.0 | ✅ |
| JVM | 17 | ✅ |
| `applicationId` | `com.example.flutter_application_1` | ⚠️ Harus diganti sebelum rilis |
| App label | `flutter_application_1` | ⚠️ Harus diganti `Gadaikan` |
| INTERNET permission | Hanya di manifest debug/profile | ⚠️ Release butuh di manifest utama |
| Cleartext HTTP | Belum diatur | ⚠️ Android 9+ memblokir HTTP lokal |

### 6.2 Blocker untuk uji Android

1. `cmdline-tools` tidak terpasang.
2. Lisensi Android belum terverifikasi (`flutter doctor`).
3. Tidak ada system image dan AVD/emulator.
4. Platform `android-36` belum terpasang (hanya `android-37.0`).
5. NDK 28.2.13676358 belum terpasang; biasanya tidak dibutuhkan untuk plugin murni Dart/Java, tetapi perlu dipantau.

**Konsekuensi:** Tahap 1–2 bisa diverifikasi di Chrome/Edge dan lewat `flutter test`, tetapi **kriteria “diuji di emulator Android” belum bisa dipenuhi** sampai toolchain dibereskan. Ini tugas setup, bukan perubahan kode.

---

## 7. Gap Analysis terhadap PRD, DESIGN, dan Prompt 01–02

### 7.1 Sudah ada

- Token warna utama sudah tepat: Navy `#173B66`, Gold `#D9A441`, background `#F6F8FB`, surface putih, text, success/warning/danger/info, border.
- `AppTheme` dasar, `PrimaryButton`, `SecondaryButton`.
- `ProviderScope` + `MaterialApp.router` + `go_router`.
- Empat route tab sudah didefinisikan (tetapi belum valid).
- `HomeScreen` sederhana (tetapi belum bisa dikompilasi).

### 7.2 Belum ada / belum lengkap

**Fondasi (Prompt 01)**

- Theme lengkap: typography scale, spacing 8pt, radius, elevation, ukuran komponen, component themes.
- Widget wajib: `AppTextField`, `PasswordField`, `AppCard`, `SectionHeader`, `StatusBadge`, `EmptyState`, `ErrorState`, `LoadingView`.
- Bottom navigation shell yang benar (4 tab, state per tab, tanpa bottom nav di halaman auth).
- Routing constants + guard.
- Environment/base URL API.
- Screen tab minimal yang berfungsi (Pengajuan, Riwayat, Profil belum ada).
- Test yang valid.

**Splash & Onboarding (Prompt 02)**

- Splash screen, wordmark, tagline, loading singkat.
- Onboarding 3 halaman + indikator + tombol Lewati/Lanjutkan/Mulai.
- Penyimpanan status onboarding.
- Pemeriksaan status autentikasi.
- Login screen minimal (belum ada).
- Alur splash → onboarding → login/home.

**Fitur berikutnya (belum masuk Tahap 1–2)**

- Registrasi, login backend, logout, profil.
- Home dashboard lengkap dengan data API.
- Pilih kategori, form elektronik/emas/BPKB, upload, review, status.
- Simulasi, riwayat, detail transaksi.
- Outlet, promo, notifikasi, FAQ, pembayaran demo.
- Panel/endpoint admin.
- Laravel, migrasi, seeder, Sanctum, role.

---

## 8. Risiko dan Mitigasi

| # | Risiko | Level | Mitigasi |
|---|---|---|---|
| R-1 | Build rusak (14 error) | 🔴 Tinggi | Tahap 1 membuat file yang hilang dan menulis ulang router; tidak menjalankan fitur lain sebelum `flutter analyze` bersih |
| R-2 | Tidak ada Git | 🔴 Tinggi | `git init` + commit baseline sebelum perubahan; commit per tahap |
| R-3 | Toolchain Android tidak lengkap | 🔴 Tinggi | Pasang cmdline-tools, platform 36, system image, buat AVD, terima lisensi; verifikasi `flutter build apk --debug` |
| R-4 | Backend Laravel belum ada | 🔴 Tinggi | Buat `gadaikan-api/` terpisah; Tahap 2 memakai sesi demo yang dilabeli, bukan klaim autentikasi nyata |
| R-5 | MySQL belum jalan | 🟡 Sedang | Jalankan Laragon MySQL; buat database `gadaikan`; jangan commit `.env` |
| R-6 | Font diunduh saat runtime | 🟡 Sedang | Bundle Inter ke `assets/fonts/` dan set `fontFamily: 'Inter'`; hilangkan ketergantungan jaringan saat splash |
| R-7 | `applicationId` masih `com.example` | 🟡 Sedang | Ganti ke `com.gadaikan.app` di Tahap 1 sebelum fitur bertambah |
| R-8 | HTTP lokal diblokir Android | 🟡 Sedang | Tambah INTERNET di manifest utama; cleartext hanya untuk debug/`10.0.2.2` |
| R-9 | Ambiguitas auth Tahap 2 | 🟡 Sedang | Putuskan: sesi demo berlabel vs berhenti di layar login (rekomendasi: sesi demo) |
| R-10 | Overflow di layar kecil | 🟡 Sedang | Uji 320/360/412 dp; `SafeArea` + scroll; text scale 1.3 |
| R-11 | `PROMPT_Antigravity_Gadaikan.md` tidak ada | 🟢 Rendah | Gunakan PRD + DESIGN + teks prompt di chat; minta file jika ada versi lengkap |
| R-12 | Audit lama menyesatkan | 🟢 Rendah | Dokumen ini menggantikan audit lama |
| R-13 | Test tidak ada | 🟡 Sedang | Ganti test default; tambah test onboarding/routing |
| R-14 | Keamanan backend nanti | 🔴 Tinggi (nanti) | Sanctum, role middleware, validasi upload, storage privat, jangan log data sensitif |

---

## 9. Struktur Folder yang Diusulkan

Struktur ini **mempertahankan** `lib/app` dan `lib/features` yang sudah ada, lalu menambah `lib/core` untuk kebutuhan lintas fitur. Tidak ada pemindahan folder existing.

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── navigation/
│   │   ├── app_bottom_navigation.dart
│   │   └── main_shell.dart
│   ├── routes/
│   │   ├── app_router.dart
│   │   └── app_routes.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_spacing.dart        (spacing + radius + sizes + elevation)
│   │   ├── app_text_styles.dart
│   │   └── app_theme.dart
│   └── widgets/
│       ├── primary_button.dart
│       ├── secondary_button.dart
│       ├── app_text_field.dart
│       ├── password_field.dart
│       ├── app_card.dart
│       ├── section_header.dart
│       ├── status_badge.dart
│       ├── empty_state.dart
│       ├── error_state.dart
│       ├── loading_view.dart
│       ├── app_logo.dart
│       └── (nanti) service_category_card.dart, document_upload_tile.dart,
│                   application_timeline.dart, transaction_list_tile.dart
├── core/
│   ├── config/app_config.dart
│   ├── storage/local_storage.dart
│   ├── storage/session_store.dart
│   ├── network/api_client.dart     (Tahap 3)
│   └── utils/validators.dart
├── features/
│   ├── splash/screens/splash_screen.dart
│   ├── onboarding/
│   │   ├── screens/onboarding_screen.dart
│   │   └── widgets/onboarding_page.dart
│   ├── auth/screens/login_screen.dart
│   ├── home/screens/home_screen.dart
│   ├── pawn/screens/pawn_screen.dart
│   ├── history/screens/history_screen.dart
│   └── profile/screens/profile_screen.dart
└── shared/                          (nanti: model/provider lintas fitur)
```

**Backend (baru, di luar Flutter):**

```text
Project Akhir APP Mobile/
├── flutter_application_1/           ← existing, dipertahankan
└── gadaikan-api/                    ← baru, Laravel 13 + Sanctum + MySQL
    ├── app/Http/Controllers/Api/
    ├── app/Http/Controllers/Api/Admin/
    ├── app/Http/Middleware/
    ├── app/Http/Requests/
    ├── app/Models/
    ├── database/migrations/
    ├── database/seeders/
    └── routes/api.php
```

---

## 10. Rencana Implementasi per Tahap

### Tahap 0 — Audit (dokumen ini)

- [x] Petakan workspace, konfigurasi, dependency, routing, kode, database.
- [x] Identifikasi error build dan risiko.
- [x] Usulkan struktur folder.
- [x] Susun checklist Prompt 01 & 02.
- [ ] **Persetujuan user** ← sedang di sini.

### Tahap 1 — Design System & Fondasi Flutter (Prompt 01)

Fokus: **membuat aplikasi bisa dijalankan**, theme lengkap, komponen reusable, shell navigasi, environment config. Belum membuat form pengajuan, belum backend.

### Tahap 2 — Splash & Onboarding (Prompt 02)

Fokus: splash, onboarding 3 halaman, persistensi, routing guard, dan jembatan ke login/home.

### Tahap 3 — Backend Foundation & Autentikasi

- Buat Laravel `gadaikan-api/`.
- Konfigurasi `.env`, MySQL `gadaikan`, Sanctum, role (`nasabah`, `admin`, `petugas`).
- Migrasi `users`, `user_profiles`; endpoint register/login/logout/me.
- Flutter: ganti sesi demo dengan API nyata, simpan token di secure storage, register/login/logout, validasi.

### Tahap 4 — Pengajuan Gadai

- Migrasi `categories`, `pawn_applications`, `pawn_items`, `pawn_documents`.
- Endpoint pengajuan + upload dokumen (validasi tipe/ukuran, storage privat).
- Flutter: home dashboard, pilih kategori, form elektronik/emas/BPKB, upload, review & submit, status + timeline.

### Tahap 5 — Simulasi, Riwayat, Transaksi

- Konfigurasi simulasi dari backend (bukan hard-code).
- Flutter: simulasi, daftar/riwayat, detail transaksi, empty/error/loading state.

### Tahap 6 — Admin & Penaksiran

- Middleware role admin.
- Endpoint dashboard, list/detail, assessment, decision, request revision.
- Migrasi `pawn_assessments`, `pawn_offers`, `application_status_histories`, `admin_activity_logs`.
- Panel admin (Blade/Filament) opsional.

### Tahap 7 — Fitur Pendukung

- Notifikasi, outlet, promo, profil/edit profil, FAQ, pembayaran demo.
- Seed data demo.

### Tahap 8 — Polish & Pengujian

- Loading/error/empty di semua halaman.
- Validasi Flutter + Laravel.
- Feature test auth/pengajuan/status.
- Uji Android kecil (360dp) dan besar (412dp), text scale, keyboard.
- Dokumentasi cara menjalankan dan data demo.

---

## 11. File yang Akan Dibuat / Diubah pada Tahap 1–2

> **Belum satu pun file di bawah ini diubah.** Daftar ini untuk persetujuan.

### 11.1 File existing yang akan diubah isinya

| File | Perubahan | Alasan |
|---|---|---|
| `pubspec.yaml` | Tambah `shared_preferences ^2.5.6`, `flutter_secure_storage ^11.2.0`; daftarkan `assets/fonts/`; update deskripsi | Persistensi onboarding + sesi; font stabil |
| `lib/main.dart` | `WidgetsFlutterBinding.ensureInitialized()`, bootstrap singkat | Persiapan storage sebelum UI |
| `lib/app/app.dart` | Theme, router, title, batas text scale, locale | Konsistensi aplikasi |
| `lib/app/routes/app_router.dart` | Tulis ulang: `StatefulShellRoute.indexedStack` + route auth di luar shell + redirect guard | Memperbaiki error `builder` dan bottom nav |
| `lib/app/theme/app_colors.dart` | Tambah token soft/overlay; pertahankan token existing | Status badge, card, state |
| `lib/app/theme/app_text_styles.dart` | Lengkapi skala tipografi; pakai font Inter bundled | Keterbacaan dan konsistensi |
| `lib/app/theme/app_spacing.dart` | Tambah skala 8pt, radius, elevation, ukuran komponen; hapus import tak terpakai | Token desain lengkap |
| `lib/app/theme/app_theme.dart` | ThemeData lengkap; hapus `background` deprecated; theme tombol/input/card/chip/snackbar/dialog/nav | Design system terpusat |
| `lib/app/widgets/primary_button.dart` | Tinggi 48–52, full-width opsional, loading/disabled, icon | Sesuai DESIGN |
| `lib/app/widgets/secondary_button.dart` | Sama, varian outline | Sesuai DESIGN |
| `lib/features/home/screens/home_screen.dart` | Tulis ulang sebagai dashboard skeleton (sapaan, layanan, simulasi, pengajuan terakhir, empty state) | Saat ini error dan double Scaffold |
| `test/widget_test.dart` | Ganti test counter dengan smoke test Gadaikan | Test lama tidak valid |
| `android/app/build.gradle.kts` | `applicationId = "com.gadaikan.app"`; minSdk tetap 24 | Identitas aplikasi |
| `android/app/src/main/AndroidManifest.xml` | Label `Gadaikan`; tambah `INTERNET` | Nama aplikasi + akses API release |
| `README.md` (opsional) | Cara menjalankan Flutter + Laravel, base URL per device | Dokumentasi |

**Tidak ada file yang akan dihapus.** Perubahan pada `test/widget_test.dart` dan `home_screen.dart` adalah penulisan ulang isi, bukan penghapusan file.

### 11.2 File baru — Fondasi (Tahap 1)

| File | Fungsi |
|---|---|
| `lib/app/routes/app_routes.dart` | Konstanta path/nama route |
| `lib/app/navigation/app_bottom_navigation.dart` | Bottom nav 4 tab, label + ikon, active/inactive |
| `lib/app/navigation/main_shell.dart` | Shell scaffold + `SafeArea` untuk tab |
| `lib/app/widgets/app_text_field.dart` | Input teks dengan label, hint, error, prefix/suffix |
| `lib/app/widgets/password_field.dart` | Password + show/hide |
| `lib/app/widgets/app_card.dart` | Kartu radius 16, border/shadow tipis |
| `lib/app/widgets/section_header.dart` | Judul bagian + aksi opsional |
| `lib/app/widgets/status_badge.dart` | Badge status dengan teks + warna (tidak hanya warna) |
| `lib/app/widgets/empty_state.dart` | Empty state + CTA |
| `lib/app/widgets/error_state.dart` | Error state + tombol coba lagi |
| `lib/app/widgets/loading_view.dart` | Loading terpusat |
| `lib/app/widgets/app_logo.dart` | Wordmark GADAIKAN + tagline (dipakai splash/home) |
| `lib/core/config/app_config.dart` | `API_BASE_URL`, `APP_ENV` via `--dart-define`; tanpa URL produksi |
| `lib/core/utils/validators.dart` | Validasi email/HP/password/nama |
| `lib/features/pawn/screens/pawn_screen.dart` | Tab Pengajuan minimal + empty state |
| `lib/features/history/screens/history_screen.dart` | Tab Riwayat minimal + empty state |
| `lib/features/profile/screens/profile_screen.dart` | Tab Profil minimal + tombol keluar (setelah sesi ada) |
| `assets/fonts/Inter-Regular.ttf` | Font bundled |
| `assets/fonts/Inter-Medium.ttf` | Font bundled |
| `assets/fonts/Inter-SemiBold.ttf` | Font bundled |
| `assets/fonts/Inter-Bold.ttf` | Font bundled |

### 11.3 File baru — Splash & Onboarding (Tahap 2)

| File | Fungsi |
|---|---|
| `lib/features/splash/screens/splash_screen.dart` | Wordmark, tagline, loading singkat, bootstrap status |
| `lib/features/onboarding/screens/onboarding_screen.dart` | 3 halaman, indikator, Lewati/Lanjutkan/Mulai |
| `lib/features/onboarding/widgets/onboarding_page.dart` | Layout satu halaman onboarding |
| `lib/features/auth/screens/login_screen.dart` | Login minimal (UI + validasi); detail keputusan di bawah |
| `lib/core/storage/local_storage.dart` | Wrapper `shared_preferences` untuk flag onboarding |
| `lib/core/storage/session_store.dart` | Wrapper `flutter_secure_storage` untuk sesi/token |
| `test/features/onboarding/onboarding_flow_test.dart` | Test persistensi + routing onboarding |
| `test/app/routing_test.dart` | Test splash → onboarding/login/home |

### 11.4 File yang **tidak** akan disentuh pada Tahap 1–2

- `PRD_Gadaikan.md`, `DESIGN_Gadaikan.md` — dokumen acuan, tidak diubah.
- Seluruh folder `android/` selain dua file konfigurasi di atas.
- `ios/`, `macos/`, `linux/`, `web/`, `windows/` — tidak diubah.
- `pubspec.lock` — berubah otomatis setelah `flutter pub get`; bukan edit manual.

---

## 12. Checklist Tahap 1 — Design System & Fondasi (Prompt 01)

### 12.1 Kesehatan build

- [ ] Buat semua file yang dirujuk router dan home.
- [ ] Ganti `GoRouter.builder` dengan `StatefulShellRoute.indexedStack`.
- [ ] Hapus double `Scaffold`/`SafeArea`.
- [ ] Perbaiki `test/widget_test.dart`.
- [ ] `flutter analyze` → **0 error** (warning/info wajar diminimalkan).
- [ ] `flutter test` → lulus.

### 12.2 Theme terpusat

- [ ] `AppColors`: Navy, Gold, background, surface, text primary/secondary, border, success, warning, danger, info + varian soft.
- [ ] `AppTextStyles`: heading 22–26, section 16–18, body 14–16, caption 12–13, nominal 22–28 bold; maksimal 3 bobot per layar.
- [ ] `AppSpacing`: skala 4/8/12/16/20/24/32; padding horizontal 20.
- [ ] Radius: kartu 16, tombol 12, input 12.
- [ ] Elevation tipis; hindari shadow berat.
- [ ] Ukuran tombol 48–52; input 50–54.
- [ ] `AppTheme`: `ColorScheme` lengkap, `textTheme`, `appBarTheme`, `elevatedButtonTheme`, `outlinedButtonTheme`, `inputDecorationTheme`, `cardTheme`, `chipTheme`, `dividerTheme`, `snackBarTheme`, `dialogTheme`, `navigationBarTheme`/`bottomNavigationBarTheme`, `progressIndicatorTheme`.
- [ ] Tidak memakai API deprecated (`ColorScheme.background`).
- [ ] `useMaterial3: true`.
- [ ] Kontras teks memadai; Gold tidak dipakai untuk teks kecil di atas putih.

### 12.3 Widget reusable

- [ ] `PrimaryButton` — loading, disabled, icon opsional, tinggi 48–52, full-width opsional.
- [ ] `SecondaryButton` — outline, loading, disabled.
- [ ] `AppTextField` — label, hint, helper, error inline, prefix/suffix, keyboard type, `textInputAction`.
- [ ] `PasswordField` — show/hide, validasi, error inline.
- [ ] `AppCard` — radius 16, padding konsisten, border/shadow tipis.
- [ ] `SectionHeader` — judul + aksi "Lihat semua" opsional.
- [ ] `StatusBadge` — teks + warna; tidak hanya warna.
- [ ] `EmptyState` — ikon, judul, deskripsi, CTA.
- [ ] `ErrorState` — pesan ramah + tombol "Coba lagi".
- [ ] `LoadingView` — indikator + pesan opsional.
- [ ] Semua widget menerima parameter; tidak ada data bisnis hard-coded.
- [ ] Semua area sentuh ≥ 44–48 px; ada `Semantics`/label yang jelas.

### 12.4 Routing & bottom navigation

- [ ] `AppRoutes` berisi konstanta path/nama.
- [ ] Route di luar shell: `/splash`, `/onboarding`, `/masuk` (login).
- [ ] Shell 4 tab: `/beranda`, `/pengajuan`, `/riwayat`, `/profil`.
- [ ] Tab aktif Primary, tidak aktif Text Secondary; label di bawah ikon.
- [ ] State tiap tab dipertahankan (`indexedStack`).
- [ ] Tombol back berperilaku wajar; tidak keluar aplikasi dari tab non-root.
- [ ] Splash/onboarding/login **tanpa** bottom navigation.
- [ ] Route guard belum aktif sampai Tahap 2; siapkan strukturnya.

### 12.5 Environment & API

- [ ] `AppConfig` membaca `API_BASE_URL` dan `APP_ENV` dari `--dart-define`.
- [ ] Tidak ada URL produksi yang dikarang.
- [ ] Dokumentasi base URL:
  - Web/desktop: `http://127.0.0.1:8000/api`
  - Emulator Android: `http://10.0.2.2:8000/api`
  - Perangkat fisik: `http://<IP-LAN>:8000/api`
- [ ] Tidak ada secret/API key di repository.
- [ ] Siapkan `ApiClient` (Dio) di Tahap 3, bukan sekarang.

### 12.6 Screen minimal (bukan semua fitur)

- [ ] `HomeScreen`: sapaan, hero CTA "Ajukan Gadai", 3 kartu layanan (Elektronik, Emas, BPKB), kartu simulasi, "Pengajuan Terakhir" dengan empty state.
- [ ] `PawnScreen`: judul + empty state + CTA menuju kategori (route kategori menyusul).
- [ ] `HistoryScreen`: judul + empty state.
- [ ] `ProfileScreen`: data akun dummy/placeholder yang jelas + tombol keluar (jika sesi sudah ada).
- [ ] Tidak membuat form pengajuan/upload/detail pada tahap ini.
- [ ] Semua screen memakai `SafeArea` dan scroll yang benar.
- [ ] Uji lebar 320/360/412 dp; tidak overflow.

### 12.7 Android

- [ ] `applicationId` diganti `com.gadaikan.app`.
- [ ] Label aplikasi `Gadaikan`.
- [ ] `INTERNET` di manifest utama.
- [ ] Cleartext HTTP hanya untuk debug (atau `network_security_config` khusus dev).
- [ ] `minSdk 24`, `targetSdk 36`, `compileSdk 36`; tidak menurunkan target.
- [ ] `flutter build apk --debug` berhasil (setelah toolchain siap).

---

## 13. Checklist Tahap 2 — Splash & Onboarding (Prompt 02)

### 13.1 Splash

- [ ] Latar Navy (`AppColors.primary`/`primaryDark`) dengan aksen Gold halus.
- [ ] Wordmark teks **GADAIKAN** orisinal (bukan logo GAOL).
- [ ] Tagline: **“Solusi Gadai dalam Genggaman”**.
- [ ] Indikator loading singkat (target 1,2–1,5 detik; jangan menahan user).
- [ ] Bootstrap membaca status onboarding + sesi.
- [ ] Jika sesi valid → `/beranda`.
- [ ] Jika onboarding selesai tetapi belum login → `/masuk`.
- [ ] Jika onboarding belum selesai → `/onboarding`.
- [ ] Jika terjadi error storage → fallback aman (onboarding/login), tampilkan pesan ramah.
- [ ] Tidak ada `await` tanpa batas yang membuat splash macet.

### 13.2 Onboarding

- [ ] Maksimal 3 halaman.
- [ ] Halaman 1: **“Pilih jenis barang”** — elektronik, emas, BPKB.
- [ ] Halaman 2: **“Ajukan dengan mudah”** — lengkapi data dan unggah dokumen.
- [ ] Halaman 3: **“Pantau prosesnya”** — lihat perkembangan pengajuan.
- [ ] Ilustrasi/ikon orisinal (Material Icons boleh, bukan aset GAOL).
- [ ] Indikator halaman (dots) yang jelas.
- [ ] Tombol **Lewati** di halaman 1–2.
- [ ] Tombol **Lanjutkan** di halaman 1–2.
- [ ] Tombol **Mulai** di halaman 3.
- [ ] `PageView` bisa di-swipe; indikator ikut berubah.
- [ ] Tombol back Android berperilaku wajar (kembali halaman, bukan keluar).
- [ ] Layout aman di 320/360 dp; teks tidak terpotong.
- [ ] Teks dan tombol memakai komponen/theme Tahap 1.

### 13.3 Persistensi

- [ ] Gunakan `shared_preferences` (bukan secure storage untuk flag non-sensitif).
- [ ] Key berversi, mis. `onboarding_completed_v1`.
- [ ] **Lewati** dan **Mulai** sama-sama menandai onboarding selesai.
- [ ] Onboarding tidak muncul lagi setelah selesai (kecuali data aplikasi dihapus).
- [ ] Flag tidak dihapus saat logout.
- [ ] Ada test: first launch → onboarding; setelah selesai → login.

### 13.4 Autentikasi / jembatan ke login

- [ ] `SessionStore` memakai `flutter_secure_storage` untuk token/sesi.
- [ ] Splash memeriksa sesi; jika ada → home.
- [ ] Layar login minimal tersedia (nomor HP/email + password, show/hide, validasi inline, tombol Masuk, link Daftar).
- [ ] **Keputusan diperlukan:** sesi demo berlabel vs berhenti di layar login.
  - **Rekomendasi:** sesi demo berlabel “Mode demo — autentikasi backend menyusul” agar alur splash → onboarding → login → home bisa diuji sekarang; diganti Sanctum di Tahap 3.
- [ ] Logout menghapus sesi dan kembali ke login.
- [ ] Tidak mengklaim autentikasi nyata sebelum Laravel terhubung.
- [ ] Tidak menyimpan password mentah.

### 13.5 Routing

- [ ] Redirect guard terpusat di `AppRouter`/`refreshListenable`.
- [ ] Splash/onboarding/login tidak memakai bottom nav.
- [ ] Setelah login → `/beranda`.
- [ ] Setelah logout → `/masuk`.
- [ ] Deep link ke halaman privat saat belum login → `/masuk`.
- [ ] Tidak ada loop redirect.

### 13.6 Pengujian

- [ ] Widget test splash menampilkan wordmark + tagline.
- [ ] Test onboarding: 3 halaman, tombol Lanjut/Mulai/Lewati.
- [ ] Test persistensi: flag tersimpan, onboarding tidak muncul lagi.
- [ ] Test routing: sesi ada → home; sesi tidak ada → login/onboarding.
- [ ] Uji lebar 320 dp dan text scale 1.3; tidak overflow.
- [ ] `flutter analyze` tetap 0 error; `flutter test` lulus.
- [ ] Uji manual di Chrome; uji Android setelah toolchain siap.

---

## 14. Keputusan yang Perlu Persetujuan

| # | Keputusan | Rekomendasi |
|---|---|---|
| D-1 | Setujui rencana dan mulai Tahap 1? | **Ya**, mulai Tahap 1 dulu; Tahap 2 setelah Tahap 1 bersih |
| D-2 | Lokasi Laravel | Sibling: `Project Akhir APP Mobile/gadaikan-api/` |
| D-3 | Versi Laravel | Laravel 13.x + Sanctum 4.x + MySQL 8.4 |
| D-4 | `applicationId` | `com.gadaikan.app` (namespace Android tetap sampai rename penuh disetujui) |
| D-5 | Auth Tahap 2 | Sesi demo berlabel, diganti Sanctum di Tahap 3 |
| D-6 | Font | Bundle Inter di `assets/fonts/`, lepas ketergantungan fetch runtime |
| D-7 | Git | `git init` + commit baseline sebelum perubahan |
| D-8 | Setup Android | Setujui pemasangan cmdline-tools/platform 36/system image/AVD (unduhan besar) atau user menyiapkan sendiri |
| D-9 | README | Perbarui `README.md` dengan cara menjalankan Flutter + Laravel |

---

## 15. Cara Menjalankan

### 15.1 Kondisi saat ini

Aplikasi **belum bisa dijalankan** karena 14 error kompilasi. Jangan menilai UI sebelum Tahap 1 selesai.

```powershell
cd "C:\Users\fauzanbintang\Downloads\Project Akhir APP Mobile\flutter_application_1"
flutter pub get
flutter analyze   # saat ini: 14 error
```

### 15.2 Setelah Tahap 1–2 (Flutter)

```powershell
cd "C:\Users\fauzanbintang\Downloads\Project Akhir APP Mobile\flutter_application_1"
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

Android (setelah toolchain siap):

```powershell
flutter doctor --android-licenses
flutter emulators --create --name gadaikan_pixel
flutter emulators --launch gadaikan_pixel
flutter run -d emulator-5554
```

Dengan base URL kustom:

```powershell
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

### 15.3 Laravel (setelah Tahap 3 dimulai)

```powershell
# Jalankan MySQL dari Laragon terlebih dahulu, lalu:
cd "C:\Users\fauzanbintang\Downloads\Project Akhir APP Mobile\gadaikan-api"
composer install
Copy-Item .env.example .env
php artisan key:generate
php artisan migrate --seed
php artisan serve
```

API default: `http://127.0.0.1:8000/api`.

---

## 16. Kriteria Selesai Audit

- [x] Kondisi project terpetakan (Flutter, Android, backend, database).
- [x] Error build dan gap fitur teridentifikasi.
- [x] Risiko dan mitigasi tercatat.
- [x] Struktur folder usulan konsisten dengan project existing.
- [x] Checklist Tahap 1 & 2 tersusun.
- [x] Daftar file yang akan dibuat/diubah dilaporkan.
- [x] Tidak ada file existing yang dihapus atau diubah dalam audit ini.
- [ ] **Rencana disetujui user** ← menunggu konfirmasi.
