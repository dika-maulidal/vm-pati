#!/bin/bash

figlet "$(whoami)"

while true; do
    echo "=============================="
    echo "         MENU UTAMA"
    echo "=============================="
    echo "1. TAMPILKAN KEHADIRAN SAAT INI"
    echo "2. TAMPILKAN DAFTAR DIREKTORI INI"
    echo "3. INFORMASI JARINGAN"
    echo "4. TAMPILKAN DETAIL OS"
    echo "5. TAMPILKAN WAKTU INSTALL PERTAMA OS"
    echo "6. INFORMASI USER"
    echo "7. KELUAR"
    echo "=============================="

    read -p "PILIH OPSI [1-7]: " pilihan

    case $pilihan in
        1)
            echo -e "\n[ Kehadiran Saat Ini ]"
            uptime
            ;;
        2)
            echo -e "\n[ Daftar Direktori Sekarang ]"
            ls -l
            ;;
        3)
            echo -e "\n[ Informasi Jaringan Lokal ]"
            ip addr

            echo -e "\n[ Informasi Geolokasi IP Publik ]"
            if command -v curl &> /dev/null; then
                info=$(curl -s ipinfo.io)
                ip=$(echo "$info" | grep '"ip"' | cut -d '"' -f 4)
                city=$(echo "$info" | grep '"city"' | cut -d '"' -f 4)
                region=$(echo "$info" | grep '"region"' | cut -d '"' -f 4)
                country=$(echo "$info" | grep '"country"' | cut -d '"' -f 4)
                org=$(echo "$info" | grep '"org"' | cut -d '"' -f 4)
                loc=$(echo "$info" | grep '"loc"' | cut -d '"' -f 4)
                timezone=$(echo "$info" | grep '"timezone"' | cut -d '"' -f 4)
                postal=$(echo "$info" | grep '"postal"' | cut -d '"' -f 4)

                echo "IP Publik : $ip"
                echo "Kota      : $city"
                echo "Wilayah   : $region"
                echo "Negara    : $country"
                echo "Kode Pos  : $postal"
                echo "Zona Waktu: $timezone"
                echo "ISP       : $org"
                echo "Lokasi    : $loc"
            else
                echo "curl tidak ditemukan. Silakan install dengan: sudo apt install curl"
            fi
            ;;
        4)
            echo -e "\n[ Detail Sistem Operasi ]"
            lsb_release -a
            uname -a
            ;;
        5)
            echo -e "\n[ Perkiraan Waktu Install Pertama OS ]"
            install_time=$(stat -c %w /)
            if [[ "$install_time" == "-" ]]; then
                echo "Informasi waktu tidak tersedia dengan stat -c %w."
                echo "Alternatif: lihat log /var/log/installer atau file system lainnya."
            else
                echo "Pertama kali diinstall: $install_time"
            fi
            ;;
        6)
            echo -e "\n[ Informasi User ]"
            if command -v finger &> /dev/null; then
                finger $(whoami)
            else
                echo "Perintah finger tidak ditemukan. Silakan install dengan:"
                echo "sudo apt install finger"
            fi
            ;;
        7)
            read -p "Apakah kamu yakin ingin keluar? (y/n): " konfirmasi
            if [[ "$konfirmasi" =~ ^[Yy]$ ]]; then
                hour=$(date +%H)
                if (( hour < 12 )); then
                    greeting="Selamat Pagi!"
                elif (( hour < 18 )); then
                    greeting="Selamat Siang!"
                else
                    greeting="Selamat Malam!"
                fi
                echo -e "\n$greeting Terima kasih telah menggunakan MENU SUGAR."
                break
            else
                echo "Kembali ke menu utama..."
            fi
            ;;
        *)
            echo "Opsi tidak valid. Silakan pilih antara 1-7."
            ;;
    esac

    echo -e "\nTekan Enter untuk kembali ke menu..."
    read
    clear
    figlet "$(whoami)"
done
