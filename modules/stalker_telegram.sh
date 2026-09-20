#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/color.sh"
source "$SCRIPT_DIR/lib/banner.sh"

clear
show_banner
section "STALKER TELEGRAM"
echo -ne "${GREEN}┃${RESET} Masukkan username Telegram (tanpa @) ${GREEN}»${RESET} "
read -r username

if [ -z "$username" ]; then
    error "Username tidak boleh kosong!"; exit 1
fi

info "Mencari info untuk @$username ..."
echo ""

# Coba ambil data via t.me
RESULT=$(curl -s "https://t.me/$username")

if echo "$RESULT" | grep -q "tgme_page_title"; then
    NAME=$(echo "$RESULT" | grep -oP '(?<=<div class="tgme_page_title"><span dir="auto">)[^<]+')
    DESC=$(echo "$RESULT" | grep -oP '(?<=<div class="tgme_page_description">)[^<]+' | head -1)
    PHOTO=$(echo "$RESULT" | grep -oP '(?<=<img class="tgme_page_photo_image" src=")[^"]+' | head -1)

    echo -e "${CYAN}╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮${RESET}"
    echo -e "${CYAN}┃${RESET}   ${BOLD}Hasil Stalker Telegram${RESET}       ${CYAN}┃${RESET}"
    echo -e "${CYAN}├━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┤${RESET}"
    echo -e "${CYAN}┃${RESET} Username  : @$username"
    echo -e "${CYAN}┃${RESET} Nama      : ${GREEN}${NAME:-Tidak ditemukan}${RESET}"
    echo -e "${CYAN}┃${RESET} Deskripsi : ${DESC:-Tidak ada deskripsi}"
    echo -e "${CYAN}┃${RESET} Foto      : ${PHOTO:-Tidak ada foto}"
    echo -e "${CYAN}┃${RESET} URL       : https://t.me/$username"
    echo -e "${CYAN}╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯${RESET}"
    success "Data berhasil ditemukan!"
else
    warn "Akun tidak ditemukan atau private."
fi
