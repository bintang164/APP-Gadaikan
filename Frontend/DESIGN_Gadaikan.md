# DESIGN SYSTEM & UI/UX SPECIFICATION

## Gadaikan --- Flutter Mobile App

**Versi:** 1.0\
**Arah visual:** modern, terpercaya, sederhana, ramah pengguna\
**Platform utama:** Android\
**Referensi alur:** aplikasi GAOL yang diberikan pemilik proyek\
**Catatan:** buat visual orisinal; jangan menyalin logo, screenshot,
ilustrasi, atau aset eksklusif aplikasi referensi.

------------------------------------------------------------------------

## 1. Design Principles

1.  **Trust first:** informasi biaya, status, dan langkah berikutnya
    harus jelas.
2.  **Simple journey:** pengajuan gadai dibuat bertahap dan tidak
    membingungkan.
3.  **Readable:** ukuran teks, kontras, dan jarak antarkomponen nyaman
    dibaca.
4.  **Consistent:** tombol, input, kartu, ikon, dan status memakai pola
    konsisten.
5.  **Honest feedback:** tampilkan loading, sukses, gagal, dan status
    kosong secara nyata; jangan menampilkan transaksi palsu sebagai
    transaksi sungguhan.

## 2. Visual Identity

### 2.1 Warna

Gunakan tema **Navy Blue + Gold**.

  Token            Hex         Penggunaan
  ---------------- ----------- -----------------------------------------
  Primary          `#173B66`   App bar, tombol utama, elemen identitas
  Primary Dark     `#102B4C`   Header/penekanan
  Primary Soft     `#EAF1F8`   Latar kartu/selected state
  Accent Gold      `#D9A441`   Aksen emas, highlight, ikon tertentu
  Background       `#F6F8FB`   Latar utama
  Surface          `#FFFFFF`   Kartu dan modal
  Text Primary     `#17212F`   Teks utama
  Text Secondary   `#667085`   Teks pendukung
  Border           `#E4E8EF`   Garis input/kartu
  Success          `#16865B`   Berhasil/disetujui
  Warning          `#C98216`   Menunggu/perlu perhatian
  Danger           `#C83E4D`   Ditolak/gagal
  Info             `#3478C8`   Informasi

Pastikan kontras teks memadai. Jangan memakai gold untuk teks kecil di
atas latar putih jika kontrasnya rendah.

### 2.2 Tipografi

-   Gunakan **Inter** atau **Poppins** jika tersedia secara konsisten.
-   Heading halaman: 22--26 px, semibold/bold.
-   Heading bagian: 16--18 px, semibold.
-   Body: 14--16 px, regular.
-   Caption/helper: 12--13 px.
-   Angka nominal penting: 22--28 px, bold.
-   Gunakan maksimal 3 tingkat bobot font dalam satu layar.

### 2.3 Bentuk dan Spacing

-   Radius kartu: 16 px.
-   Radius tombol: 12 px.
-   Radius input: 12 px.
-   Tinggi tombol utama: 48--52 px.
-   Tinggi input: 50--54 px.
-   Padding layar horizontal: 20 px.
-   Jarak antarkomponen: kelipatan 8 px.
-   Gunakan elevation/shadow tipis; hindari bayangan berat.

### 2.4 Ikon dan Ilustrasi

-   Gunakan satu keluarga ikon yang konsisten (Material Symbols atau
    Lucide).
-   Ikon kategori: smartphone/laptop untuk elektronik, gem/ring untuk
    emas, car/document untuk BPKB.
-   Ilustrasi boleh menggunakan aset open-source atau ilustrasi buatan
    sendiri.
-   Jangan mengambil logo atau ilustrasi eksklusif dari GAOL.

## 3. Navigation Architecture

Bottom navigation: 1. **Beranda** --- dashboard. 2. **Pengajuan** ---
membuat dan memantau pengajuan. 3. **Riwayat** --- transaksi dan
pengajuan terdahulu. 4. **Profil** --- data akun dan pengaturan.

Gunakan label teks di bawah ikon. Tab aktif memakai Primary; tab tidak
aktif memakai Text Secondary.

## 4. Screen Specifications

### 4.1 Splash Screen

-   Logo teks GADAIKAN orisinal di tengah.
-   Tagline: "Solusi Gadai dalam Genggaman".
-   Latar Primary atau Background dengan aksen gold.
-   Tampilkan indikator loading seperlunya.
-   Arahkan pengguna ke onboarding atau home sesuai status login.

### 4.2 Onboarding

-   Maksimal 3 halaman.
-   Halaman 1: "Pilih jenis barang" --- elektronik, emas, BPKB.
-   Halaman 2: "Ajukan dengan mudah" --- isi data dan unggah dokumen.
-   Halaman 3: "Pantau prosesnya" --- status dan riwayat dalam satu
    aplikasi.
-   Tombol Lewati dan Lanjutkan; halaman terakhir memiliki tombol Mulai.

### 4.3 Login

-   Logo dan judul "Selamat datang kembali".
-   Input nomor HP/email.
-   Input password dengan show/hide.
-   Tombol Masuk.
-   Link Daftar akun dan Lupa password.
-   Validasi inline; jangan hanya mengandalkan snackbar.

### 4.4 Register

-   Nama lengkap.
-   Nomor HP.
-   Email (opsional jika autentikasi memakai nomor HP).
-   Password dan konfirmasi password.
-   Checkbox persetujuan syarat dan kebijakan privasi.
-   Tombol Buat Akun.

### 4.5 Home Dashboard

Susunan dari atas ke bawah: 1. Header sapaan dan avatar/profil. 2. Kartu
informasi/hero dengan headline singkat dan CTA "Ajukan Gadai". 3. Bagian
"Pilih Layanan" berisi tiga kartu kategori: Elektronik, Emas, BPKB. 4.
Kartu "Simulasi Gadai". 5. Bagian "Pengajuan Terakhir" dengan status
ringkas. 6. Banner informasi/promo yang datanya berasal dari backend. 7.
Bottom navigation.

Jangan memenuhi layar dengan terlalu banyak banner. Berikan ruang putih
yang cukup.

### 4.6 Pilih Kategori

-   Judul: "Mau gadai apa hari ini?"
-   Tiga kartu besar dengan ikon, nama kategori, dan deskripsi pendek.
-   Saat dipilih, tampilkan selected state dan lanjut ke form kategori
    terkait.

### 4.7 Form Gadai Elektronik

Field: - Jenis perangkat. - Merek. - Model/tipe. - Tahun pembelian
(opsional). - Kondisi fisik. - Kondisi fungsi. - Kelengkapan. -
Deskripsi. - Foto barang (minimal sesuai konfigurasi aplikasi).
Tampilkan indikator langkah, misalnya 1 dari 3. Beri petunjuk format dan
ukuran foto.

### 4.8 Form Gadai Emas

Field: - Jenis emas/perhiasan. - Kadar/karat (opsional jika tidak
diketahui). - Berat gram (estimasi pengguna). - Kondisi. - Foto
barang. - Sertifikat/bukti pembelian (opsional sesuai kebijakan demo).
Jelaskan bahwa data pengguna merupakan perkiraan dan hasil akhir perlu
pemeriksaan.

### 4.9 Form Gadai BPKB

Field: - Jenis kendaraan. - Merek/model. - Tahun kendaraan. - Nomor
polisi. - Nama pemilik sesuai dokumen. - Foto BPKB/dokumen pendukung. -
Foto kendaraan (jika diperlukan). Tampilkan peringatan privasi: dokumen
hanya digunakan untuk proses verifikasi dan tidak boleh terlihat oleh
pengguna lain.

### 4.10 Upload Document

-   Gunakan area upload dengan ikon kamera/galeri.
-   Tampilkan thumbnail setelah file dipilih.
-   Sediakan aksi ganti dan hapus.
-   Validasi ukuran dan tipe file.
-   Tampilkan progress upload dan error state.
-   Jangan menampilkan data dokumen sensitif secara terbuka di halaman
    umum.

### 4.11 Simulasi Gadai

-   Input estimasi nilai barang.
-   Pilihan tenor sesuai konfigurasi.
-   Tampilkan estimasi plafon, biaya, dan total.
-   Beri label jelas: "Hasil simulasi, bukan penawaran final".
-   CTA "Lanjutkan Pengajuan".
-   Semua parameter perhitungan berasal dari konfigurasi backend, bukan
    angka hard-coded tersebar di UI.

### 4.12 Review & Submit

-   Ringkasan kategori dan data barang.
-   Daftar foto/dokumen yang diunggah.
-   Informasi estimasi jika tersedia.
-   Checkbox pernyataan kebenaran data.
-   Tombol "Kirim Pengajuan".
-   Setelah sukses, tampilkan nomor pengajuan dan CTA "Lihat Status".

### 4.13 Status Pengajuan

-   Nomor pengajuan dan tanggal.
-   Badge status dengan teks dan warna.
-   Timeline: Dikirim → Ditinjau → Perlu Perbaikan/Disetujui/Ditolak.
-   Catatan admin jika ada.
-   CTA perbaiki data jika status `revision_required`.
-   Refresh data dari API; jangan mengandalkan status lokal saja.

### 4.14 Detail Penawaran/Transaksi

-   Kategori dan ringkasan barang.
-   Nilai taksiran.
-   Nominal yang disetujui.
-   Biaya dan tenor.
-   Tanggal mulai dan jatuh tempo.
-   Status transaksi.
-   Tombol terima/tolak penawaran jika status memungkinkan.
-   Untuk demo, tampilkan penjelasan bahwa nilai dan pembayaran
    merupakan simulasi.

### 4.15 Riwayat

-   Filter Semua, Pengajuan, Aktif, Selesai.
-   Kartu berisi nomor, kategori, tanggal, nominal (jika ada), dan
    status.
-   Empty state yang mengarahkan pengguna untuk membuat pengajuan.
-   Pagination atau infinite scroll bila data banyak.

### 4.16 Outlet dan Promo

-   Outlet: nama, alamat, jam operasional, nomor kontak (jika tersedia).
-   Promo: banner, judul, periode, deskripsi, syarat.
-   Data berasal dari API; jika belum ada data, tampilkan empty state
    yang rapi.

### 4.17 Notifikasi

-   Daftar pemberitahuan berdasarkan waktu.
-   Bedakan sudah dibaca dan belum dibaca.
-   Tap notifikasi membuka detail pengajuan/transaksi terkait.

### 4.18 Profil

-   Foto/avatar opsional.
-   Nama, nomor HP, email.
-   Edit profil.
-   Pusat bantuan/FAQ.
-   Kebijakan privasi dan syarat layanan.
-   Logout dengan dialog konfirmasi.

## 5. Component Library

Buat reusable widgets: - `PrimaryButton` - `SecondaryButton` -
`AppTextField` - `PasswordField` - `AppCard` - `ServiceCategoryCard` -
`StatusBadge` - `SectionHeader` - `EmptyState` - `ErrorState` -
`LoadingView` - `DocumentUploadTile` - `ApplicationTimeline` -
`TransactionListTile` - `AppBottomNavigation`

Komponen menerima parameter dan tidak mengandung data bisnis hard-coded
yang seharusnya berasal dari API.

## 6. State dan Feedback

Setiap halaman yang mengambil data harus memiliki: - Loading state. -
Success/content state. - Empty state. - Error state dengan aksi coba
lagi.

Setiap form harus memiliki: - Validasi wajib isi. - Validasi format. -
Pesan error di dekat field terkait. - Disable tombol saat submit
berlangsung. - Pencegahan double submit. - Konfirmasi sebelum aksi
penting.

## 7. Accessibility dan Responsive

-   Area sentuh tombol minimal sekitar 44--48 px.
-   Jangan menyampaikan status hanya dengan warna; sertakan teks.
-   Dukung text scaling secara wajar.
-   Hindari teks terlalu kecil.
-   Pastikan keyboard tidak menutupi input aktif.
-   Gunakan SafeArea dan scroll yang benar.
-   Uji pada ukuran layar Android kecil dan besar.

## 8. Flutter Implementation Guidance

-   Gunakan struktur feature-first yang rapi.
-   Pisahkan `screens`, `widgets`, `models`, `services`,
    `providers`/`state`, dan `routing`.
-   Gunakan satu pendekatan state management yang konsisten (misalnya
    Riverpod atau Provider).
-   Gunakan repository/service layer untuk komunikasi API.
-   Simpan base URL API di konfigurasi/environment, bukan hard-coded di
    banyak file.
-   Gunakan secure storage untuk token.
-   Gunakan image picker untuk mengambil foto.
-   Gunakan package yang aktif dan kompatibel; cek versi sebelum
    menambah dependency.
-   Buat theme terpusat: `AppColors`, `AppTextStyles`, `AppSpacing`,
    `AppTheme`.

## 9. Design Do / Don't

**Do** - Gunakan visual bersih, konsisten, dan terasa seperti produk
fintech lokal. - Utamakan keterbacaan nominal, biaya, dan status. -
Gunakan bahasa Indonesia yang sederhana. - Gunakan ikon dan ilustrasi
orisinal. - Beri konfirmasi sebelum pengajuan dikirim.

**Don't** - Jangan menyalin screenshot atau aset GAOL. - Jangan memakai
logo/nama GAOL di dalam aplikasi Gadaikan. - Jangan membuat semua
halaman hanya berupa placeholder. - Jangan menampilkan nominal, bunga,
atau status seolah-olah resmi tanpa sumber data. - Jangan membuat tombol
yang tidak memiliki aksi. - Jangan menampilkan data pribadi/dokumen
nasabah di halaman publik.

## 10. Definition of Done UI

-   Seluruh screen MVP tersedia.
-   Navigasi antar-screen berfungsi.
-   Design token dipakai konsisten.
-   Form memiliki validasi.
-   Loading, error, dan empty state tersedia.
-   Tampilan diuji pada emulator Android.
-   Tidak ada overflow pada ukuran layar umum.
-   Semua konten dummy diberi label demo jika dapat disalahartikan
    sebagai data nyata.
