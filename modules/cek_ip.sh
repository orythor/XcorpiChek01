#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/color.sh"
source "$SCRIPT_DIR/lib/banner.sh"

clear
show_banner
section "CEK IP DETAIL"
echo -e "${DIM}Kosongkan untuk cek IP sendiri${RESET}"
echo -ne "${GREEN}┃${RESET} Masukkan IP/Domain ${GREEN}»${RESET} "
read -r target

if [ -z "$target" ]; then
    info "Mendeteksi IP publik kamu ..."
    target=$(curl -s "https://api.ipify.org")
    info "IP kamu: $target"
fi

echo ""
info "Mengambil detail untuk: $target ..."
echo ""

# Resolve domain ke IP jika bukan IP
if echo "$target" | grep -qP '[a-zA-Z]'; then
    IP=$(getent hosts "$target" | awk '{ print $1 }' | head -1)
    [ -z "$IP" ] && IP=$(curl -s "https://dns.google/resolve?name=$target&type=A" | jq -r '.Answer[0].data // empty' | head -1)
    DOMAIN="$target"
    TARGET_IP="${IP:-$target}"
else
    TARGET_IP="$target"
    DOMAIN="-"
fi

# Ambil info IP dari multiple sumber
DATA=$(curl -s "https://ipapi.co/$TARGET_IP/json/")
DATA2=$(curl -s "https://ipwho.is/$TARGET_IP")

IP_ADDR=$(echo "$DATA" | jq -r '.ip // empty')
CITY=$(echo "$DATA" | jq -r '.city // empty')
REGION=$(echo "$DATA" | jq -r '.region // empty')
COUNTRY=$(echo "$DATA" | jq -r '.country_name // empty')
ZIP=$(echo "$DATA" | jq -r '.postal // empty')
LAT=$(echo "$DATA" | jq -r '.latitude // empty')
LON=$(echo "$DATA" | jq -r '.longitude // empty')
ISP=$(echo "$DATA" | jq -r '.org // empty')
ASN=$(echo "$DATA" | jq -r '.asn // empty')
TIMEZONE=$(echo "$DATA" | jq -r '.timezone // empty')
CURRENCY=$(echo "$DATA" | jq -r '.currency_name // empty')

# Fallback ke ipwho.is
[ -z "$CITY" ] && CITY=$(echo "$DATA2" | jq -r '.city // empty')
[ -z "$ISP" ] && ISP=$(echo "$DATA2" | jq -r '.connection.isp // empty')

# Cek VPN/Proxy/Tor
THREAT=$(curl -s "https://ipapi.co/$TARGET_IP/json/" | jq -r '.threat // "N/A"')

echo -e "${CYAN}╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮${RESET}"
echo -e "${CYAN}┃${RESET}         ${BOLD}Detail IP Address${RESET}          ${CYAN}┃${RESET}"
echo -e "${CYAN}├━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┤${RESET}"
echo -e "${CYAN}┃${RESET} IP       : ${GREEN}${IP_ADDR:-$TARGET_IP}${RESET}"
echo -e "${CYAN}┃${RESET} Domain   : ${DOMAIN}"
echo -e "${CYAN}┃${RESET} Kota     : ${CITY:-N/A}"
echo -e "${CYAN}┃${RESET} Provinsi : ${REGION:-N/A}"
echo -e "${CYAN}┃${RESET} Negara   : ${YELLOW}${COUNTRY:-N/A}${RESET}"
echo -e "${CYAN}┃${RESET} Kode Pos : ${ZIP:-N/A}"
echo -e "${CYAN}┃${RESET} Lat/Lon  : ${LAT:-N/A} / ${LON:-N/A}"
echo -e "${CYAN}┃${RESET} ISP      : ${ISP:-N/A}"
echo -e "${CYAN}┃${RESET} ASN      : ${ASN:-N/A}"
echo -e "${CYAN}┃${RESET} Timezone : ${TIMEZONE:-N/A}"
echo -e "${CYAN}┃${RESET} Mata Uang: ${CURRENCY:-N/A}"
echo -e "${CYAN}├━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┤${RESET}"
echo -e "${CYAN}┃${RESET} Maps     : https://maps.google.com/?q=$LAT,$LON"
echo -e "${CYAN}╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯${RESET}"
success "Selesai!"
