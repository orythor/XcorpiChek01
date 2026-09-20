#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/color.sh"
source "$SCRIPT_DIR/lib/banner.sh"

clear
show_banner
section "STALKER TWITTER / X"
echo -ne "${GREEN}┃${RESET} Masukkan username Twitter/X (tanpa @) ${GREEN}»${RESET} "
read -r username

if [ -z "$username" ]; then
    error "Username tidak boleh kosong!"; exit 1
fi

info "Mengambil data @$username ..."
echo ""

# Scrape via Nitter (alternatif publik) atau x.com
NITTER_INSTANCES=("nitter.net" "nitter.privacydev.net" "nitter.poast.org")
DATA=""

for instance in "${NITTER_INSTANCES[@]}"; do
    DATA=$(curl -sL "https://$instance/$username" \
        -H "User-Agent: Mozilla/5.0" --max-time 10 2>/dev/null)
    [ -n "$DATA" ] && { USED_INSTANCE="$instance"; break; }
done

if [ -z "$DATA" ]; then
    DATA=$(curl -sL "https://x.com/$username" \
        -H "User-Agent: Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36")
    USED_INSTANCE="x.com"
fi

# Parse dari Nitter
FULL_NAME=$(echo "$DATA" | grep -oP '(?<=<a class="profile-card-fullname" href="/[^"]*">)[^<]+' | head -1)
FOLLOWERS=$(echo "$DATA" | grep -oP '(?<=Followers</span>)[^<]+' | tr -d ' \n' | head -1)
FOLLOWING=$(echo "$DATA" | grep -oP '(?<=Following</span>)[^<]+' | tr -d ' \n' | head -1)
TWEETS=$(echo "$DATA" | grep -oP '(?<=Tweets</span>)[^<]+' | tr -d ' \n' | head -1)
BIO=$(echo "$DATA" | grep -oP '(?<=<div class="profile-bio"><p>)[^<]+' | head -1 | cut -c1-100)
JOINED=$(echo "$DATA" | grep -oP '(?<=Joined </span>)[^<]+' | head -1)

[ -z "$FULL_NAME" ] && FULL_NAME=$(echo "$DATA" | grep -oP '"name":"\K[^"]+' | head -1)

echo -e "${CYAN}╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮${RESET}"
echo -e "${CYAN}┃${RESET}   ${BOLD}Hasil Stalker Twitter/X${RESET}      ${CYAN}┃${RESET}"
echo -e "${CYAN}├━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┤${RESET}"
echo -e "${CYAN}┃${RESET} Username  : @$username"
echo -e "${CYAN}┃${RESET} Nama      : ${GREEN}${FULL_NAME:-N/A}${RESET}"
echo -e "${CYAN}┃${RESET} Bio       : ${BIO:-Tidak ada bio}"
echo -e "${CYAN}┃${RESET} Followers : ${YELLOW}${FOLLOWERS:-N/A}${RESET}"
echo -e "${CYAN}┃${RESET} Following : ${FOLLOWING:-N/A}"
echo -e "${CYAN}┃${RESET} Tweet     : ${TWEETS:-N/A}"
echo -e "${CYAN}┃${RESET} Bergabung : ${JOINED:-N/A}"
echo -e "${CYAN}┃${RESET} Sumber    : $USED_INSTANCE"
echo -e "${CYAN}┃${RESET} URL       : https://x.com/$username"
echo -e "${CYAN}╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯${RESET}"

[ -n "$FULL_NAME" ] && success "Data ditemukan!" || warn "Akun tidak ditemukan atau terbatas."
