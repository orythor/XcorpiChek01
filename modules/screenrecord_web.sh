#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/color.sh"
source "$SCRIPT_DIR/lib/banner.sh"

clear
show_banner
section "SCREENRECORD WEB"
echo -ne "${GREEN}┃${RESET} Masukkan URL website ${GREEN}»${RESET} "
read -r url
echo -ne "${GREEN}┃${RESET} Durasi rekaman (detik, default 10) ${GREEN}»${RESET} "
read -r duration
duration="${duration:-10}"

if [ -z "$url" ]; then
    error "URL tidak boleh kosong!"; exit 1
fi

echo "$url" | grep -q "^http" || url="https://$url"

OUTDIR="$HOME/XcorpiChek01_output"
mkdir -p "$OUTDIR"
FILENAME="screenrecord_$(date +%Y%m%d_%H%M%S)"
OUTPATH="$OUTDIR/$FILENAME"

info "Merekam: $url (${duration}s)"
echo ""

# Cek tool yang tersedia
if python3 -c "from playwright.async_api import async_playwright" &>/dev/null 2>&1; then
    # Playwright: bisa record + screenshot sequence
    info "Menggunakan Playwright (screenshot sequence -> GIF)..."
    
    python3 - "$url" "$OUTPATH" "$duration" <<'PYEOF'
import sys, asyncio, time
from playwright.async_api import async_playwright

async def record():
    url = sys.argv[1]
    outpath = sys.argv[2]
    duration = int(sys.argv[3])
    frames = []
    
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        page = await browser.new_page(viewport={"width": 1280, "height": 720})
        await page.goto(url, wait_until="networkidle", timeout=30000)
        
        print(f"[*] Merekam {duration} detik...")
        start = time.time()
        frame_i = 0
        
        while time.time() - start < duration:
            frame_path = f"{outpath}_frame_{frame_i:04d}.png"
            await page.screenshot(path=frame_path)
            frames.append(frame_path)
            frame_i += 1
            await asyncio.sleep(0.5)  # 2fps
        
        await browser.close()
    
    # Convert ke GIF jika ada pillow
    try:
        from PIL import Image
        images = [Image.open(f) for f in frames]
        gif_path = f"{outpath}.gif"
        images[0].save(gif_path, save_all=True, append_images=images[1:],
                      optimize=False, duration=500, loop=0)
        print(f"[✓] GIF disimpan: {gif_path}")
        # Hapus frames temp
        import os
        for f in frames:
            os.remove(f)
    except ImportError:
        print(f"[*] Frames disimpan di: {outpath}_frame_*.png")
        print("[!] Install pillow untuk convert ke GIF: pip install pillow")

asyncio.run(record())
PYEOF

elif command -v ffmpeg &>/dev/null && command -v chromium-browser &>/dev/null; then
    # Chromium + FFmpeg headless
    info "Menggunakan Chromium + FFmpeg..."
    DISPLAY=":99"
    
    # Start virtual display jika ada Xvfb
    if command -v Xvfb &>/dev/null; then
        Xvfb :99 -screen 0 1280x720x24 &
        XVFB_PID=$!
        sleep 1
    fi
    
    chromium-browser --headless=false --display=$DISPLAY \
        --window-size=1280,720 "$url" &
    CHROME_PID=$!
    sleep 2
    
    ffmpeg -y -f x11grab -r 15 -s 1280x720 -i $DISPLAY \
        -t "$duration" -vcodec libx264 -preset fast \
        "${OUTPATH}.mp4" 2>/dev/null
    
    kill $CHROME_PID 2>/dev/null
    [ -n "$XVFB_PID" ] && kill $XVFB_PID 2>/dev/null
    
    OUTPATH="${OUTPATH}.mp4"

else
    warn "Tool untuk screenrecord web tidak ditemukan."
    echo ""
    echo -e "Install salah satu opsi berikut:"
    echo -e "  ${CYAN}[Option 1]${RESET} pip install playwright pillow"
    echo -e "             playwright install chromium"
    echo ""
    echo -e "  ${CYAN}[Option 2]${RESET} pkg install ffmpeg chromium"
    echo ""
    echo -e "  ${CYAN}[Note]${RESET} Termux perlu X11 untuk opsi 2"
    echo -e "         Disarankan pakai Playwright (opsi 1)"
    exit 1
fi

# Cek hasil
OUTPUT_FILE=$(ls "${OUTPATH}"* 2>/dev/null | head -1)
if [ -n "$OUTPUT_FILE" ] && [ -s "$OUTPUT_FILE" ]; then
    echo -e "${CYAN}╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮${RESET}"
    echo -e "${CYAN}┃${RESET}   ${BOLD}Rekaman Berhasil!${RESET}            ${CYAN}┃${RESET}"
    echo -e "${CYAN}├━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┤${RESET}"
    echo -e "${CYAN}┃${RESET} URL      : $url"
    echo -e "${CYAN}┃${RESET} Durasi   : ${duration}s"
    echo -e "${CYAN}┃${RESET} Disimpan : ${GREEN}$OUTPUT_FILE${RESET}"
    echo -e "${CYAN}┃${RESET} Ukuran   : $(du -sh "$OUTPUT_FILE" | cut -f1)"
    echo -e "${CYAN}╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯${RESET}"
    success "Rekaman tersimpan!"
    command -v termux-open &>/dev/null && termux-open "$OUTPUT_FILE"
else
    error "Gagal merekam website."
fi
