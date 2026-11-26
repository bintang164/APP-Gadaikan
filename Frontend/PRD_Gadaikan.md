# PRODUCT REQUIREMENTS DOCUMENT (PRD)

## Project: Gadaikan

**Versi:** 1.0\
**Platform:** Android (Flutter)\
**Backend:** Laravel REST API\
**Database:** MySQL\
**Status:** Dokumen acuan pengembangan proyek akademik

------------------------------------------------------------------------

## 1. Ringkasan Produk

Gadaikan adalah aplikasi pengajuan gadai digital yang memungkinkan
pengguna mengajukan gadai barang elektronik, emas, dan BPKB kendaraan
melalui aplikasi Android. Pengguna dapat mengisi data barang, mengunggah
foto dan dokumen, melihat estimasi pinjaman, memantau status pengajuan,
serta melihat riwayat transaksi.

Gadaikan mengambil inspirasi alur layanan dari aplikasi GAOL yang
diberikan sebagai referensi oleh pemilik proyek. Gadaikan harus memiliki
identitas visual, susunan komponen, ikon, ilustrasi, teks, dan
implementasi kode sendiri. Jangan menyalin logo, aset, teks eksklusif,
atau kode sumber aplikasi referensi.

Untuk proyek akademik, proses penaksiran dan pembayaran dapat
menggunakan data simulasi. Jangan mengklaim bahwa aplikasi telah
terhubung ke lembaga gadai, layanan pembayaran, atau sistem resmi
apabila integrasi tersebut belum benar-benar tersedia.

## 2. Tujuan Produk

1.  Menyediakan pengalaman pengajuan gadai yang mudah dipahami melalui
    ponsel.
2.  Memisahkan alur pengajuan berdasarkan kategori barang: elektronik,
    emas, dan BPKB.
3.  Memudahkan pengguna memantau status pengajuan dan transaksi.
4.  Menyediakan simulasi estimasi pinjaman yang transparan dan dapat
    dikonfigurasi.
5.  Menyediakan panel admin untuk mengelola pengajuan dan proses
    penaksiran.
6.  Menghasilkan aplikasi Flutter yang terhubung ke backend Laravel dan
    database MySQL.

## 3. Target Pengguna dan Peran

### 3.1 Nasabah

-   Mendaftar dan masuk.
-   Mengelola profil.
-   Membuat pengajuan gadai.
-   Mengunggah foto barang dan dokumen.
-   Melihat estimasi dan status pengajuan.
-   Melihat detail transaksi serta riwayat pembayaran.

### 3.2 Admin

-   Masuk ke panel admin.
-   Melihat daftar pengajuan.
-   Memeriksa data dan lampiran.
-   Mengubah status pengajuan.
-   Memasukkan hasil penaksiran dan nominal pinjaman yang disetujui.
-   Mengelola kategori, outlet, promo, dan informasi aplikasi.

### 3.3 Petugas Penaksir (opsional)

-   Melihat pengajuan yang ditugaskan.
-   Memeriksa detail barang.
-   Mengisi hasil pemeriksaan dan rekomendasi taksiran.
-   Mengirim hasil kepada admin untuk keputusan akhir.

## 4. Ruang Lingkup MVP

### 4.1 Fitur Nasabah

  -----------------------------------------------------------------------
  ID                Fitur             Deskripsi         Prioritas
  ----------------- ----------------- ----------------- -----------------
  F-01              Splash screen     Menampilkan       Must
                                      identitas         
                                      Gadaikan saat     
                                      aplikasi dibuka   

  F-02              Onboarding        Menjelaskan       Should
                                      manfaat dan alur  
                                      singkat aplikasi  

  F-03              Registrasi        Membuat akun      Must
                                      dengan nama,      
                                      nomor HP/email,   
                                      dan kata sandi    

  F-04              Login/logout      Autentikasi dan   Must
                                      keluar dari akun  

  F-05              Beranda           Menampilkan       Must
                                      sapaan, pintasan  
                                      layanan, banner,  
                                      dan ringkasan     
                                      pengajuan         

  F-06              Kategori gadai    Memilih           Must
                                      elektronik, emas, 
                                      atau BPKB         

  F-07              Form pengajuan    Mengisi data      Must
                                      barang, kondisi,  
                                      deskripsi, dan    
                                      kontak            

  F-08              Unggah berkas     Mengunggah foto   Must
                                      barang dan        
                                      dokumen sesuai    
                                      kategori          

  F-09              Simulasi gadai    Menampilkan       Should
                                      estimasi          
                                      berdasarkan       
                                      parameter yang    
                                      dapat diatur      

  F-10              Konfirmasi        Meninjau data     Must
                    pengajuan         sebelum dikirim   

  F-11              Status pengajuan  Melihat tahapan   Must
                                      dan catatan       
                                      verifikasi        

  F-12              Detail transaksi  Melihat barang,   Must
                                      taksiran, nominal 
                                      disetujui, biaya, 
                                      dan jatuh tempo   

  F-13              Riwayat           Melihat pengajuan Must
                                      dan transaksi     
                                      sebelumnya        

  F-14              Pembayaran demo   Mencatat simulasi Should
                                      pembayaran tanpa  
                                      mengklaim         
                                      transaksi uang    
                                      sungguhan         

  F-15              Outlet            Melihat daftar    Should
                                      outlet dan detail 
                                      alamat/jam        
                                      operasional       

  F-16              Promo             Melihat daftar    Could
                                      informasi promo   
                                      yang dikelola     
                                      admin             

  F-17              Notifikasi        Menampilkan       Should
                                      pemberitahuan     
                                      perubahan status  

  F-18              Profil            Melihat dan       Must
                                      mengubah data     
                                      profil            

  F-19              Bantuan/FAQ       Menampilkan       Could
                                      pertanyaan umum   
                                      dan kontak        
                                      bantuan           
  -----------------------------------------------------------------------

### 4.2 Fitur Admin

1.  Login admin dengan hak akses terpisah dari nasabah.
2.  Dashboard ringkasan jumlah pengajuan berdasarkan status.
3.  Daftar, pencarian, filter, dan detail pengajuan.
4.  Pemeriksaan foto barang dan dokumen.
5.  Perubahan status pengajuan dengan catatan.
6.  Input hasil penaksiran: nilai taksiran, plafon yang disetujui,
    tenor, biaya, dan tanggal jatuh tempo.
7.  Pengelolaan kategori, outlet, promo, dan FAQ.
8.  Riwayat aktivitas admin untuk perubahan penting.

## 5. Alur Bisnis Utama

### 5.1 Pengajuan Gadai

1.  Nasabah login.
2.  Nasabah memilih kategori barang.
3.  Aplikasi menampilkan persyaratan berdasarkan kategori.
4.  Nasabah mengisi data barang dan data pendukung.
5.  Nasabah mengunggah foto/dokumen.
6.  Nasabah meninjau ringkasan pengajuan.
7.  Nasabah menyetujui pernyataan bahwa data yang dikirim benar.
8.  Sistem menyimpan pengajuan dengan status `submitted`.
9.  Nasabah mendapat nomor pengajuan dan dapat memantau status.

### 5.2 Pemeriksaan dan Penaksiran

1.  Admin membuka pengajuan berstatus `submitted`.
2.  Admin memeriksa kelengkapan data.
3.  Admin dapat meminta perbaikan dengan status `revision_required`.
4.  Jika data lengkap, admin mengubah status menjadi `under_review`.
5.  Admin/petugas mengisi hasil taksiran.
6.  Admin menetapkan keputusan `approved` atau `rejected`.
7.  Jika disetujui, detail nilai pinjaman, biaya, tenor, dan jatuh tempo
    ditampilkan kepada nasabah.
8.  Nasabah dapat menerima atau menolak penawaran.

### 5.3 Transaksi dan Pelunasan

1.  Setelah nasabah menerima penawaran, sistem membuat transaksi
    berstatus `active`.
2.  Sistem menampilkan rincian kewajiban dan tanggal jatuh tempo.
3.  Untuk versi demo, tombol pembayaran membuat catatan pembayaran
    simulasi.
4.  Setelah seluruh kewajiban dinyatakan lunas oleh admin/sistem demo,
    status transaksi menjadi `paid_off`.
5.  Setiap perubahan status tercatat dalam riwayat.

## 6. Status dan Aturan Transisi

Status pengajuan: - `draft`: belum dikirim. - `submitted`: sudah
dikirim. - `under_review`: sedang diperiksa. - `revision_required`:
perlu perbaikan dari nasabah. - `approved`: disetujui. - `rejected`:
ditolak. - `offer_accepted`: nasabah menerima penawaran. -
`offer_declined`: nasabah menolak penawaran. - `cancelled`: dibatalkan
sesuai aturan aplikasi.

Status transaksi: - `active`: transaksi aktif. - `payment_pending`:
pembayaran sedang menunggu konfirmasi. - `paid_off`: sudah lunas. -
`overdue`: melewati tanggal jatuh tempo (untuk simulasi sesuai aturan
yang dikonfigurasi). - `closed`: transaksi ditutup.

Jangan mengizinkan perubahan status secara acak dari aplikasi nasabah.
Transisi harus divalidasi di backend dan disimpan dalam log.

## 7. Persyaratan Data per Kategori

### 7.1 Elektronik

-   Jenis perangkat.
-   Merek dan model.
-   Tahun pembelian (opsional).
-   Kondisi fisik dan fungsi.
-   Kelengkapan (charger, dus, aksesori).
-   Foto barang dari beberapa sisi.
-   Nomor seri/IMEI bila relevan dan aman untuk kebutuhan verifikasi.
-   Catatan tambahan.

### 7.2 Emas

-   Jenis emas/perhiasan.
-   Kadar/karat jika diketahui.
-   Berat (gram) jika diketahui.
-   Foto barang.
-   Bukti pembelian/sertifikat jika tersedia.
-   Catatan kondisi.

### 7.3 BPKB

-   Jenis kendaraan.
-   Merek, model, tahun, dan nomor polisi.
-   Data kepemilikan sesuai dokumen.
-   Foto BPKB dan dokumen pendukung yang diperlukan.
-   Foto kendaraan bila diminta.
-   Informasi privasi dan persetujuan pemrosesan data.

Data sensitif seperti nomor identitas dan dokumen kendaraan harus
dibatasi aksesnya, tidak ditampilkan di log umum, dan disimpan dengan
kontrol keamanan yang sesuai.

## 8. Simulasi Pinjaman

Simulasi hanya memberikan perkiraan, bukan keputusan final. Parameter
seperti persentase taksiran, biaya layanan/sewa modal, tenor, dan batas
pinjaman harus disimpan sebagai konfigurasi backend agar dapat diubah
admin.

Contoh rumus demo: -
`estimasi_pinjaman = nilai_taksiran × persentase_plafon` -
`estimasi_biaya = estimasi_pinjaman × tarif_biaya × jumlah_periode` -
`estimasi_total = estimasi_pinjaman + estimasi_biaya`

Nilai tarif dan persentase di atas wajib diberi label simulasi dan
jangan ditetapkan sebagai tarif resmi. Nilai final hanya berasal dari
hasil pemeriksaan dan persetujuan yang tercatat.

## 9. Kebutuhan Halaman Flutter

1.  Splash Screen
2.  Onboarding
3.  Login
4.  Registrasi
5.  Lupa kata sandi (opsional untuk MVP)
6.  Home/Dashboard
7.  Pilih kategori gadai
8.  Form pengajuan per kategori
9.  Unggah foto/dokumen
10. Ringkasan pengajuan
11. Simulasi gadai
12. Daftar pengajuan
13. Detail pengajuan dan timeline status
14. Detail transaksi
15. Riwayat
16. Daftar outlet
17. Promo
18. Notifikasi
19. Profil dan pengaturan
20. FAQ/Bantuan

Bottom navigation yang disarankan: **Beranda, Pengajuan, Riwayat,
Profil**.

## 10. Kebutuhan Backend dan Database

Gunakan Laravel REST API dan MySQL. Rekomendasi entitas/tabel awal: -
`users` - `user_profiles` - `categories` - `pawn_applications` -
`pawn_items` - `pawn_documents` - `pawn_assessments` - `pawn_offers` -
`pawn_transactions` - `payments` - `outlets` - `promotions` -
`notifications` - `application_status_histories` - `admin_activity_logs`

Gunakan relasi foreign key, timestamps, validasi request, pagination,
dan soft delete jika sesuai. Pisahkan role nasabah, admin, dan petugas.
Gunakan Laravel Sanctum atau mekanisme token API yang sesuai.

## 11. Rancangan Endpoint API

Contoh endpoint REST: - `POST /api/register` - `POST /api/login` -
`POST /api/logout` - `GET /api/me` - `PUT /api/profile` -
`GET /api/categories` - `POST /api/pawn-applications` -
`GET /api/pawn-applications` - `GET /api/pawn-applications/{id}` -
`PUT /api/pawn-applications/{id}` -
`POST /api/pawn-applications/{id}/documents` -
`GET /api/pawn-applications/{id}/status-history` -
`GET /api/transactions` - `GET /api/transactions/{id}` -
`GET /api/outlets` - `GET /api/promotions` - `GET /api/notifications`

Endpoint admin (dilindungi middleware role): -
`GET /api/admin/applications` - `GET /api/admin/applications/{id}` -
`POST /api/admin/applications/{id}/assessment` -
`POST /api/admin/applications/{id}/decision` -
`POST /api/admin/applications/{id}/request-revision` -
`GET /api/admin/dashboard`

Sesuaikan nama dan metode endpoint saat implementasi. Jangan membuat
endpoint palsu yang tidak memiliki controller dan validasi.

## 12. Persyaratan Non-Fungsional

-   UI responsif untuk ukuran layar Android umum.
-   Navigasi konsisten dan mudah dipahami.
-   Validasi input di Flutter dan Laravel.
-   Password di-hash; jangan menyimpan password mentah.
-   Endpoint privat memerlukan autentikasi.
-   Validasi tipe dan ukuran file upload.
-   Simpan file pada storage privat bila berisi dokumen sensitif.
-   Pesan error mudah dipahami pengguna.
-   Loading, empty state, dan error state tersedia.
-   Gunakan environment variable untuk URL API dan kredensial.
-   Jangan menaruh secret/API key di repository.
-   Sediakan data seed/demo untuk presentasi.
-   Buat pengujian dasar untuk autentikasi, pengajuan, dan perubahan
    status.

## 13. Kriteria Penerimaan MVP

MVP dianggap berjalan jika: 1. Pengguna dapat registrasi, login, dan
logout. 2. Pengguna dapat memilih kategori gadai. 3. Pengguna dapat
mengisi dan mengirim pengajuan. 4. Foto/dokumen tersimpan dan dapat
diakses sesuai hak akses. 5. Pengajuan muncul pada daftar nasabah dan
dashboard admin. 6. Admin dapat memeriksa, memberi catatan, dan mengubah
status. 7. Nasabah dapat melihat status terbaru. 8. Admin dapat
memasukkan hasil taksiran dan penawaran. 9. Riwayat status tercatat. 10.
Aplikasi menampilkan loading, error, dan empty state dengan benar.

## 14. Di Luar Ruang Lingkup MVP

-   Penilaian harga otomatis berbasis AI.
-   Integrasi payment gateway sungguhan.
-   Integrasi tanda tangan elektronik.
-   Integrasi layanan pemerintah atau lembaga keuangan.
-   Pencairan dana sungguhan.
-   Pelacakan kurir atau penjemputan barang.
-   Keputusan kredit otomatis.

Fitur tersebut dapat menjadi pengembangan lanjutan setelah kebutuhan
legal, operasional, dan integrasi pihak ketiga jelas.

## 15. Asumsi dan Catatan

-   Proyek ini merupakan prototipe akademik.
-   Nama, logo, warna, ilustrasi, dan copywriting Gadaikan dibuat
    orisinal.
-   Alur layanan terinspirasi dari aplikasi referensi, bukan salinan
    aset/kode.
-   Tarif, nilai taksiran, dan pembayaran pada mode demo harus ditandai
    sebagai simulasi.
-   Jangan menggunakan data identitas asli untuk demo; gunakan data
    dummy.
