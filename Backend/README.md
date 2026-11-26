# Gadaikan — Backend Laravel (REST API)

Backend untuk aplikasi Flutter Gadaikan. Kode ini mengikuti `PRD_Gadaikan.md`
dan `DESIGN_Gadaikan.md` di repo yang sama.

> **Status implementasi:** source lengkap, namun **belum dijalankan** di mesin
> pengembangan karena PHP/Composer tidak terpasang di environment lokal.
> Jalankan langkah di bawah pada mesin yang memiliki PHP 8.2+ dan Composer.
> Hasil pengujian dicatat di `E2E_TESTING.md`.

## Menjalankan

```powershell
cd "C:\Users\fauzanbintang\Downloads\Project Akhir APP Mobile\Backend"
copy .env.example .env
composer install
php artisan key:generate
New-Item -ItemType File -Path database\database.sqlite -Force | Out-Null
php artisan migrate --seed
php artisan serve
```

Base URL untuk Flutter:

```powershell
flutter run --dart-define=AUTH_MODE=api `
  --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```

Akun demo (development saja, ubah via `.env`):

- Admin: `admin.demo@gadaikan.test` / `demo1234`
- Nasabah: daftar lewat `POST /api/register`.

## Entitas & migrasi

`users`, `user_profiles`, `categories`, `pawn_applications`, `pawn_items`,
`pawn_documents`, `pawn_assessments`, `pawn_offers`, `pawn_transactions`,
`payments`, `outlets`, `promotions`, `notifications`,
`application_status_histories`, `admin_activity_logs`, `faqs`, dan
`simulation_configs`. Semua relasi memakai foreign key; index ditambahkan
pada kolom status, user, dan tanggal.

## Endpoint utama

Publik:

- `POST /api/register`, `POST /api/login`

Bearer (`auth:sanctum`):

- `POST /api/logout`, `GET /api/me`, `PUT /api/profile`
- `GET /api/categories`, `GET /api/simulation/config`
- `GET /api/outlets`, `GET /api/promotions`, `GET /api/faqs`
- `POST /api/pawn-applications/documents` (multipart, privat)
- `GET|POST /api/pawn-applications`, `GET /api/pawn-applications/{id}`
- `GET /api/pawn-applications/{id}/status-history`
- `POST /api/pawn-applications/{id}/accept-offer`
- `POST /api/pawn-applications/{id}/decline-offer`
- `GET /api/transactions`, `GET /api/transactions/{id}`
- `POST /api/transactions/{id}/demo-payment`
- `GET /api/notifications`, `POST /api/notifications/read-all`
- `POST /api/notifications/{id}/read`

Admin (`auth:sanctum` + middleware `admin`):

- `GET /api/admin/dashboard`
- `GET /api/admin/applications`, `GET /api/admin/applications/{id}`
- `GET /api/admin/applications/{id}/status-history`
- `GET /api/admin/applications/{id}/documents/{document}` (download privat)
- `POST /api/admin/applications/{id}/assessment`
- `POST /api/admin/applications/{id}/request-revision`
- `POST /api/admin/applications/{id}/review`
- `POST /api/admin/applications/{id}/decision`

## Arsitektur keamanan

- Password di-hash (cast `hashed`), token Sanctum disimpan di
  `personal_access_tokens`; logout menghapus token aktif.
- Middleware `admin` memeriksa `role = admin`; endpoint nasabah selalu
  memfilter data oleh `user_id` yang sedang login.
- Upload divalidasi ekstensi **dan** MIME, maksimal 5 MB, disimpan di
  `storage/app/private` (disk `local`), tidak pernah mengembalikan path/URL.
- Dokumen sensitif hanya bisa diambil lewat endpoint admin terotorisasi.
- `StatusTransitionService` satu-satunya tempat transisi status; setiap
  perubahan mencatat `application_status_histories` dan `admin_activity_logs`
  beserta aktor.
- `AssessmentRequest` dan `ReasonRequest` memvalidasi nominal tidak negatif,
  konsistensi plafon, serta alasan wajib untuk revisi/penolakan.
- `.env.example` tidak berisi kredensial produksi. Jangan log password,
  token, atau isi dokumen sensitif.

## Format response

Semua error validasi Laravel (422) berbentuk:

```json
{ "message": "The given data was invalid.", "errors": { "field": ["pesan"] } }
```

Resource mengembalikan `{ "data": ... }` untuk koleksi dan meta pagination
`{ "meta": { "current_page", "per_page", "total" } }`. Field memakai
`snake_case` agar sesuai dengan pem parser model Flutter.

## Test

```powershell
php artisan test
```

Test yang tersedia:

- `AuthTest` — registrasi, validasi 422, login 401, role admin.
- `EndToEndFlowTest` — alur lengkap nasabah + admin dari register sampai
  pembayaran demo dan riwayat.
- `DocumentSecurityTest` — validasi MIME/ukuran dan akses dokumen privat.

Lihat `E2E_TESTING.md` untuk checklist integrasi Flutter ↔ Laravel.
