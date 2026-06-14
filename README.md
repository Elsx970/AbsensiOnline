# 🏫 Sistem Presensi Geolocation Mobile & Web Admin

Sistem Presensi Mahasiswa berbasis **Flutter** (Aplikasi Mobile) dan **PHP Native + MySQL** (Backend Web Admin). Sistem ini dirancang untuk mendigitalisasi proses kehadiran mahasiswa dengan menggunakan teknologi **Validasi GPS (Haversine Formula)**, sehingga mahasiswa hanya bisa melakukan presensi jika mereka berada pada radius kelas yang telah ditentukan oleh admin.

Sistem ini telah diperbarui secara ekstensif untuk mencapai stabilitas produksi dan *User Experience* (UX) yang sangat baik.

---

## ✨ Fitur-Fitur Utama (Modernized)

### 📱 Aplikasi Mobile (Flutter)
- **Validasi Jarak Real-Time (GPS):** Menggunakan sensor lokasi *smartphone* dipadukan dengan formula Haversine untuk menjamin mahasiswa wajib berada di radius ruangan (misal: 50 Meter).
- **Proteksi Jam Kelas Berlapis:** Dilengkapi perlindungan Ganda (Frontend & Backend). Aplikasi otomatis menolak presensi apabila diakses di luar jadwal kelas (`jam_selesai`) atau di luar tanggal pertemuan.
- **Pull-to-Refresh:** Pembaruan data *real-time*. Semua halaman (Beranda, Jadwal, Riwayat, Profil) mendukung mekanisme usap ke bawah untuk menyegarkan data.
- **Filter Jadwal Dinamis:** Mahasiswa dapat melihat daftar mata kuliah berdasarkan Hari (Senin-Minggu) melalui antarmuka *chip-button* yang rapi.
- **Desain UI/UX Modern:** Tidak ada gambar *fingerprint* palsu/membingungkan, antarmuka bersih dan langsung ke poin utama menggunakan komponen *cards* dan *bottom sheet*.

### 💻 Web Admin & Backend (PHP MySQL)
- **Smart Dashboard & Live Search:** Manajemen data yang sangat cepat. Admin dapat mencari kelas dan riwayat mahasiswa tanpa *reload* halaman berkat fitur *AJAX Live Search*.
- **Otomatisasi Zona Waktu (WIB):** Seluruh *log* waktu presensi yang direkam di server (`jam_masuk`, `jam_pulang`) telah secara konsisten di-sinkronisasi ke Waktu Indonesia Barat (WIB).
- **Security Enhancements:** Menghindari *Directory Listing* terbuka melalui konfigurasi skrip `index.php` dan `.htaccess`. 
- **Pertemuan & Sesi Spesifik:** Pembuatan sesi absensi mendukung pelacakan hingga level "Pertemuan ke-X".

---

## 🚀 Panduan Deployment Server

Pilih salah satu metode yang sesuai dengan OS Server VPS Anda.

### Opsi A: Menggunakan Linux VPS (Ubuntu + Apache/Nginx) - *Direkomendasikan*
Metode ini adalah metode yang saat ini aktif digunakan untuk *Production* pada VPS IP `165.22.241.192`.

1. **Upload File Backend:**
   - Jadikan zip seluruh isi dari folder `absensi_backend`.
   - Upload zip tersebut ke direktori publik VPS, misal `/var/www/html/`.
   - Ekstrak (unzip) file tersebut ke folder `/var/www/html/absensi/`.

2. **Konfigurasi Database MySQL/MariaDB:**
   - Login MySQL via SSH: `mysql -u root -p`
   - Buat database: `CREATE DATABASE absensi_db;`
   - Import data: `mysql -u root -p absensi_db < /var/www/html/absensi/database.sql`

3. **Atur Permissions (Sangat Penting):**
   - Agar *Flutter* bisa mengunggah foto *selfie* mahasiswa ke server, jalankan:
   ```bash
   cd /var/www/html/absensi/
   mkdir -p uploads/absensi
   sudo chmod -R 777 uploads/
   ```

4. **Penyesuaian Kredensial Database:**
   Edit file `api/koneksi.php` dan `admin/includes/db.php`:
   ```php
   $host = "localhost"; 
   $user = "root"; // Atau user lain seperti absensi_user
   $pass = "password_anda_di_sini"; 
   $db   = "absensi_db"; 
   ```

### Opsi B: Menggunakan Windows RDP (XAMPP / Laragon)
1. Login ke RDP, instal **XAMPP**, dan jalankan Apache + MySQL.
2. Letakkan seluruh isi folder `absensi_backend` ke `C:\xampp\htdocs\absensi`.
3. Buka `http://localhost/phpmyadmin` dan lakukan *import* file `database.sql`.
4. Sesuaikan password koneksi database (umumnya `$pass = "";` di XAMPP).
5. **Penting:** Buka Port 80 di **Windows Defender Firewall** (Inbound Rules) agar *Flutter* dapat menembak API tersebut dari luar server.

---

## 🔌 Menyambungkan Flutter Mobile ke API

Saat ini, aplikasi Flutter Anda dikonfigurasi untuk terhubung ke IP Publik VPS `165.22.241.192`. Jika Anda melakukan migrasi server di kemudian hari:

1. Buka file di proyek Flutter Anda: `lib/utils/constants.dart`
2. Ubah atribut `baseUrl` ke IP/Domain terbaru:
   ```dart
   class Constants {
     // Pastikan format folder benar sesuai struktur htdocs/var/www
     static const String baseUrl = "http://165.22.241.192/absensi/api"; 
   }
   ```

## 🛠️ Build APK / Proses Rilis
Setelah semuanya terhubung dengan baik, kompilasi kode Flutter menjadi `.apk` Android dengan perintah berikut di Terminal *root folder* proyek Flutter:

```bash
flutter build apk --release
```
Lokasi *file* jadi APK: `build/app/outputs/flutter-apk/app-release.apk`
Kirimkan *file* ini ke Mahasiswa Anda untuk langsung di-instal!

---
*Dibangun untuk modernisasi administrasi perkuliahan Universitas.*
