#!/bin/bash
# ═══════════════════════════════════════════════
#  XcorpiChek01 Installer - By XioNiV ID
# ═══════════════════════════════════════════════

RED="\e[31m"; GREEN="\e[32m"; YELLOW="\e[33m"; CYAN="\e[36m"; RESET="\e[0m"; BOLD="\e[1m"

clear
echo -e "${CYAN}╭━━━〔 XcorpiChek01 - Installer 〕━━━━╮${RESET}"
echo -e "${CYAN}┃${RESET}     ${BOLD}By XioNiV ID${RESET}                    ${CYAN}┃${RESET}"
echo -e "${CYAN}╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯${RESET}"
echo ""

info()    { echo -e "${CYAN}[*]${RESET} $*"; }
success() { echo -e "${GREEN}[✓]${RESET} $*"; }
warn()    { echo -e "${YELLOW}[!]${RESET} $*"; }
error()   { echo -e "${RED}[✗]${RESET} $*"; }

# Update repo
info "Update package repository..."
pkg update -y &>/dev/null && success "Repository updated" || warn "Partial update"

# Install dependensi wajib
info "Installing dependensi utama..."
PKGS=("curl" "jq" "python3" "dnsutils" "openssl-tool")
for pkg in "${PKGS[@]}"; do
    if ! command -v "$pkg" &>/dev/null && ! dpkg -l "$pkg" &>/dev/null 2>&1; then
        pkg install -y "$pkg" &>/dev/null
    fi
    success "  $pkg"
done

# Install Python packages
info "Installing Python packages..."
pip install requests pillow 2>/dev/null | tail -1
success "Python packages installed"

# Optional: Playwright untuk screenshot/record
echo ""
warn "Install Playwright? (untuk fitur Screenshot & Screenrecord)"
echo -ne "${CYAN}┃${RESET} Pilih [y/n] ${GREEN}»${RESET} "
read -r install_pw
if [ "$install_pw" == "y" ] || [ "$install_pw" == "Y" ]; then
    info "Installing Playwright..."
    pip install playwright 2>/dev/null | tail -1
    playwright install chromium 2>/dev/null
    success "Playwright installed!"
else
    warn "Playwright dilewati. Fitur screenshot/record mungkin terbatas."
fi

# Chmod semua script
info "Setting permissions..."
chmod +x "$(dirname "$0")/xcorpichek01.sh"
chmod +x "$(dirname "$0")/modules/"*.sh
success "Permissions set"

# Buat shortcut alias
BASHRC="$HOME/.bashrc"
if ! grep -q "xcorpichek01" "$BASHRC" 2>/dev/null; then
    echo "alias xcorpi='bash $(realpath "$(dirname "$0")/xcorpichek01.sh")'" >> "$BASHRC"
    success "Alias 'xcorpi' ditambahkan ke .bashrc"
fi

echo ""
echo -e "${GREEN}╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮${RESET}"
echo -e "${GREEN}┃${RESET}   ${BOLD}Instalasi Selesai!${RESET}             ${GREEN}┃${RESET}"
echo -e "${GREEN}├━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┤${RESET}"
echo -e "${GREEN}┃${RESET} Jalankan dengan:"
echo -e "${GREEN}┃${RESET}   ${CYAN}bash xcorpichek01.sh${RESET}"
echo -e "${GREEN}┃${RESET}   ${CYAN}xcorpi${RESET} ${DIM}(setelah restart terminal)${RESET}"
echo -e "${GREEN}╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯${RESET}"
