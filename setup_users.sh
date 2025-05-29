#!/bin/bash

# Periksa apakah dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Jalankan skrip ini sebagai root (gunakan sudo)."
    exit 1
fi

# Tambah grup developer dan guest
groupadd -f developer
groupadd -f guest
echo "[✓] Grup developer dan guest dibuat."

# Tambah user admin ke grup sudo
useradd -m -s /bin/bash -G sudo admin
echo "admin:admin123" | chpasswd
echo "[✓] User admin dibuat dan ditambahkan ke grup sudo."

# Tambah user developer1, developer2, developer3 ke grup developer
for i in developer1 developer2 developer3; do
    useradd -m -s /bin/bash -G developer $i
    echo "$i:dev123" | chpasswd
    echo "[✓] User $i dibuat dan ditambahkan ke grup developer."
done

# Tambah user guest1 dan guest2 ke grup guest
for i in guest1 guest2; do
    useradd -m -s /bin/bash -G guest $i
    echo "$i:guest123" | chpasswd
    echo "[✓] User $i dibuat dan ditambahkan ke grup guest."
done

# Tambah user tanpa login (nologinuser)
useradd -M -s /usr/sbin/nologin nologinuser
echo "nologinuser:nologin123" | chpasswd
echo "[✓] User nologinuser dibuat dengan login dinonaktifkan."

# Atur kebijakan password untuk developer1
chage -M 5 developer1  # Password harus diganti setiap 5 hari
echo "[✓] Kebijakan password untuk developer1: ganti setiap 5 hari."

# Atur kebijakan password minimal (8 karakter, kompleksitas)
if ! grep -q "pam_pwquality.so" /etc/pam.d/common-password; then
    echo "password requisite pam_pwquality.so retry=3 minlen=8 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1" >> /etc/pam.d/common-password
    echo "[✓] Kebijakan password minimal diterapkan."
else
    echo "[✓] Kebijakan password minimal sudah ada."
fi

echo "[✓] Semua user dan grup berhasil dibuat dan disetup."