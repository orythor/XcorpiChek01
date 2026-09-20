#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/color.sh"
source "$SCRIPT_DIR/lib/banner.sh"

clear
show_banner
section "CEK SECURITY WEBSITE"
echo -ne "${GREEN}┃${RESET} Masukkan domain/URL ${GREEN}»${RESET} "
read -r target

if [ -z "$target" ]; then
    error "Input tidak boleh kosong!"; exit 1
fi

# Bersihkan URL
DOMAIN=$(echo "$target" | sed 's|https\?://||' | sed 's|/.*||' | sed 's|www\.||')
URL="https://$DOMAIN"

info "Menganalisis keamanan: $DOMAIN ..."
echo ""

# === SSL/TLS Check ===
echo -e "${CYAN}━━━ SSL/TLS ━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
SSL_INFO=$(echo | timeout 10 openssl s_client -connect "$DOMAIN:443" -servername "$DOMAIN" 2>/dev/null)
if [ $? -eq 0 ]; then
    CERT_ISSUER=$(echo "$SSL_INFO" | grep "issuer=" | sed 's/issuer=//' | tr -d ' ')
    CERT_EXPIRE=$(echo "$SSL_INFO" | grep "notAfter=" | sed 's/.*notAfter=//')
    CERT_SUBJECT=$(echo "$SSL_INFO" | grep "subject=" | sed 's/subject=//' | tr -d ' ')
    echo -e " ${GREEN}[✓] SSL Aktif${RESET}"
    echo -e " Issuer  : $CERT_ISSUER"
    echo -e " Expire  : ${YELLOW}$CERT_EXPIRE${RESET}"
    echo -e " Subject : $CERT_SUBJECT"
else
    echo -e " ${RED}[✗] SSL Tidak Aktif atau Error${RESET}"
fi

# === HTTP Headers Security ===
echo -e "\n${CYAN}━━━ HTTP Security Headers ━━━━━━━━━━━${RESET}"
HEADERS=$(curl -sI "$URL" --max-time 10 2>/dev/null)

check_header() {
    local header="$1"
    local label="$2"
    if echo "$HEADERS" | grep -qi "^$header:"; then
        echo -e " ${GREEN}[✓]${RESET} $label"
    else
        echo -e " ${RED}[✗]${RESET} $label ${DIM}(tidak ada)${RESET}"
    fi
}

check_header "Strict-Transport-Security" "HSTS"
check_header "Content-Security-Policy" "Content-Security-Policy"
check_header "X-Frame-Options" "X-Frame-Options"
check_header "X-Content-Type-Options" "X-Content-Type-Options"
check_header "X-XSS-Protection" "XSS Protection"
check_header "Referrer-Policy" "Referrer-Policy"
check_header "Permissions-Policy" "Permissions-Policy"

# === Server Info ===
echo -e "\n${CYAN}━━━ Server Info ━━━━━━━━━━━━━━━━━━━━${RESET}"
SERVER=$(echo "$HEADERS" | grep -i "^Server:" | awk -F': ' '{print $2}' | tr -d '\r')
POWERED=$(echo "$HEADERS" | grep -i "^X-Powered-By:" | awk -F': ' '{print $2}' | tr -d '\r')
HTTP_CODE=$(curl -so /dev/null -w "%{http_code}" "$URL" --max-time 10)

echo -e " Server     : ${SERVER:-Tersembunyi}"
echo -e " Powered By : ${POWERED:-Tersembunyi}"
echo -e " HTTP Code  : ${YELLOW}$HTTP_CODE${RESET}"

# === DNS Check ===
echo -e "\n${CYAN}━━━ DNS Records ━━━━━━━━━━━━━━━━━━━━${RESET}"
A_RECORD=$(dig +short A "$DOMAIN" 2>/dev/null | head -3)
MX_RECORD=$(dig +short MX "$DOMAIN" 2>/dev/null | head -3)
NS_RECORD=$(dig +short NS "$DOMAIN" 2>/dev/null | head -3)
TXT_RECORD=$(dig +short TXT "$DOMAIN" 2>/dev/null | grep -i "spf\|dmarc" | head -2)

echo -e " A Record  : ${A_RECORD:-N/A}"
echo -e " MX Record : ${MX_RECORD:-N/A}"
echo -e " NS Record : ${NS_RECORD:-N/A}"
echo -e " SPF/DMARC : ${TXT_RECORD:-Tidak ada}"

# === VirusTotal Check ===
echo -e "\n${CYAN}━━━ Reputasi (VirusTotal) ━━━━━━━━━━${RESET}"
VT_RESULT=$(curl -s "https://www.virustotal.com/vtapi/v2/url/report?apikey=no-key&resource=$URL" 2>/dev/null)
if echo "$VT_RESULT" | jq -e '.positives' &>/dev/null 2>&1; then
    POSITIVES=$(echo "$VT_RESULT" | jq -r '.positives')
    TOTAL=$(echo "$VT_RESULT" | jq -r '.total')
    [ "$POSITIVES" -eq 0 ] && \
        echo -e " ${GREEN}[✓] Bersih: 0/$TOTAL engine${RESET}" || \
        echo -e " ${RED}[!] Terdeteksi: $POSITIVES/$TOTAL engine${RESET}"
else
    echo -e " ${DIM}(API Key VT diperlukan untuk scan penuh)${RESET}"
    echo -e " Cek manual: https://www.virustotal.com/gui/url/$(echo -n $URL | base64 | tr '/+' '_-' | tr -d '=')"
fi

echo ""
success "Analisis selesai untuk $DOMAIN"
