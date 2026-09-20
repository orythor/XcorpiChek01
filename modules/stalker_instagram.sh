#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/color.sh"
source "$SCRIPT_DIR/lib/banner.sh"

clear
show_banner
section "STALKER INSTAGRAM"
echo -ne "${GREEN}┃${RESET} Masukkan username Instagram (tanpa @) ${GREEN}»${RESET} "
read -r username

if [ -z "$username" ]; then
    error "Username tidak boleh kosong!"; exit 1
fi

info "Mengambil data @$username ..."
echo ""

# Ambil via endpoint JSON publik Instagram
DATA=$(curl -s "https://www.instagram.com/$username/?__a=1&__d=dis" \
    -H "User-Agent: Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36" \
    -H "Accept: application/json")

# Fallback: scrape HTML
if ! echo "$DATA" | jq -e '.graphql' &>/dev/null 2>&1; then
    RAW=$(curl -sL "https://www.instagram.com/$username/" \
        -H "User-Agent: Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36")
    
    FULL_NAME=$(echo "$RAW" | grep -oP '"full_name":"\K[^"]+' | head -1)
    BIO=$(echo "$RAW" | grep -oP '"biography":"\K[^"]+' | head -1 | cut -c1-100)
    FOLLOWERS=$(echo "$RAW" | grep -oP '"edge_followed_by":\{"count":\K[0-9]+' | head -1)
    FOLLOWING=$(echo "$RAW" | grep -oP '"edge_follow":\{"count":\K[0-9]+' | head -1)
    POSTS=$(echo "$RAW" | grep -oP '"edge_owner_to_timeline_media":\{"count":\K[0-9]+' | head -1)
    IS_PRIVATE=$(echo "$RAW" | grep -oP '"is_private":\K(true|false)' | head -1)
    IS_VERIFIED=$(echo "$RAW" | grep -oP '"is_verified":\K(true|false)' | head -1)
else
    USER=$(echo "$DATA" | jq -r '.graphql.user')
    FULL_NAME=$(echo "$USER" | jq -r '.full_name')
    BIO=$(echo "$USER" | jq -r '.biography' | cut -c1-100)
    FOLLOWERS=$(echo "$USER" | jq -r '.edge_followed_by.count')
    FOLLOWING=$(echo "$USER" | jq -r '.edge_follow.count')
    POSTS=$(echo "$USER" | jq -r '.edge_owner_to_timeline_media.count')
    IS_PRIVATE=$(echo "$USER" | jq -r '.is_private')
    IS_VERIFIED=$(echo "$USER" | jq -r '.is_verified')
fi

[ "$IS_VERIFIED" == "true" ] && VERIFIED="${GREEN}✓ Verified${RESET}" || VERIFIED="${RED}✗ Tidak Verified${RESET}"
[ "$IS_PRIVATE" == "true" ]  && PRIV="${RED}Private${RESET}" || PRIV="${GREEN}Public${RESET}"

echo -e "${CYAN}╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮${RESET}"
echo -e "${CYAN}┃${RESET}   ${BOLD}Hasil Stalker Instagram${RESET}      ${CYAN}┃${RESET}"
echo -e "${CYAN}├━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┤${RESET}"
echo -e "${CYAN}┃${RESET} Username  : @$username"
echo -e "${CYAN}┃${RESET} Nama      : ${GREEN}${FULL_NAME:-N/A}${RESET}"
echo -e "${CYAN}┃${RESET} Bio       : ${BIO:-Tidak ada bio}"
echo -e "${CYAN}┃${RESET} Followers : ${YELLOW}${FOLLOWERS:-N/A}${RESET}"
echo -e "${CYAN}┃${RESET} Following : ${FOLLOWING:-N/A}"
echo -e "${CYAN}┃${RESET} Postingan : ${POSTS:-N/A}"
echo -e "${CYAN}┃${RESET} Status    : $PRIV"
echo -e "${CYAN}┃${RESET} Verified  : $VERIFIED"
echo -e "${CYAN}┃${RESET} URL       : https://instagram.com/$username"
echo -e "${CYAN}╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯${RESET}"

[ -n "$FULL_NAME" ] && success "Data ditemukan!" || warn "Akun tidak ditemukan atau datanya terbatas."
