# QA Final, Polishing & Dokumentasi — Gadaikan

Tanggal: 27 November 2026

Dokumen ini sengaja transparan: **status "Selesai" hanya untuk hal yang benar-benar
dijalankan/terverifikasi di environment lokal**. Item yang hanya ditulis sebagai
source tanpa dijalankan tidak diklaim selesai.

## Ringkasan status

| Area | Status | Bukti / Catatan |
|------|--------|-----------------|
| Flutter `flutter pub get` | **Selesai** | `Got dependencies!` |
| Flutter `flutter analyze` | **Selesai** | `No issues found!` |
| Flutter `flutter test` | **Selesai** | **112 test lulus** |
| Overflow 4 ukuran layar | **Selesai** | 15 layar × 320×640, 360×800, 390×844, 414×896 → 60 test lulus tanpa exception |
| Tombol & navigasi utama | **Selesai (widget test)** | CTA Ajukan Gadai → kategori → form terverifikasi; belum uji manual emulator |
| Loading / error / empty state | **Selesai (widget test)** | Diverifikasi pada daftar pengajuan & komponen state |
| Build APK debug | **Selesai** | `app-debug.apk` berhasil |
| Build Web release | **Selesai** | `build/web` berhasil |
| Uji manual di emulator/perangkat Android | **Belum Dikerjakan** | Tidak ada AVD/system image; build APK saja |
| Laravel source (migration, model, seeder, controller, request, resource, service, middleware) | **Selesai (kode)** | 18 migration, 3 feature test, lihat `Backend/README.md` |
| Laravel `php artisan test` / `route:list` / `migrate` | **Belum Dikerjakan** | PHP tidak terpasang; `composer -V` juga gagal karena memanggil `php` |
| Autorisasi & validasi backend runtime | **Belum Dikerjakan** | Source + test ditulis, tapi belum dieksekusi |
| Upload privat & akses dokumen runtime | **Belum Dikerjakan** | Source + `Storage::fake` test ditulis, belum dieksekusi |
| Integrasi end-to-end Flutter ↔ Laravel | **Belum Dikerjakan** | Runbook `Backend/E2E_TESTING.md` masih berisi "Belum dijalankan" |
| Panel admin web | **Perlu Perbaikan** | `node --check Admin/app.js` lulus; belum diuji di browser dengan API |
| Dokumentasi setup & endpoint | **Selesai** | `Frontend/README.md`, `Backend/README.md`, `Admin/README.md`, `Backend/E2E_TESTING.md`, dokumen ini |

## Perbaikan yang dilakukan saat QA

- `TransactionListTile` dan `StatusBadge`: `Expanded`/`Flexible` + ellipsis agar
  nomor, status, dan nominal tidak overflow di layar 320 px.
- `_InfoRow` pada detail transaksi serta header langkah form: label/value
  dibatasi dengan flex agar tidak melebar.
- Baris "Belum punya akun? Daftar Akun" pada Login diganti `Wrap`.
- `EmptyState` dan `ErrorState` dibungkus `SingleChildScrollView` agar konten
  panjang tidak overflow vertikal.
- Row "Estimasi Plafon Pinjaman" pada simulasi dibuat flex.

## Cara setup & menjalankan

### 1. Flutter (Android / Web)

```powershell
cd "C:\Users\fauzanbintang\Downloads\Project Akhir APP Mobile\flutter_application_1"
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
flutter run -d <device-id>
flutter build apk --debug
```

Mode demo default. Untuk memakai backend Laravel:

```powershell
flutter run --dart-define=AUTH_MODE=api --dart-define=API_BASE_URL=http://127.0.0.1:8000/api -d chrome
```

Folder project lokal tetap `flutter_application_1`; di GitHub project berada di
`Frontend/` (sesuai permintaan).

### 2. Laravel (backend)

```powershell
cd "C:\Users\fauzanbintang\Downloads\Project Akhir APP Mobile\Backend"
copy .env.example .env
composer install
php artisan key:generate
New-Item -ItemType File -Path database\database.sqlite -Force | Out-Null
php artisan migrate --seed
php artisan serve
```

Database default development: SQLite (`database/database.sqlite`). Untuk MySQL,
ubah `DB_CONNECTION=mysql` dan isi `DB_HOST`, `DB_PORT`, `DB_DATABASE`,
`DB_USERNAME`, `DB_PASSWORD` di `.env`.

Verifikasi wajib di mesin dengan PHP 8.2+:

```powershell
php artisan route:list
php artisan test
```

### 3. Panel admin

Buka `Admin/index.html` lewat static server:

```powershell
cd "C:\Users\fauzanbintang\Downloads\Project Akhir APP Mobile\Admin"
python -m http.server 8080
```

Isi API base URL yang sama, pilih mode **Laravel API**, login sebagai admin.

### 4. Daftar endpoint

Lihat `Backend/README.md` (bagian "Endpoint utama") dan `Backend/routes/api.php`.
Ringkasnya: `/api/register`, `/login`, `/logout`, `/me`, `/profile`,
`/categories`, `/simulation/config`, `/outlets`, `/promotions`, `/faqs`,
`/pawn-applications`, `/pawn-applications/{id}`, `/documents`,
`/transactions`, `/demo-payment`, `/notifications`, serta endpoint `/admin/*`.

### 5. Akun demo development

| Peran | Identitas | Kata sandi |
|-------|-----------|------------|
| Admin | `admin.demo@gadaikan.test` | `demo1234` |
| Nasabah | daftar via `POST /api/register` | `demo1234` (min. 8) |

Kredensial dibaca dari `.env` (`DEMO_ADMIN_*`). Jangan gunakan kredensial
produksi.

## Fitur selesai vs mock/demo

- **Fungsional & terverifikasi (Flutter):** auth + sesi token, onboarding,
  home, form Elektronik/Emas/BPKB, upload dokumen, simulasi, review/submit,
  daftar & riwayat berpagination, detail & timeline, penawaran, pembayaran
  demo, notifikasi, profil/FAQ/logout, panel admin terpisah.
- **Masih mock/demo berlabel:** data kategori/outlet/promo/FAQ/seed saat
  `AUTH_MODE` bukan `api`, nomor pengajuan lokal mode demo, catatan pembayaran
  demo, status/timeline lokal, dan tidak ada push notification sungguhan.
- **Belum terverifikasi runtime:** seluruh backend Laravel dan integrasi
  Flutter ↔ Laravel ↔ panel admin.

## Keterbatasan & pekerjaan lanjutan

1. Pasang PHP 8.2+ di mesin development, jalankan `composer install`,
   `migrate --seed`, `route:list`, dan `php artisan test`. Perbaiki bila ada
   error runtime yang baru muncul.
2. Jalankan runbook `Backend/E2E_TESTING.md` dan centang tabel hasilnya.
3. Uji manual di emulator/perangkat Android (belum tersedia AVD).
4. Uji panel admin di browser dengan backend berjalan, termasuk download
   dokumen privat dan middleware role.
5. Setelah integrasi lolos, ubah status di tabel ringkasan dari
   "Belum Dikerjakan" menjadi "Selesai" beserta output test.

## Kesimpulan jujur

Aplikasi Flutter **dapat dijalankan dan lulus QA otomatis** mengikuti
dokumentasi di atas. Backend **sudah memiliki source lengkap**, tetapi
**belum dibuktikan berjalan** karena PHP tidak tersedia di environment ini.
Karena itu kriteria "migration dan test berjalan" serta "satu alur end-to-end
berhasil" **belum terpenuhi** dan tidak diklaim selesai.
