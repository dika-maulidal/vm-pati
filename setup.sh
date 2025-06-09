#!/bin/bash

# Jalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "Silakan jalankan sebagai root"
  exit 1
fi

# --- SETUP USER ---
ADMIN="admin1"
DEV1="anggota1"
DEV2="anggota2"
BACA_ONLY="anggota3"
NONLOGIN="anggota4"

# Buat grup developer jika belum ada
groupadd -f developer

# Buat user admin1 (grup sudo)
useradd -m -s /bin/bash "$ADMIN"
echo "$ADMIN:admin123" | chpasswd
usermod -aG sudo "$ADMIN"

# Buat user developer
for user in "$DEV1" "$DEV2"; do
  useradd -m -s /bin/bash -G developer "$user"
  echo "$user:dev12345" | chpasswd
done

# Buat user hanya baca file (bukan developer)
useradd -m -s /bin/bash "$BACA_ONLY"
echo "$BACA_ONLY:baca12345" | chpasswd

# Buat user nonaktif login
useradd -m -s /usr/sbin/nologin "$NONLOGIN"
echo "$NONLOGIN:nonaktif123" | chpasswd

# Atur kebijakan login: anggota1 ubah password tiap 5 hari
chage -M 5 "$DEV1"

# Install pam_pwquality untuk enforce password policy
apt-get install -y libpam-pwquality

# Pastikan baris pam_pwquality ada dan sesuai
if ! grep -q "pam_pwquality.so" /etc/pam.d/common-password; then
  sed -i '/pam_unix.so/ a password requisite pam_pwquality.so retry=3 minlen=8 reject_username' /etc/pam.d/common-password
fi

# --- SETUP FOLDER SHARING ---
mkdir -p /srv/projects
chown root:developer /srv/projects
chmod 770 /srv/projects

# Set default ACL supaya grup developer dapat akses penuh ke semua file baru
setfacl -d -m g:developer:rwx /srv/projects

# --- BUAT FILE DAN FOLDER LEBIH KOMPLEKS UNTUK TESTING ---
echo "Isi untuk dev1" > /srv/projects/dev1.txt
echo "Isi untuk dev2" > /srv/projects/dev2.txt
echo "Isi umum developer" > /srv/projects/umum.txt
echo "Boleh dibaca anggota3" > /srv/projects/boleh-baca.txt
echo "Rahasia internal 1" > /srv/projects/secret1.txt
echo "Rahasia internal 2" > /srv/projects/secret2.txt

# Subdirektori dan isinya
mkdir -p /srv/projects/subdir1
mkdir -p /srv/projects/subdir2
echo "File dalam subdir1 untuk developer" > /srv/projects/subdir1/subfile1.txt
echo "File dalam subdir2 untuk developer" > /srv/projects/subdir2/subfile2.txt
echo "File publik khusus anggota3" > /srv/projects/subdir2/boleh-baca-2.txt

# Set kepemilikan dan hak akses awal
chown -R root:developer /srv/projects
chmod -R 770 /srv/projects

# ACL: Hapus semua hak akses anggota3
setfacl -R -m u:$BACA_ONLY:--- /srv/projects

# Beri akses baca hanya ke file tertentu untuk anggota3
setfacl -m u:$BACA_ONLY:r-- /srv/projects/boleh-baca.txt
setfacl -m u:$BACA_ONLY:r-- /srv/projects/subdir2/boleh-baca-2.txt

# Beri izin eksekusi ke anggota3 untuk direktori agar bisa akses file
setfacl -m u:$BACA_ONLY:--x /srv/projects
setfacl -m u:$BACA_ONLY:--x /srv/projects/subdir2

# Set default ACL untuk direktori baru supaya anggota3 bisa eksekusi folder
setfacl -d -m u:$BACA_ONLY:--x /srv/projects
setfacl -d -m u:$BACA_ONLY:--x /srv/projects/subdir2

# --- TAMBAH FOLDER KHUSUS ANGGOTA3 dengan akses rwx penuh ---
mkdir -p /srv/projects/public_for_anggota3
chown root:developer /srv/projects/public_for_anggota3
chmod 770 /srv/projects/public_for_anggota3

# Isi contoh file di folder baru ini
echo "Ini adalah file publik milik anggota3" > /srv/projects/public_for_anggota3/file1.txt
echo "File kedua dengan akses penuh untuk anggota3" > /srv/projects/public_for_anggota3/file2.txt

# Set ACL supaya anggota3 dapat akses rwx penuh di folder ini
setfacl -m u:$BACA_ONLY:rwx /srv/projects/public_for_anggota3
setfacl -d -m u:$BACA_ONLY:rwx /srv/projects/public_for_anggota3

setfacl -R -m u:$BACA_ONLY3:r-- /srv/projects/public_for_anggota3/*

# Output verifikasi
echo
echo "✅ Setup selesai."
echo "Isi folder /srv/projects:"
ls -l /srv/projects
echo
echo "Isi folder khusus anggota3 (/srv/projects/public_for_anggota3):"
ls -l /srv/projects/public_for_anggota3
echo
echo "ACL file boleh-baca.txt:"
getfacl /srv/projects/boleh-baca.txt
echo
echo "ACL file boleh-baca-2.txt di subdir2:"
getfacl /srv/projects/subdir2/boleh-baca-2.txt
echo
echo "ACL folder public_for_anggota3:"
getfacl /srv/projects/public_for_anggota3
