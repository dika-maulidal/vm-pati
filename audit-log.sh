#!/bin/bash

# Periksa apakah dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
    echo "Jalankan skrip ini sebagai root (gunakan sudo)."
    exit 1
fi

# Tentukan file output
OUTPUT_FILE="/var/log/audit_summary.log"

# Buat atau kosongkan file audit_summary.log
: > "$OUTPUT_FILE"

# Tambahkan header ke file output
echo "=== Audit Summary - $(date '+%Y-%m-%d %H:%M:%S') ===" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 1. Simpan log login terakhir (menggunakan last)
echo "=== Last Login Information ===" >> "$OUTPUT_FILE"
if command -v last >/dev/null 2>&1; then
    last -w >> "$OUTPUT_FILE" 2>/dev/null
else
    echo "Perintah last tidak tersedia di sistem ini." >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# 2. Ambil log gagal login dari /var/log/auth.log
echo "=== Failed Login Attempts ===" >> "$OUTPUT_FILE"
if [ -f /var/log/auth.log ]; then
    grep -E "Failed password|authentication failure|FAILED SU" /var/log/auth.log >> "$OUTPUT_FILE" 2>/dev/null || echo "Tidak ada log gagal login ditemukan di /var/log/auth.log." >> "$OUTPUT_FILE"
else
    echo "File /var/log/auth.log tidak ditemukan. Pastikan rsyslog diinstal dan aktif." >> "$OUTPUT_FILE"
fi
echo "" >> "$OUTPUT_FILE"

# 3. Pastikan file memiliki izin yang aman
chown root:root "$OUTPUT_FILE"
chmod 600 "$OUTPUT_FILE"

echo "[✓] Audit selesai. Rekap disimpan di $OUTPUT_FILE"