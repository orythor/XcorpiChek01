#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/color.sh"
source "$SCRIPT_DIR/lib/banner.sh"

clear
show_banner
section "STALKER YOUTUBE"
echo -e "${DIM}Contoh input: @channelname atau channel ID${RESET}"
echo -ne "${GREEN}┃${RESET} Masukkan username/channel ${GREEN}»${RESET} "
read -r channel

if [ -z "$channel" ]; then
    error "Input tidak boleh kosong!"; exit 1
fi

info "Mengambil data channel YouTube: $channel ..."
echo ""

# Strip @ jika ada
channel="${channel#@}"

# Ambil data dari YouTube via scraping
RESULT=$(curl -sL "https://www.youtube.com/@$channel" \
    -H "User-Agent: Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36")

CHANNEL_NAME=$(echo "$RESULT" | grep -oP '"channelMetadataRenderer":\{"title":"\K[^"]+' | head -1)
SUBS=$(echo "$RESULT" | grep -oP '"subscriberCountText":\{"simpleText":"\K[^"]+' | head -1)
DESC=$(echo "$RESULT" | grep -oP '"description":"\K[^"]+' | head -1 | cut -c1-100)
VIDEOS=$(echo "$RESULT" | grep -oP '"videoCountText":\{"runs":\[.*?"text":"\K[^"]+' | head -1)
COUNTRY=$(echo "$RESULT" | grep -oP '"country":"\K[^"]+' | head -1)

echo -e "${CYAN}╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮${RESET}"
echo -e "${CYAN}┃${RESET}   ${BOLD}Hasil Stalker YouTube${RESET}        ${CYAN}┃${RESET}"
echo -e "${CYAN}├━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┤${RESET}"
echo -e "${CYAN}┃${RESET} Channel   : ${GREEN}${CHANNEL_NAME:-$channel}${RESET}"
echo -e "${CYAN}┃${RESET} Subscriber: ${YELLOW}${SUBS:-Tidak tersedia}${RESET}"
echo -e "${CYAN}┃${RESET} Video     : ${VIDEOS:-Tidak tersedia}"
echo -e "${CYAN}┃${RESET} Negara    : ${COUNTRY:-Tidak diketahui}"
echo -e "${CYAN}┃${RESET} Deskripsi : ${DESC:-Tidak ada}"
echo -e "${CYAN}┃${RESET} URL       : https://youtube.com/@$channel"
echo -e "${CYAN}╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯${RESET}"

[ -n "$CHANNEL_NAME" ] && success "Data ditemukan!" || warn "Channel tidak ditemukan atau data terbatas."
