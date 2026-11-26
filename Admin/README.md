# Gadaikan — Panel Admin (Web Terpisah)

Panel admin sengaja dibuat **terpisah** dari aplikasi Flutter nasabah dan
tidak ditambahkan ke bottom navigation nasabah. Ini aplikasi web statis
(HTML/CSS/JS) tanpa build step: buka `index.html` lewat static server.

## Menjalankan

```powershell
cd "C:\Users\fauzanbintang\Downloads\Project Akhir APP Mobile\Admin"
python -m http.server 8080
```

Buka `http://localhost:8080`.

## Konfigurasi

- Isi **API base URL**, misalnya `http://127.0.0.1:8000/api`.
- Pilih mode:
  - **Demo**: memakai data contoh berlabel; tombol aksi dinonaktifkan dan
    tidak ada klaim perubahan tersimpan di server.
  - **Laravel API**: login dengan akun admin, token disimpan di
    `sessionStorage`, dan peran diverifikasi lewat `GET /api/me`.

Tidak ada URL produksi yang di-hard-code.

## Fitur

- Ringkasan: total pengajuan, menunggu, diproses, disetujui, ditolak,
  transaksi aktif (`GET /api/admin/dashboard`).
- Daftar pengajuan: pencarian nomor/nama, filter status & kategori,
  pagination (`GET /api/admin/applications`).
- Detail admin: data nasabah sesuai hak akses, data barang, dokumen privat
  via endpoint terotorisasi, catatan internal, riwayat status.
- Aksi: minta revisi, proses pemeriksaan, setujui, tolak. Alasan wajib
  diisi untuk revisi dan penolakan.

## Endpoint yang dipakai

Semua endpoint admin mengirim header `Authorization: Bearer <token>` dan
wajib dilindungi middleware peran di Laravel:

- `POST /api/login`, `GET /api/me`
- `GET /api/admin/dashboard`
- `GET /api/admin/applications`
- `GET /api/admin/applications/{id}?include=status_history`
- `GET /api/admin/applications/{id}/documents/{docId}` (privat)
- `POST /api/admin/applications/{id}/request-revision` `{reason, internal_note}`
- `POST /api/admin/applications/{id}/review`
- `POST /api/admin/applications/{id}/decision`
  `{decision: approved|rejected, reason?, internal_note}`

Panel **tidak** mengubah status secara lokal. Setelah aksi berhasil, detail
dan daftar dimuat ulang dari server. Backend bertugas memvalidasi transisi,
mencatat aktor, dan menyimpan alasan.

## Keamanan

- Token hanya di `sessionStorage`, dikirim sebagai Bearer.
- Tidak ada URL file publik yang ditampilkan; dokumen diambil sebagai blob
  dan pratinjau dibuat dengan `URL.createObjectURL`, lalu dicabut saat tutup.
- Peran admin diperiksa sebelum dashboard dapat dipakai.

> Endpoint di atas mengikuti rancangan `PRD_Gadaikan.md` dan belum
> diverifikasi karena backend Laravel belum tersedia.
