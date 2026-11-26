# Gadaikan

Aplikasi pengajuan gadai digital untuk prototipe akademik. Dibangun dengan
Flutter (Android) dan disiapkan untuk backend Laravel REST API.

> **Status:** Prompt 01–10 selesai: design system, splash & onboarding,
> autentikasi, Home Dashboard, pemilihan kategori, form Elektronik/Emas/BPKB,
> upload dokumen, dan kalkulator simulasi. Backend Laravel dan beberapa
> fitur lanjutan masih memakai mode demo berlabel.

## Fitur yang sudah berjalan

- Splash screen dengan wordmark **GADAIKAN** dan tagline
  “Solusi Gadai dalam Genggaman”.
- Onboarding 3 halaman; status onboarding disimpan di perangkat.
- **Login & register** dengan validasi inline (wajib isi, format email/HP,
  konfirmasi kata sandi, persetujuan syarat & kebijakan privasi).
- Password dengan tombol show/hide; tombol dinonaktifkan saat request
  berjalan dan double submit dicegah.
- Error 401, 422 (per-field), timeout, dan koneksi ditampilkan dengan
  pesan yang mudah dipahami.
- Token disimpan di **secure storage**; kata sandi **tidak pernah**
  disimpan. Sesi login bertahan setelah aplikasi ditutup.
- Mode demo diberi label jelas; tidak ada klaim request API berhasil.
  Akun demo awal: `081234567890` / kata sandi minimal 8 karakter.
- Home Dashboard: sapaan + avatar, hero card, CTA Ajukan Gadai, Pilih
  Layanan (Elektronik/Emas/BPKB), kartu Simulasi Gadai, Pengajuan
  Terakhir, Info & Promo, dan bottom navigation.
- Kategori membuka form pengajuan; simulasi membuka kalkulator dengan
  disclaimer; pengajuan terakhir membuka detail.
- Loading, error dengan **Coba lagi**, dan empty state tersedia.
- **Pilih kategori**: tiga kartu dengan indikator terpilih, persyaratan
  kategori ditampilkan sebelum form, tombol Lanjut nonaktif tanpa kategori,
  serta penjelasan bahwa pengajuan tetap perlu pemeriksaan & persetujuan.
- **Form elektronik bertahap**: Identitas Perangkat → Kondisi &
  Kelengkapan → Unggah Berkas → Tinjau & Kirim. Chips untuk pilihan
  terstruktur, helper text, validasi, draf lokal, dan tombol Lanjut aktif
  hanya bila field wajib valid. Tidak ada taksiran harga otomatis.
- **Form emas**: chips jenis/kondisi, kadar opsional tervalidasi, berat
  numerik positif (0,01–10.000 gram), penjelasan bahwa berat/kadar masih
  perkiraan, tanpa harga emas real-time; taksiran final setelah pemeriksaan.
- **Form BPKB**: merek & model terpisah, tahun 4 digit, format nomor
  polisi, pemberitahuan privasi dokumen, nomor polisi disamarkan di
  ringkasan/detail, tanpa klaim pengecekan legalitas otomatis.
- **Upload dokumen**: picker kamera/galeri (`image_picker`), preview
  thumbnail, ganti/hapus, validasi JPG/PNG/PDF maks 5 MB, indikator jumlah
  berkas, progress, retry saat gagal, dan pesan error jelas. Multipart via
  Dio ke Laravel; metadata privat tanpa URL publik. Mode demo tidak
  mengklaim berkas tersimpan di server.
- **Simulasi gadai**: kategori, nilai barang, tenor dari konfigurasi,
  plafon/biaya/total sesuai rumus PRD, validasi kosong/nol/angka besar,
  label "parameter demo" dan CTA lanjut pengajuan.
- Riwayat, detail transaksi, outlet, promo, notifikasi, dan FAQ (mode demo
  berlabel).
- Theme terpusat Navy Blue + Gold dengan komponen reusable.

## Yang belum dibuat

- Backend Laravel, MySQL, dan Sanctum yang sebenarnya.
- Panel admin dan penaksiran sungguhan.
- Pembayaran/rekening bank sungguhan (semua masih simulasi demo).

## Menjalankan

```powershell
cd "C:\Users\fauzanbintang\Downloads\Project Akhir APP Mobile\flutter_application_1"
flutter pub get
flutter run -d chrome        # web
flutter run -d <device-id>   # Android
```

Build:

```powershell
flutter build apk --debug
flutter build web --release
```

Hasil: `build\app\outputs\flutter-apk\app-debug.apk` dan `build\web`.

> Emulator Android belum tersedia di mesin ini, tetapi build APK debug
> sudah berhasil. Uji manual di emulator perlu AVD/system image.

## Mode autentikasi & API

Default: **mode demo** (`AUTH_MODE=mock`). Tidak ada permintaan jaringan
yang dipura-pura berhasil. Untuk memakai backend Laravel/Sanctum:

```powershell
flutter run --dart-define=AUTH_MODE=api \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

Kontrak endpoint yang dipakai `ApiAuthService` (belum terverifikasi
karena backend belum ada):

- `POST /api/login` → `{token, user}`
- `POST /api/register` → `{token, user}`
- `POST /api/logout` (Bearer)
- `GET /api/me` (Bearer)

Base URL dibaca dari `--dart-define`; tidak ada URL produksi yang
di-hard-code. Enam belas endpoint lain mengikuti `PRD_Gadaikan.md`.

## Akun demo

- Nomor HP: `081234567890`, kata sandi: `demo1234` (atau minimal 8 karakter)
- Atau daftar akun demo baru lewat tombol **Daftar Akun**.

Data demo hanya disimpan di perangkat. Jangan memasukkan data identitas
atau dokumen asli.

## Struktur project

```text
lib/
├── app/                  tema, routing lama, widget reusable
├── core/
│   ├── auth/             AuthService (mock/API), AuthRepository, error
│   ├── config/           AppConfig (API base URL, AUTH_MODE)
│   ├── models/           AuthUser + model domain Gadaikan
│   ├── network/          ApiClient + pemetaan error Dio
│   ├── services/         GadaikanRepository (mock data)
│   ├── state/            AppState + SessionController
│   ├── storage/          LocalStorage + SecureSessionStore + InMemory
│   └── utils/            validator & formatter
└── features/
    ├── auth/             splash, onboarding, login, register
    ├── home/             dashboard + shell
    ├── pawn/             kategori, form, daftar, detail pengajuan
    ├── simulation/       kalkulator simulasi
    ├── history/, profile/, info/, transactions/
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
- `flutter test`: **23 test lulus** (auth, kategori/form, emas/BPKB, upload/simulasi, widget).
- `flutter build web --release`: berhasil.
- `flutter build apk --debug`: berhasil.

## Dokumen

- `PRD_Gadaikan.md` — kebutuhan produk.
- `DESIGN_Gadaikan.md` — design system dan spesifikasi UI.
- `AUDIT_Gadaikan.md` — audit workspace, risiko, dan rencana tahap berikutnya.
