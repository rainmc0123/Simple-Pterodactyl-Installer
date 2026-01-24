# 🚀 Pterodactyl Panel Auto Installer

<p align="center">
  <img src="https://pterodactyl.io/logos/new/pterodactyl_logo.png" alt="Pterodactyl Logo" width="400"/>
</p>

<p align="center">
  <strong>Script Instalasi Otomatis untuk Pterodactyl Panel</strong>
</p>

<p align="center">
  <a href="#fitur">Fitur</a> •
  <a href="#persyaratan">Persyaratan</a> •
  <a href="#instalasi">Instalasi</a> •
  <a href="#pasca-instalasi">Pasca-Instalasi</a> •
  <a href="#troubleshooting">Troubleshooting</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Panel-v1.11.x-blue?style=flat-square" alt="Versi Panel"/>
  <img src="https://img.shields.io/badge/Wings-v1.11.x-blue?style=flat-square" alt="Versi Wings"/>
  <img src="https://img.shields.io/badge/PHP-8.3-purple?style=flat-square" alt="Versi PHP"/>
  <img src="https://img.shields.io/badge/License-MIT-green?style=flat-square" alt="Lisensi"/>
</p>

<p align="center">
  <strong>Dibuat oleh ClouviaID</strong><br>
  © 2026 ClouviaID - All Rights Reserved
</p>

---

## 📋 Ringkasan

Script ini mengotomatisasi instalasi lengkap **Pterodactyl Panel** - panel manajemen game server modern dan open-source. Script ini menangani semua dependensi, konfigurasi, dan layanan yang diperlukan untuk menjalankan Pterodactyl di server Anda.

**Yang akan diinstall:**
- 🌐 Pterodactyl Panel (Versi Terbaru)
- 🦅 Wings Daemon (Versi Terbaru)
- 🐘 PHP 8.3 dengan semua ekstensi yang diperlukan
- 🗄️ MariaDB Database Server
- 🔴 Redis Server (Cache & Queue)
- 🌍 Nginx Web Server
- 🐳 Docker Engine
- 🔒 Sertifikat SSL Let's Encrypt
- ⚡ Queue Worker & Cron Jobs

---

## ✨ Fitur

| Fitur | Deskripsi |
|-------|-----------|
| 🤖 **Otomatis Sepenuhnya** | Hanya perlu memasukkan nama domain - sisanya dikonfigurasi otomatis |
| 🔐 **Aman Secara Default** | Menghasilkan password kuat untuk database dan akun admin |
| 🔒 **SSL Siap Pakai** | Otomatis mendapatkan dan mengkonfigurasi SSL Let's Encrypt |
| 📦 **Stack Lengkap** | Menginstall semua dependensi termasuk Docker dan Wings |
| 🔄 **Setup Layanan** | Mengkonfigurasi layanan systemd dan cron jobs |
| 📊 **Tampilan Progress** | Pesan status yang jelas selama instalasi |
| 📝 **Penyimpanan Kredensial** | Menyimpan semua kredensial yang dihasilkan dengan aman |
| 🛡️ **Penanganan Error** | Memvalidasi persyaratan sistem sebelum instalasi |

---

## 💻 Persyaratan

### Sistem Operasi yang Didukung

| OS | Versi | Status |
|----|-------|--------|
| Ubuntu | 20.04 LTS | ✅ Didukung |
| Ubuntu | 22.04 LTS | ✅ Didukung |
| Ubuntu | 24.04 LTS | ✅ Didukung |
| Debian | 11 (Bullseye) | ✅ Didukung |
| Debian | 12 (Bookworm) | ✅ Didukung |
| Debian | 13 (Trixie) | ✅ Didukung |

### Spesifikasi Hardware Minimum

| Resource | Minimum | Rekomendasi |
|----------|---------|-------------|
| CPU | 1 Core | 2+ Cores |
| RAM | 2 GB | 4+ GB |
| Storage | 10 GB | 20+ GB SSD |
| Network | 100 Mbps | 1 Gbps |

### Persyaratan Jaringan

| Port | Protokol | Fungsi |
|------|----------|--------|
| 22 | TCP | Akses SSH |
| 80 | TCP | HTTP (Redirect ke HTTPS) |
| 443 | TCP | HTTPS (Panel) |
| 8080 | TCP | Wings HTTP |
| 2022 | TCP | Wings SFTP |

### Checklist Pra-Instalasi

- [ ] VPS atau Server Dedicated baru (virtualisasi KVM/VMware)
- [ ] Akses root atau hak sudo
- [ ] Domain sudah diarahkan ke IP server (A record)
- [ ] Port 80 dan 443 tersedia (tidak diblokir firewall)
- [ ] Koneksi internet stabil

> ⚠️ **Penting:** Container OpenVZ dan LXC TIDAK didukung karena keterbatasan Docker.

---

## 🚀 Instalasi

### Instalasi Cepat (Satu Perintah)

```bash
bash <(curl -s https://raw.githubusercontent.com/rainmc0123/Simple-Pterodactyl-Installer/main/install.sh)
```

### Instalasi Manual

1. **Download installer:**
   ```bash
   curl -Lo install.sh https://raw.githubusercontent.com/rainmc0123/Simple-Pterodactyl-Installer/main/install.sh
   ```

2. **Buat executable:**
   ```bash
   chmod +x install.sh
   ```

3. **Jalankan sebagai root:**
   ```bash
   sudo ./install.sh
   ```

### Proses Instalasi

Script akan:

1. ✅ Memeriksa apakah berjalan sebagai root
2. ✅ Memverifikasi kompatibilitas sistem operasi
3. ✅ Memeriksa tipe virtualisasi
4. ✅ Memvalidasi sumber daya sistem
5. ✅ Meminta domain panel Anda
6. ✅ Memperbarui paket sistem
7. ✅ Menginstall semua dependensi
8. ✅ Mengkonfigurasi database MariaDB
9. ✅ Mendownload dan mengkonfigurasi Panel
10. ✅ Menyiapkan Nginx dengan SSL
11. ✅ Mengkonfigurasi queue workers
12. ✅ Menginstall Wings daemon
13. ✅ Mengkonfigurasi aturan firewall

**Estimasi Waktu:** 10-15 menit tergantung kecepatan server

---

## 📦 Pasca-Instalasi

### Akses Panel Anda

Setelah instalasi selesai, Anda akan menerima:

- **URL Panel:** `https://domain-anda.com`
- **Email Admin:** `admin@domain-anda.com`
- **Password Admin:** (dihasilkan otomatis)

Semua kredensial disimpan di: `/root/pterodactyl-credentials.txt`

### Konfigurasi Wings

1. **Login ke Panel** sebagai admin

2. **Buat Lokasi:**
   - Navigasi ke Admin → Locations
   - Klik "Create New"
   - Masukkan nama singkat (contoh: "ID-Jakarta")

3. **Buat Node:**
   - Navigasi ke Admin → Nodes
   - Klik "Create New"
   - Isi detail node (gunakan IP publik server Anda)
   - Atur batas memori dan disk

4. **Dapatkan Konfigurasi Wings:**
   - Klik pada Node yang dibuat
   - Pergi ke tab "Configuration"
   - Klik "Generate Token"
   - Salin perintah auto-deployment

5. **Deploy Konfigurasi Wings:**
   ```bash
   nano /etc/pterodactyl/config.yml
   ```

6. **Jalankan Wings:**
   ```bash
   sudo systemctl start wings
   ```

7. **Verifikasi Wings Berjalan:**
   ```bash
   sudo systemctl status wings
   ```

### Buat Game Server

1. **Buat Allocations:**
   - Pergi ke Admin → Nodes → Node Anda → Allocation
   - Tambahkan alamat IP dan rentang port

2. **Buat Server:**
   - Pergi ke Admin → Servers → Create New
   - Pilih user, node, dan allocation
   - Pilih Nest (contoh: Minecraft) dan Egg
   - Konfigurasi sumber daya server

---

## 🔧 Perintah Manajemen

### Manajemen Panel

```bash
systemctl restart nginx php8.3-fpm pteroq

tail -f /var/log/nginx/pterodactyl.app-error.log

cd /var/www/pterodactyl && php artisan cache:clear

cd /var/www/pterodactyl
php artisan down
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz --overwrite
chmod -R 755 storage/* bootstrap/cache/
composer install --no-dev --optimize-autoloader
php artisan migrate --seed --force
php artisan view:clear
php artisan config:clear
chown -R www-data:www-data /var/www/pterodactyl/*
php artisan queue:restart
php artisan up
```

### Manajemen Wings

```bash
systemctl start wings

systemctl stop wings

systemctl restart wings

journalctl -u wings -f

systemctl status wings
```

### Manajemen Database

```bash
mariadb -u root -p

mysqldump -u root -p panel > panel_backup.sql

mysql -u root -p panel < panel_backup.sql
```

---

## 🔒 Rekomendasi Keamanan

### Setelah Instalasi

1. **Simpan Kredensial dengan Aman:**
   ```bash
   cat /root/pterodactyl-credentials.txt
   rm /root/pterodactyl-credentials.txt
   ```

2. **Nonaktifkan Root SSH (Opsional):**
   ```bash
   adduser admin
   usermod -aG sudo admin
   
   sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
   systemctl restart sshd
   ```

3. **Aktifkan 2FA:**
   - Login ke Panel
   - Pergi ke Pengaturan Akun
   - Aktifkan Two-Factor Authentication

4. **Update Berkala:**
   ```bash
   apt update && apt upgrade -y
   ```

5. **Backup Rutin:**
   ```bash
   tar -czvf pterodactyl-backup.tar.gz /var/www/pterodactyl
   
   mysqldump -u root -p panel > panel_backup.sql
   
   cp /etc/pterodactyl/config.yml /root/wings-config.yml.backup
   ```

---

## ❓ Troubleshooting

### Masalah Umum

#### 1. Sertifikat SSL Gagal

```bash
dig +short domain-anda.com

certbot --nginx -d domain-anda.com

nginx -t
```

#### 2. Panel Menampilkan Error 500

```bash
tail -f /var/log/nginx/pterodactyl.app-error.log

chown -R www-data:www-data /var/www/pterodactyl/*

cd /var/www/pterodactyl
php artisan config:clear
php artisan cache:clear
php artisan view:clear
```

#### 3. Queue Worker Tidak Berjalan

```bash
systemctl status pteroq

journalctl -u pteroq -f

systemctl restart pteroq
```

#### 4. Wings Tidak Mau Start

```bash
systemctl status docker

wings --debug

cat /etc/pterodactyl/config.yml
```

#### 5. Koneksi Database Gagal

```bash
systemctl status mariadb

mysql -u pterodactyl -p -h 127.0.0.1 panel

grep DB_ /var/www/pterodactyl/.env
```

---

## 📞 Bantuan & Dukungan

### Hubungi Kami

| Platform | Link |
|----------|------|
| 📧 **Email Support** | s.rainstoreid@gmail.com |
| 💬 **Grup WhatsApp** | [Gabung Grup](https://chat.whatsapp.com/I9TD1kQM9kKAeFVzzChysJ) |
| 📖 **Dokumentasi Resmi** | [pterodactyl.io](https://pterodactyl.io/) |
| 📝 **Log Instalasi** | `/var/log/pterodactyl-installer.log` |

### Sebelum Bertanya

1. Pastikan sudah membaca dokumentasi ini dengan lengkap
2. Cek file log instalasi untuk melihat error
3. Pastikan server memenuhi persyaratan minimum
4. Siapkan informasi sistem (OS, versi, error message)

---

## 📄 Lisensi

Proyek ini dilisensikan di bawah Lisensi MIT - lihat file [LICENSE](LICENSE) untuk detail.

---

## ⚠️ Disclaimer

- Ini adalah script instalasi **tidak resmi** dan tidak berafiliasi dengan Pterodactyl Software.
- Selalu backup data Anda sebelum menjalankan script instalasi.
- Script ini memodifikasi konfigurasi sistem; penggunaan pada instalasi fresh direkomendasikan.
- Kami tidak bertanggung jawab atas kehilangan data atau masalah sistem akibat penggunaan script ini.
- Untuk lingkungan produksi, pertimbangkan untuk mengikuti [panduan instalasi resmi](https://pterodactyl.io/panel/1.0/getting_started.html).

---

## 🙏 Kredit

- [Pterodactyl](https://pterodactyl.io/) - Panel manajemen game server open-source yang luar biasa
- [Let's Encrypt](https://letsencrypt.org/) - Sertifikat SSL gratis
- [Docker](https://www.docker.com/) - Platform container
- Semua kontributor dan komunitas open-source

---

<p align="center">
  <strong>Dibuat dengan ❤️ oleh ClouviaID</strong>
</p>

<p align="center">
  © 2026 ClouviaID - All Rights Reserved
</p>

<p align="center">
  ⭐ Beri bintang repo ini jika bermanfaat!
</p>
