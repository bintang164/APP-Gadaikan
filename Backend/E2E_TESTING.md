# Integrasi End-to-End Flutter ↔ Laravel

Dokumen ini adalah runbook dan catatan hasil pengujian. **Belum dijalankan**
karena PHP/Composer tidak tersedia di mesin lokal tempat kode ini dibuat.
Jangan menganggap hasil di bawah sebagai bukti sukses.

## Prasyarat

1. PHP 8.2+, Composer, SQLite atau MySQL.
2. Flutter SDK + Android/emulator atau Chrome.
3. Backend berjalan di `http://127.0.0.1:8000`.

```powershell
cd Backend
copy .env.example .env
composer install
php artisan key:generate
New-Item -ItemType File -Path database\database.sqlite -Force | Out-Null
php artisan migrate --seed
php artisan serve
```

```powershell
cd ..\flutter_application_1
flutter run --dart-define=AUTH_MODE=api --dart-define=API_BASE_URL=http://127.0.0.1:8000/api -d chrome
```

Panel admin terpisah: buka `Admin/index.html` lewat static server, isi API
base URL yang sama, pilih mode **Laravel API**, lalu login sebagai admin.

## Checklist alur

| # | Langkah | Endpoint / UI | Ekspektasi | Status |
|---|---------|---------------|------------|--------|
| 1 | Register nasabah | `POST /api/register` | 201, token, user role customer | Belum dijalankan |
| 2 | Login | `POST /api/login` | token + user; salah password 401 | Belum dijalankan |
| 3 | Home ambil profil/kategori | `GET /api/me`, `/categories` | 3 kategori aktif | Belum dijalankan |
| 4 | Pilih kategori | UI kategori | persyaratan tampil | Belum dijalankan |
| 5 | Isi form | UI elektronik/emas/BPKB | validasi 422 sesuai field | Belum dijalankan |
| 6 | Upload foto/dokumen | `POST /pawn-applications/documents` | 201, id, tanpa path publik; MIME & 5 MB | Belum dijalankan |
| 7 | Review & submit | `POST /pawn-applications` | 201, nomor dari server | Belum dijalankan |
| 8 | Pengajuan di akun nasabah | `GET /pawn-applications` | hanya milik login | Belum dijalankan |
| 9 | Admin login & lihat | `/api/login`, `/admin/applications` | 403 untuk customer | Belum dijalankan |
| 10 | Admin revisi/proses | `/admin/.../request-revision`, `/review` | status & timeline berubah | Belum dijalankan |
| 11 | Admin penaksiran & keputusan | `/admin/.../assessment`, `/decision` | plafon, biaya, tenor tersimpan | Belum dijalankan |
| 12 | Nasabah lihat timeline/penawaran | `GET /pawn-applications/{id}` | `status_history` dari server | Belum dijalankan |
| 13 | Terima/tolak penawaran | `/accept-offer`, `/decline-offer` | keputusan tercatat | Belum dijalankan |
| 14 | Transaksi terbentuk | `GET /transactions` | TRX-... muncul | Belum dijalankan |
| 15 | Pembayaran demo | `/demo-payment` | catatan `is_demo=true`, backend set lunas | Belum dijalankan |
| 16 | Riwayat konsisten | aplikasi + transaksi + notifikasi | nominal/status sama | Belum dijalankan |

## Hal yang perlu diverifikasi saat dijalankan

- [ ] Token Bearer dikirim di semua endpoint privat; logout menghapus token.
- [ ] Respons 422 dari Laravel dipetakan ke field Flutter (`fieldErrors`).
- [ ] Error jaringan/timeout menampilkan pesan ramah, bukan data palsu.
- [ ] Multipart upload benar-benar masuk `storage/app/private`.
- [ ] Pagination `meta.total/current_page` sesuai tampilan "Muat Lebih Banyak".
- [ ] Nominal dan status konsisten antara pengajuan, penawaran, transaksi,
      pembayaran, riwayat, dan notifikasi.
- [ ] User lain tidak bisa membaca pengajuan/transaksi/dokumen akun ini
      (404/403), termasuk lewat endpoint admin oleh customer.

## Cara mencatat hasil

Setelah menjalankan `php artisan test` dan alur manual di atas, ubah kolom
Status pada tabel menjadi **Lulus/Gagal** dan lampirkan output test di bawah:

```text
(Tempel output `php artisan test` di sini)
```
