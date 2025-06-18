#!/bin/bash

# ------ Definisi Warna ANSI ------
NC='\033[0m'
BOLD='\033[1m'
BLUE='\033[0;34m'
LBLUE='\033[1;34m'
CYAN='\033[0;36m'
LCYAN='\033[1;36m'

# ------ Fungsi Header ------
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

    max_len=0
    for line in "${ascii_art[@]}"; do
        [ ${#line} -gt $max_len ] && max_len=${#line}
    done

    echo -e "${BOLD}${LCYAN}╔$(printf '═%.0s' $(seq 1 $((max_len + 2))))╗${NC}"
    for line in "${ascii_art[@]}"; do
        padding=$(( (max_len - ${#line}) / 2 ))
        pad_right=$(( max_len - ${#line} - padding ))
        printf "${BOLD}${LCYAN}║${NC} %${padding}s${BOLD}${LBLUE}%s%${pad_right}s ${BOLD}${LCYAN}║${NC}\n" "" "$line" ""
    done
    echo -e "${BOLD}${LCYAN}╚$(printf '═%.0s' $(seq 1 $((max_len + 2))))╝${NC}"
}

# ------ Fungsi Menu ------
show_menu() {
    echo
    echo -e "${CYAN}1.${NC} ${BOLD}${BLUE}INFORMASI JARINGAN${NC}"
    echo -e "${CYAN}2.${NC} ${BOLD}${BLUE}TAMPILKAN DETAIL OS${NC}"
    echo -e "${CYAN}3.${NC} ${BOLD}${BLUE}KELUAR${NC}"
    echo
}

pause() {
    echo
    echo -ne "${BOLD}${CYAN}Tekan Enter untuk kembali ke menu utama...${NC}"
    read -r
}

# ------ Fungsi Informasi Jaringan ------
show_network_info() {
    echo -e "${BOLD}${LBLUE}\n[ Informasi Jaringan ]${NC}"

    echo -e "${BOLD}${LCYAN}\n[ Informasi Jaringan Lokal ]${NC}"
    ip addr show | grep inet | grep -v inet6 | grep -v 127.0.0.1 | while read -r line; do
        ip_cidr=$(echo "$line" | awk '{print $2}')
        ip=$(echo "$ip_cidr" | cut -d'/' -f1)
        gateway=$(ip route | grep default | awk '{print $3}')

        echo -e "${CYAN}Alamat IP   :${NC} $ip"
        echo -e "${CYAN}Gateway     :${NC} $gateway"
        echo -e "${CYAN}Netmask     :${NC} $ip_cidr"
    done

    echo -e "${BOLD}${LCYAN}\n[ Server DNS ]${NC}"
    [ -f /etc/resolv.conf ] && grep nameserver /etc/resolv.conf | awk '{print "    "$2}' || echo "    File /etc/resolv.conf tidak ditemukan."

    if command -v nmcli &>/dev/null && systemctl is-active NetworkManager &>/dev/null; then
        nmcli connection show --active | awk 'NR>1 {print $1}' | while read -r conn; do
            nmcli connection show "$conn" | grep 'ipv4.dns:' | awk '{print "    "$2}'
        done
    fi

    echo -e "${BOLD}${LCYAN}\n[ Status Koneksi LAN/WIFI ]${NC}"
    if command -v nmcli &>/dev/null && systemctl is-active NetworkManager &>/dev/null; then
        nmcli device status | awk 'NR==1 {printf "\033[1;37m%-10s %-10s %-25s %-s\033[0m\n", $1, $2, $3, $4}
        NR>1 {printf "\033[36m%-10s %-10s %-25s %-s\033[0m\n", $1, $2, $3, $4}'
    else
        ip link show | awk '/^[0-9]+:/ {print "Perangkat: "$2, "Status: "$9}'
    fi

    echo -e "${BOLD}${LCYAN}\n[ Status Koneksi Internet ]${NC}"
    curl -s --head https://www.google.com > /dev/null && \
        echo -e "${CYAN}Koneksi Internet:${NC} Terhubung" || \
        echo -e "${CYAN}Koneksi Internet:${NC} Tidak Terhubung"

    echo -e "${BOLD}${LCYAN}\n[ Informasi Geolokasi IP Publik ]${NC}"
    if command -v curl &>/dev/null; then
        info=$(curl -s ipinfo.io)
        city=$(echo "$info" | grep '"city"' | cut -d '"' -f 4)
        region=$(echo "$info" | grep '"region"' | cut -d '"' -f 4)
        country=$(echo "$info" | grep '"country"' | cut -d '"' -f 4)

        echo -e "${CYAN}Kota      :${NC} $city"
        echo -e "${CYAN}Wilayah   :${NC} $region"
        echo -e "${CYAN}Negara    :${NC} $country"
    else
        echo "curl tidak ditemukan. Silakan install dengan: sudo apt install curl"
    fi

    pause
}

# ------ Fungsi Detail OS ------
show_os_info() {
    echo -e "${BOLD}${LBLUE}\n[ Detail Sistem Operasi ]${NC}"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo -e "${CYAN}Nama OS    :${NC} $NAME"
        echo -e "${CYAN}Versi      :${NC} $VERSION"
        echo -e "${CYAN}ID         :${NC} $ID"
        echo -e "${CYAN}Keterangan :${NC} $PRETTY_NAME"
    else
        echo "File /etc/os-release tidak ditemukan."
    fi

    echo -e "${BOLD}${LCYAN}\n[ Informasi Kernel: ]${NC}"
    echo -e "${CYAN}    $(uname -r)${NC}"

    echo -e "${BOLD}${LCYAN}\n[ Penggunaan CPU: ]${NC}"
    if command -v mpstat &>/dev/null; then
        mpstat 1 1 | awk '/Average/ {
            printf "\033[36m    %%CPU: %s us, %s sy, %s wa, %s hi, %s si, %s st, %s id\033[0m\n", $3, $5, $6, $7, $8, $9, $12
        }'
    else
        cpu=$(awk '/cpu / { total=$2+$4+$5; printf "    %%CPU: %.2f us, %.2f sy, %.2f id", ($2/total)*100, ($4/total)*100, ($5/total)*100 }' /proc/stat)
        echo -e "\033[36m$cpu\033[0m"
    fi

    echo -e "${BOLD}${LCYAN}\n[ Penggunaan Memori: ]${NC}"
    echo -e "\033[36m$(free -h)\033[0m"

    echo -e "${BOLD}${LCYAN}\n[ Penggunaan Disk: ]${NC}"
    echo -e "\033[36m$(df -h)\033[0m"

    pause
}

# ------ Loop Menu Utama ------
while true; do
    header
    show_menu

    echo -ne "${BOLD}${CYAN}PILIH OPSI [1-3]: ${NC}"
    read -r pilihan

    case $pilihan in
        1) show_network_info ;;
        2) show_os_info ;;
        3)
            echo -ne "${CYAN}Apakah Anda yakin ingin keluar? (y/n): ${NC}"
            read -r REPLY
            [[ $REPLY =~ ^[Yy]$ ]] && echo -e "\n${BOLD}${LCYAN}Terima kasih telah menggunakan skrip ini.${NC}" && break
            ;;
        *)
            echo -e "${BOLD}${RED}Opsi tidak valid.${NC}"
            pause
            ;;
    esac
done
