
## AI Foundation UI (Oktober 2026)

Entry point `lib/main.dart` kini membuka `lib/ai_foundation_home.dart`. Tema: header coral merah, latar gradasi abu-putih lembut, kartu putih translucent, navigasi AI Pusat di tengah. Modul navigasi berada di `lib/foundation_pages.dart`: AI Pusat, Perusahaan, Monitor, Budgeting, Approval, Tools & Integrasi, Laporan, dan Pengaturan. Semua statistik, perusahaan, anggaran, dan aktivitas adalah DATA DEMO. Integrasi API, autentikasi, persistence, approval sungguhan, dan pengelolaan kredensial aman belum diimplementasikan. Jangan masukkan API key sungguhan ke source Flutter.

Status validasi: perubahan UI telah di-commit, tetapi belum dinyatakan lulus `flutter analyze`, widget tests, atau build APK pada commit ini. README lama di bawah mendeskripsikan prototipe EWASHO yang dipakai sebagai basis historis.

---
# EWASHO

Prototipe beranda kasir laundry menggunakan Flutter. Efek kaca hanya pada slider; kartu omzet, grid menu dan navigasi memakai warna solid. Tanpa dependensi tambahan.

## Menjalankan

Pasang Flutter stable yang mendukung Dart 3.4 atau lebih baru, lalu:

```sh
git clone https://github.com/rajabadutiklan-lab/Ai-Fondation-Aggentic.git
cd Ai-Fondation-Aggentic
flutter create --project-name ewasho --platforms android,web .
flutter pub get
flutter run
```

Folder platform belum disertakan; perintah `flutter create` menghasilkan scaffolding platform lokal. Pertahankan `lib/main.dart` dari repository bila alat menawarkan overwrite. Hapus test bawaan counter di `test/widget_test.dart` bila dihasilkan, karena aplikasi ini tidak memakai counter.

## Status

- Beranda, slider manual 3 halaman, pilihan outlet, navigasi placeholder.
- Data omzet contoh; belum backend, kamera, transaksi atau laporan nyata.
- Logo dan ilustrasi berupa widget sederhana, belum aset asli referensi.
- Satu BackdropFilter terpotong pada batas slider, sigma 5; ubah `enableGlass` ke false untuk menonaktifkan blur.
- Pemeriksaan analyzer dan widget test beranda, geser slider, serta navigasi sudah lulus di GitHub Actions pada Flutter 3.24.5. Belum diuji pada HP fisik; performa perangkat belum diukur.

Basis EWASHO disalin ke AI Foundation sesuai instruksi pemilik. File implementasi AI Foundation lama digantikan; kode aplikasi EWASHO dipertahankan. Sumber: rajabadutiklan-lab/Ewasho-gpt, commit 9d0037dc84f52acb21546363c20abc4f4104afd3.

## APK uji Android

Workflow `Build Android APK` menghasilkan APK release dengan debug signing untuk mencoba prototipe, bukan untuk Play Store. APK tersedia di halaman [Releases](https://github.com/rajabadutiklan-lab/Ai-Fondation-Aggentic/releases) setelah build berhasil. Pilih `EWASHO-preview.apk` pada Assets. Repository ini public; APK dapat diunduh dari halaman Releases.

Setiap build baru memakai debug keystore runner; jika Android menolak pembaruan karena tanda tangan berbeda, hapus prototipe lama terlebih dahulu. Aplikasi ini hanya berisi data contoh.

## Halaman Laporan

Menu Laporan membuka tampilan native Flutter mengikuti referensi merah/pink: filter periode, pemilih tanggal/outlet, grafik yang dapat diketuk, layanan terlaris, diagram pembayaran dan rekap. Angka masih simulasi untuk prototipe. Efek kaca hanya di slider beranda. Tautan unduh preview-3 selalu diperbarui setelah build baru berhasil; release bernomor lain menyimpan sumber dan APK tiap build.
