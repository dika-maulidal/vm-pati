#!/bin/bash

# Periksa apakah dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Jalankan skrip ini sebagai root (gunakan sudo)."
    exit 1
fi

# Tentukan file log
LOG_FILE="/var/log/sysmon.log"

# Pastikan direktori log ada
mkdir -p /var/log
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

# Fungsi untuk mendapatkan penggunaan RAM (persentase)
get_ram_usage() {
    free | awk '/Mem:/ {printf "%.2f", ($3/$2)*100}'
}

# Fungsi untuk mendapatkan penggunaan CPU (persentase)
get_cpu_usage() {
    # Gunakan mpstat jika tersedia, jika tidak gunakan top
    if command -v mpstat >/dev/null 2>&1; then
        mpstat 1 1 | awk '/Average:/ {printf "%.2f", 100-$NF}'
    else
        top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}' | head -n 1
    fi
}

# Fungsi untuk mendapatkan penggunaan disk (persentase, root filesystem)
get_disk_usage() {
    df -h / | awk 'NR==2 {print $5}' | tr -d '%'
}

# Dapatkan timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Dapatkan metrik
RAM_USAGE=$(get_ram_usage)
CPU_USAGE=$(get_cpu_usage)
DISK_USAGE=$(get_disk_usage)

# Format pesan log
LOG_MESSAGE="$TIMESTAMP | RAM: ${RAM_USAGE}% | CPU: ${CPU_USAGE}% | Disk: ${DISK_USAGE}%"

# Cek jika CPU > 70%
if (( $(echo "$CPU_USAGE > 70" | bc -l) )); then
    LOG_MESSAGE="$LOG_MESSAGE | WARNING: CPU usage exceeds 70%!"
fi

# Tulis ke file log
echo "$LOG_MESSAGE" >> "$LOG_FILE"

# Tampilkan pesan konfirmasi
echo "[✓] Monitoring dilakukan: $LOG_MESSAGE"