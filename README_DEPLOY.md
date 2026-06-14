# Panduan Deployment: Sistem Absensi (Flutter + PHP Native) ke VPS

Dokumen ini berisi langkah-langkah lengkap untuk mempublikasikan (deploy) Backend & Web Admin ke server VPS (Ubuntu/Apache/Nginx) dan menyambungkan aplikasi mobile (Flutter) ke server VPS tersebut agar bisa online.

---

## TAHAP 1: Deployment Backend & Web Admin ke VPS (Ubuntu)

Saat ini, sistem telah di-deploy secara aktif di VPS **165.22.241.192**. Ikuti langkah berikut jika ingin melakukan deployment ulang atau memindahkan server.

### 1. Upload File Backend ke VPS
1. Jadikan zip seluruh isi dari folder `absensi_backend` di komputer Anda.
2. Upload zip tersebut ke direktori publik VPS Anda. Lokasi standar untuk web server Apache adalah `/var/www/html/`.
3. Ekstrak (unzip) file tersebut dan pastikan folder bernama `/var/www/html/absensi/` (bukan `absensi_backend`).

### 2. Persiapkan Database MySQL/MariaDB
1. Login ke MySQL melalui console terminal VPS (SSH): `mysql -u root -p`
2. Buat database baru: `CREATE DATABASE absensi_db;`
3. Lakukan **Import** menggunakan file `database.sql` yang ada di dalam folder `absensi_backend`:
   ```bash
   mysql -u root -p absensi_db < /var/www/html/absensi/database.sql
   ```

### 3. Konfigurasi Koneksi Database (PENTING)
Ubah file konfigurasi database PHP agar dapat mengakses database MariaDB/MySQL VPS Anda. **Ada dua file** yang harus diubah:
- `/var/www/html/absensi/api/koneksi.php`
- `/var/www/html/absensi/admin/includes/db.php`

Pastikan variabel `$host`, `$user`, `$pass`, dan `$db` diisi sesuai dengan kredensial server. (Contoh untuk server ini, user `root` dengan password `anime008@Asd`).

### 4. Konfigurasi Keamanan (Security)
Untuk mencegah eksploitasi dan *Directory Listing* yang terbuka di Apache:
1. Pastikan terdapat file `/var/www/html/absensi/index.php` yang berisi script redirect ke `admin/index.php`.
2. Pastikan terdapat file `/var/www/html/absensi/.htaccess` yang berisi aturan `Options -Indexes` untuk memblokir akses *listing directory* di folder seperti `api/` dan `uploads/`.

### 5. Atur Izin Folder Upload (Permissions)
Agar fitur absen *selfie* berfungsi, skrip PHP di VPS butuh hak akses (write) untuk menyimpan gambar. Jalankan perintah terminal (SSH) berikut:
```bash
# Buat foldernya jika belum ada
mkdir -p /var/www/html/absensi/uploads/absensi

# Berikan hak akses penuh agar gambar bisa disimpan
sudo chmod -R 777 /var/www/html/absensi/uploads/
```

---

## TAHAP 2: Menyambungkan Aplikasi Flutter ke VPS

Aplikasi Flutter harus mengarah ke URL Publik VPS agar API dapat berinteraksi secara *online*.

1. Buka kembali proyek Flutter Anda di VS Code.
2. Buka file: `lib/utils/constants.dart`
3. Pastikan alamat URL diatur sesuai dengan IP Publik VPS.

**Contoh:**
```dart
class Constants {
  // Pastikan akhiran /api tetap ditulis dan folder di server adalah absensi
  static const String baseUrl = "http://165.22.241.192/absensi/api"; 
}
```

---

## TAHAP 3: Build & Rilis Aplikasi Android (APK)

Langkah terakhir, karena kode sudah tersambung ke VPS yang *Online*, Anda perlu meng-compile (Build) Flutternya menjadi file instalasi Android (`.apk`).

1. Buka **Terminal** di dalam VS Code (pastikan direktori aktif berada di folder Flutter `mc code/absensi/`).
2. Jalankan perintah rilis berikut:
```bash
flutter build apk --release
```
3. Tunggu proses kompilasinya berjalan (bisa memakan waktu 1-3 menit).
4. Jika tulisan *build success* muncul, file APK siap pakai Anda akan otomatis tersimpan di lokasi:
> `build/app/outputs/flutter-apk/app-release.apk`
5. Kirimkan file `app-release.apk` tersebut ke HP Anda, ke mahasiswa, atau bagikan via Google Drive untuk langsung di-instal!

Selamat, sistem absensi geofencing berbasis lokasi Anda sudah sepenuhnya *online* dan aman! 🚀

---

## TAHAP 4: Akses Web Admin

Setelah berhasil *deploy*, Anda dapat mengelola data absensi melalui *Dashboard* Web Admin. 
Akses langsung melalui IP Server (karena sudah dikonfigurasi *redirect* ke halaman admin):

- **URL:** `http://165.22.241.192` (atau `http://165.22.241.192/absensi/admin/`)
- **Email:** `admin@admin.com`
- **Password:** `admin123`

*(Sangat disarankan untuk segera mengubah kredensial ini atau menambahkan pengguna admin baru melalui dashboard demi keamanan).*
