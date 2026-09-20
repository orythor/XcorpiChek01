#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/color.sh"
source "$SCRIPT_DIR/lib/banner.sh"

clear
show_banner
section "SCREENSHOT WEB"

# Cek ketersediaan tool
check_shot_tool() {
    if command -v cutycapt &>/dev/null; then
        echo "cutycapt"
    elif command -v wkhtmltoimage &>/dev/null; then
        echo "wkhtmltoimage"
    elif command -v chromium-browser &>/dev/null; then
        echo "chromium"
    elif python3 -c "import playwright" &>/dev/null 2>&1; then
        echo "playwright"
    else
        echo "api"
    fi
}

echo -ne "${GREEN}┃${RESET} Masukkan URL website ${GREEN}»${RESET} "
read -r url

if [ -z "$url" ]; then
    error "URL tidak boleh kosong!"; exit 1
fi

# Tambahkan https jika tidak ada
echo "$url" | grep -q "^http" || url="https://$url"

OUTDIR="$HOME/XcorpiChek01_output"
mkdir -p "$OUTDIR"
FILENAME="screenshot_$(date +%Y%m%d_%H%M%S).png"
OUTPATH="$OUTDIR/$FILENAME"

TOOL=$(check_shot_tool)
info "Mengambil screenshot: $url"
info "Metode: $TOOL"
echo ""

case "$TOOL" in
    "cutycapt")
        cutycapt --url="$url" --out="$OUTPATH" --out-format=png \
            --delay=3000 --min-width=1280 2>/dev/null
        ;;
    "wkhtmltoimage")
        wkhtmltoimage --width 1280 --quality 90 \
            --javascript-delay 2000 "$url" "$OUTPATH" 2>/dev/null
        ;;
    "chromium")
        chromium-browser --headless --disable-gpu \
            --screenshot="$OUTPATH" \
            --window-size=1280,720 "$url" 2>/dev/null
        ;;
    "playwright")
        python3 - <<'PYEOF'
import sys, asyncio
from playwright.async_api import async_playwright
async def shot():
    url = sys.argv[1] if len(sys.argv) > 1 else ""
    outpath = sys.argv[2] if len(sys.argv) > 2 else "/tmp/shot.png"
    async with async_playwright() as p:
        b = await p.chromium.launch()
        page = await b.new_page(viewport={"width":1280,"height":720})
        await page.goto(url, wait_until="networkidle", timeout=30000)
        await page.screenshot(path=outpath, full_page=True)
        await b.close()
asyncio.run(shot())
PYEOF
        ;;
    "api")
        # Gunakan API screenshot publik (tidak butuh install)
        info "Menggunakan layanan screenshot API..."
        ENCODED_URL=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$url'))")
        
        # Coba beberapa layanan gratis
        API_URL="https://api.screenshotmachine.com?key=demo&url=$ENCODED_URL&dimension=1280x720&format=png"
        
        # Alternatif: miniature.io atau s-shot.ru
        curl -sL "https://mini.s-shot.ru/1280x720/PNG/1280/$url" -o "$OUTPATH" 2>/dev/null
        
        if [ ! -s "$OUTPATH" ]; then
            warn "Layanan API gagal. Coba install tool screenshot:"
            echo -e "  ${CYAN}pkg install wkhtmltopdf${RESET}"
            echo -e "  ${CYAN}pip install playwright && playwright install chromium${RESET}"
            exit 1
        fi
        ;;
esac

if [ -f "$OUTPATH" ] && [ -s "$OUTPATH" ]; then
    echo -e "${CYAN}╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮${RESET}"
    echo -e "${CYAN}┃${RESET}   ${BOLD}Screenshot Berhasil!${RESET}         ${CYAN}┃${RESET}"
    echo -e "${CYAN}├━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┤${RESET}"
    echo -e "${CYAN}┃${RESET} URL     : $url"
    echo -e "${CYAN}┃${RESET} Disimpan: ${GREEN}$OUTPATH${RESET}"
    echo -e "${CYAN}┃${RESET} Ukuran  : $(du -sh "$OUTPATH" | cut -f1)"
    echo -e "${CYAN}╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯${RESET}"
    success "Screenshot tersimpan di: $OUTPATH"
    
    # Buka file jika ada viewer
    command -v termux-open &>/dev/null && termux-open "$OUTPATH"
else
    error "Gagal membuat screenshot."
    warn "Pastikan internet aktif dan URL valid."
fi
