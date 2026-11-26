# Gadaikan

Aplikasi pengajuan gadai digital untuk prototipe akademik. Dibangun dengan
Flutter (Android) dan disiapkan untuk backend Laravel REST API.

> **Status:** Tahap 1 (Design System & Fondasi) dan Tahap 2 (Splash &
> Onboarding) selesai. Backend Laravel dan fitur pengajuan belum dibuat.

## Fitur yang sudah berjalan

- Splash screen dengan wordmark **GADAIKAN** dan tagline
  “Solusi Gadai dalam Genggaman”.
- Onboarding 3 halaman: pilih jenis barang, ajukan dengan mudah, pantau
  prosesnya.
- Tombol **Lewati**, **Lanjutkan**, dan **Mulai** berfungsi.
- Status onboarding disimpan di perangkat, sehingga tidak muncul terus-menerus.
- Login dan registrasi **mode demo** (data hanya tersimpan di perangkat).
- Bottom navigation: Beranda, Pengajuan, Riwayat, Profil.
- Theme terpusat Navy Blue + Gold, komponen reusable, empty state, loading,
  error state, dan status badge.
- Halaman Beranda, Pengajuan, Riwayat, dan Profil (kerangka fungsional).

## Yang belum dibuat

- Backend Laravel, database MySQL, dan autentikasi Sanctum.
- Form pengajuan elektronik/emas/BPKB, upload dokumen, simulasi, dan detail
  transaksi.
- Panel admin, notifikasi, outlet, promo, FAQ, dan pembayaran demo.

## Menjalankan

### Web (paling cepat untuk melihat UI)

```powershell
cd "C:\Users\fauzanbintang\Downloads\Project Akhir APP Mobile\flutter_application_1"
flutter pub get
flutter run -d chrome
```

### Android

```powershell
flutter run -d <device-id>
```

Build APK debug:

```powershell
flutter build apk --debug
```

Hasil build: `build\app\outputs\flutter-apk\app-debug.apk`.

> Catatan: emulator Android belum tersedia di mesin ini (belum ada AVD/system
> image). Build APK sudah berhasil, tetapi uji manual di emulator perlu
> disiapkan melalui Android Studio atau `sdkmanager`.

### Base URL API

Base URL dibaca dari `--dart-define`; tidak ada URL produksi yang
di-hard-code.

```powershell
# Emulator Android
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api

# Perangkat fisik (ganti dengan IP LAN komputer)
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
```

Default pengembangan: `http://127.0.0.1:8000/api`.

## Akun demo

Belum ada autentikasi backend. Gunakan:

- Nomor HP: `081234567890` (atau email apa pun)
- Kata sandi: minimal 8 karakter

Data demo disimpan di perangkat. Jangan memasukkan data identitas asli.

## Struktur project

```text
lib/
├── app/
│   ├── navigation/     bottom navigation + shell
│   ├── routes/         GoRouter + konstanta route
│   ├── theme/          warna, spacing, tipografi, ThemeData
│   └── widgets/        komponen reusable
├── core/
│   ├── config/         AppConfig (API base URL)
│   ├── providers/      provider Riverpod
│   ├── state/          SessionController
│   ├── storage/        LocalStorage + SessionStore
│   └── utils/          validators
└── features/
    ├── splash/
    ├── onboarding/
    ├── auth/
    ├── home/
    ├── pawn/
    ├── history/
    └── profile/
```

## Pemeriksaan kualitas

```powershell
flutter analyze
flutter test
flutter build web --release
flutter build apk --debug
```

Status terakhir:

- `flutter analyze`: tidak ada issue.
- `flutter test`: 6 test lulus.
- `flutter build web --release`: berhasil.
- `flutter build apk --debug`: berhasil.

## Dokumen

- `PRD_Gadaikan.md` — kebutuhan produk.
- `DESIGN_Gadaikan.md` — design system dan spesifikasi UI.
- `AUDIT_Gadaikan.md` — audit workspace, risiko, dan rencana tahap berikutnya.
