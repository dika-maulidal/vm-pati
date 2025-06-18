#!/bin/bash

# ==========================================================
#  Menu Informasi Sistem Linux – versi estetika biru & cyan
#  Dibuat ulang oleh ChatGPT (18 Juni 2025)
# ==========================================================

# ------ Definisi Warna ANSI ------
NC='\033[0m'          # Reset / No Color
BOLD='\033[1m'
BLUE='\033[0;34m'
LBLUE='\033[1;34m'
CYAN='\033[0;36m'
LCYAN='\033[1;36m'

# ------ Fungsi Header & Menu ------
header() {
    clear
    ascii_art=(
"███╗   ███╗███████╗███╗   ██╗██╗   ██╗    ██████╗  █████╗ ███████╗██╗  ██╗"
"████╗ ████║██╔════╝████╗  ██║██║   ██║    ██╔══██╗██╔══██╗██╔════╝██║  ██║"
"██╔████╔██║█████╗  ██╔██╗ ██║██║   ██║    ██████╔╝███████║███████╗███████║"
"██║╚██╔╝██║██╔══╝  ██║╚██╗██║██║   ██║    ██╔══██╗██╔══██║╚════██║██╔══██║"
"██║ ╚═╝ ██║███████╗██║ ╚████║╚██████╔╝    ██████╔╝██║  ██║███████║██║  ██║"
"╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝     ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝"
"                                                                         "
    )

    # Cari panjang maksimal dari baris
    max_len=0
    for line in "${ascii_art[@]}"; do
        [ ${#line} -gt $max_len ] && max_len=${#line}
    done

    # Buat border atas
    echo -e "${BOLD}${LCYAN}╔$(printf '═%.0s' $(seq 1 $((max_len + 2))))╗${NC}"

    # Tampilkan setiap baris dengan border samping
    for line in "${ascii_art[@]}"; do
        padding=$(( (max_len - ${#line}) / 2 ))
        pad_right=$(( max_len - ${#line} - padding ))
        printf "${BOLD}${LCYAN}║${NC} %${padding}s${BOLD}${LBLUE}%s%${pad_right}s ${BOLD}${LCYAN}║${NC}\n" "" "$line" ""
    done

    # Buat border bawah
    echo -e "${BOLD}${LCYAN}╚$(printf '═%.0s' $(seq 1 $((max_len + 2))))╝${NC}"
}



show_menu() {
    echo
    echo -e "${CYAN}1.${NC} ${BOLD}${BLUE}INFORMASI JARINGAN${NC}"
    echo -e "${CYAN}2.${NC} ${BOLD}${BLUE}TAMPILKAN DETAIL OS${NC}"
    echo -e "${CYAN}3.${NC} ${BOLD}${BLUE}INFORMASI USER${NC}"
    echo -e "${CYAN}4.${NC} ${BOLD}${BLUE}KELUAR${NC}"
    echo
}

pause() {
    echo
    echo -ne "${BOLD}${CYAN}Tekan Enter untuk kembali ke menu utama...${NC}"
    read -r
}

# ------ Loop Menu Utama ------
while true; do
    header
    show_menu

    # Prompt pilihan user
    echo -ne "${BOLD}${CYAN}PILIH OPSI [1-4]: ${NC}"
    read -r pilihan

    case $pilihan in
        1)
            echo -e "${BOLD}${LBLUE}\n[ Informasi Jaringan ]${NC}"

            # Local IP, Netmask, Gateway, and DNS
            echo -e "${BOLD}${LCYAN}\n[ Informasi Jaringan Lokal ]${NC}"
            ip addr show | grep inet | grep -v inet6 | grep -v 127.0.0.1 | while read -r line; do
                ip_cidr=$(echo "$line" | awk '{print $2}')       # mis. 192.168.1.5/24
                ip=$(echo "$ip_cidr" | cut -d'/' -f1)            # ambil hanya alamat IP
                netmask=$(echo "$ip_cidr" | cut -d'/' -f2)       # ambil hanya CIDR/netmask
                echo -e "${CYAN}Alamat IP:${NC} $ip"
                echo -e "${CYAN}Netmask  :${NC} /$netmask"
            done

            gateway=$(ip route | grep default | awk '{print $3}')
            echo -e "${CYAN}Gateway  :${NC} $gateway"

            echo -e "${BOLD}${LCYAN}\n[ Server DNS: ]${NC}"
            if [ -f /etc/resolv.conf ]; then
                grep nameserver /etc/resolv.conf | awk '{print "  "$2}' | sed 's/^/    /'
            else
                echo "    File /etc/resolv.conf tidak ditemukan."
            fi
            if command -v nmcli &> /dev/null && systemctl is-active NetworkManager &> /dev/null; then
                nmcli connection show --active | awk 'NR>1 {print $1}' | while read -r conn; do
                    nmcli connection show "$conn" | grep 'ipv4.dns:' | awk '{print "  "$2}' | sed 's/^/    /'
                done
            fi

            # Network Interface Details
            echo -e "${BOLD}${LCYAN}\n[ Detail Antarmuka Jaringan ]${NC}"
            if command -v nmcli &> /dev/null && systemctl is-active NetworkManager &> /dev/null; then
                nmcli device status | awk 'NR==1 {
                    printf "\033[1;37m%-10s %-10s %-25s %-s\033[0m\n", $1, $2, $3, $4
                }
                NR>1 {
                    printf "\033[36m%-10s %-10s %-25s %-s\033[0m\n", $1, $2, $3, $4
                }'
            else
                echo "NetworkManager tidak aktif atau tidak terinstall. Menampilkan info antarmuka dengan 'ip link':"
                ip link show | awk '/^[0-9]+:/ {print "Perangkat: " $2, "Status: " $9}'
            fi

            # Internet Connection Status
            echo -e "${BOLD}${LCYAN}\n[ Status Koneksi Internet ]${NC}"
            if curl -s --head https://www.google.com > /dev/null; then
                echo -e "${CYAN}Koneksi Internet:${NC} Terhubung"
            else
                echo -e "${CYAN}Koneksi Internet:${NC} Tidak Terhubung"
            fi

            # Public IP Geolocation
            echo -e "${BOLD}${LCYAN}\n[ Informasi Geolokasi IP Publik ]${NC}"
            if command -v curl &> /dev/null; then
                info=$(curl -s ipinfo.io)
                ip_pub=$(echo "$info" | grep '"ip"' | cut -d '"' -f 4)
                city=$(echo "$info" | grep '"city"' | cut -d '"' -f 4)
                region=$(echo "$info" | grep '"region"' | cut -d '"' -f 4)
                country=$(echo "$info" | grep '"country"' | cut -d '"' -f 4)
                org=$(echo "$info" | grep '"org"' | cut -d '"' -f 4)
                loc=$(echo "$info" | grep '"loc"' | cut -d '"' -f 4)
                timezone=$(echo "$info" | grep '"timezone"' | cut -d '"' -f 4)
                postal=$(echo "$info" | grep '"postal"' | cut -d '"' -f 4)

                echo -e "${CYAN}IP Publik :${NC} $ip_pub"
                echo -e "${CYAN}Kota      :${NC} $city"
                echo -e "${CYAN}Wilayah   :${NC} $region"
                echo -e "${CYAN}Negara    :${NC} $country"
                echo -e "${CYAN}Kode Pos  :${NC} $postal"
                echo -e "${CYAN}Zona Waktu:${NC} $timezone"
                echo -e "${CYAN}ISP       :${NC} $org"
                echo -e "${CYAN}Lokasi    :${NC} $loc"
            else
                echo "curl tidak ditemukan. Silakan install dengan: sudo apt install curl"
            fi
            pause
            ;;

        2)
            echo -e "${BOLD}${LBLUE}\n[ Detail Sistem Operasi ]${NC}"
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                echo -e "${CYAN}Nama OS  :${NC} $PRETTY_NAME"
                echo -e "${CYAN}Versi    :${NC} $VERSION"
                echo -e "${CYAN}ID       :${NC} $ID"
                echo -e "${CYAN}Keterangan:${NC} $PRETTY_NAME $VERSION"
            else
                echo "File /etc/os-release tidak ditemukan, mencoba lsb_release..."
                if command -v lsb_release &> /dev/null; then
                    os_name=$(lsb_release -si 2>/dev/null)
                    os_version=$(lsb_release -sr 2>/dev/null)
                    os_id=$(lsb_release -si 2>/dev/null | tr '[:upper:]' '[:lower:]')
                    echo -e "${CYAN}Nama OS  :${NC} $os_name"
                    echo -e "${CYAN}Versi    :${NC} $os_version"
                    echo -e "${CYAN}ID       :${NC} $os_id"
                    echo -e "${CYAN}Keterangan:${NC} $os_name $os_version"
                else
                    echo "lsb_release tidak tersedia."
                fi
            fi

            echo -e "${BOLD}${LCYAN}\nInformasi Kernel:${NC}"
            echo -e "\033[36m$(uname -a | sed 's/^/    /')\033[0m"

            echo -e "${BOLD}${LCYAN}\nPenggunaan CPU:${NC}"
            if command -v mpstat &> /dev/null; then
                mpstat 1 1 | awk '/Average/ {
                    printf "\033[36m    %%CPU: %s us, %s sy, %s wa, %s hi, %s si, %s st, %s id\033[0m\n", $3, $5, $6, $7, $8, $9, $12
                }'
            else
                echo -e "\033[33m    mpstat tidak ditemukan. Silakan install dengan: sudo apt install sysstat\033[0m"
                echo -e "\033[33m    Alternatif penggunaan CPU (dari /proc/stat):\033[0m"
                cpu=$(awk '/cpu / { 
                    total=$2+$4+$5; 
                    printf "    %%CPU: %.2f us, %.2f sy, %.2f id", ($2/total)*100, ($4/total)*100, ($5/total)*100 
                }' /proc/stat)
                echo -e "\033[36m$cpu\033[0m"
            fi


            echo -e "${BOLD}${LCYAN}\nPenggunaan Memori:${NC}"
            echo -e "\033[36m$(free -h)\033[0m"

            echo -e "${BOLD}${LCYAN}\nPenggunaan Disk:${NC}"
            echo -e "\033[36m$(df -h)\033[0m"
            pause
            ;;

        3)
            echo -e "${BOLD}${LBLUE}\n[ Informasi User ]${NC}"
            username=$(whoami)
            echo -e "${CYAN}Username:${NC} $username"
            echo -e "${CYAN}User ID (UID):${NC} $(id -u "$username")"
            echo -e "${CYAN}Group ID (GID):${NC} $(id -g "$username")"
            if command -v getent &> /dev/null; then
                user_info=$(getent passwd "$username")
                full_name=$(echo "$user_info" | cut -d: -f5 | cut -d, -f1)
                home_dir=$(echo "$user_info" | cut -d: -f6)
                shell=$(echo "$user_info" | cut -d: -f7)
                echo -e "${CYAN}Nama Lengkap:${NC} ${full_name:-Tidak tersedia}"
                echo -e "${CYAN}Home Directory:${NC} $home_dir"
                echo -e "${CYAN}Shell:${NC} $shell"
            else
                echo "getent tidak ditemukan, mencoba parsing /etc/passwd..."
                user_info=$(grep "^$username:" /etc/passwd)
                if [ -n "$user_info" ]; then
                    full_name=$(echo "$user_info" | cut -d: -f5 | cut -d, -f1)
                    home_dir=$(echo "$user_info" | cut -d: -f6)
                    shell=$(echo "$user_info" | cut -d: -f7)
                    echo -e "${CYAN}Nama Lengkap:${NC} ${full_name:-Tidak tersedia}"
                    echo -e "${CYAN}Home Directory:${NC} $home_dir"
                    echo -e "${CYAN}Shell:${NC} $shell"
                else
                    echo "Informasi pengguna tidak ditemukan di /etc/passwd."
                fi
            fi
            pause
            ;;

        4)
            echo -ne "${CYAN}Apakah Anda yakin ingin keluar? (y/n): ${NC}"
            read -r REPLY
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo -e "\n${BOLD}${LCYAN}Terima kasih telah menggunakan skrip ini.${NC}"
                break
            fi
            ;;

        *)
            echo -e "${BOLD}${RED}Opsi tidak valid.${NC}"
            pause
            ;;
    esac

done
