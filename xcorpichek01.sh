#!/bin/bash
# ═══════════════════════════════════════════════
#  XcorpiChek01 - By XioNiV ID
#  Tools Stalker & Security Checker for Termux
# ═══════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/color.sh"
source "$SCRIPT_DIR/lib/banner.sh"

check_deps() {
    local deps=("curl" "jq" "python3" "figlet")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            echo -e "${RED}[!] Missing: $dep${RESET}"
            echo -e "${YELLOW}[*] Install: pkg install $dep${RESET}"
            missing=1
        fi
    done
    [ "$missing" == "1" ] && exit 1
}

show_menu() {
    clear
    show_banner
    echo -e "${CYAN}╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮${RESET}"
    echo -e "${CYAN}┃${RESET}        ${BOLD}[ MAIN MENU ]${RESET}               ${CYAN}┃${RESET}"
    echo -e "${CYAN}├━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┤${RESET}"
    echo -e "${CYAN}┃${RESET}  ${GREEN}[01]${RESET} Stalker Telegram               ${CYAN}┃${RESET}"
    echo -e "${CYAN}┃${RESET}  ${GREEN}[02]${RESET} Stalker YouTube                ${CYAN}┃${RESET}"
    echo -e "${CYAN}┃${RESET}  ${GREEN}[03]${RESET} Stalker Instagram              ${CYAN}┃${RESET}"
    echo -e "${CYAN}┃${RESET}  ${GREEN}[04]${RESET} Stalker Twitter/X              ${CYAN}┃${RESET}"
    echo -e "${CYAN}┃${RESET}  ${GREEN}[05]${RESET} Stalker Spotify                ${CYAN}┃${RESET}"
    echo -e "${CYAN}├━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┤${RESET}"
    echo -e "${CYAN}┃${RESET}  ${YELLOW}[06]${RESET} Cek IP Detail                  ${CYAN}┃${RESET}"
    echo -e "${CYAN}┃${RESET}  ${YELLOW}[07]${RESET} Cek Security Website           ${CYAN}┃${RESET}"
    echo -e "${CYAN}┃${RESET}  ${YELLOW}[08]${RESET} Screenshot Web                 ${CYAN}┃${RESET}"
    echo -e "${CYAN}┃${RESET}  ${YELLOW}[09]${RESET} Screenrecord Web               ${CYAN}┃${RESET}"
    echo -e "${CYAN}├━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┤${RESET}"
    echo -e "${CYAN}┃${RESET}  ${RED}[00]${RESET} Keluar                         ${CYAN}┃${RESET}"
    echo -e "${CYAN}╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯${RESET}"
    echo ""
    echo -ne "${CYAN}┃${RESET} Pilih menu ${GREEN}»${RESET} "
}

main() {
    check_deps
    while true; do
        show_menu
        read -r choice
        case "$choice" in
            01|1) bash "$SCRIPT_DIR/modules/stalker_telegram.sh" ;;
            02|2) bash "$SCRIPT_DIR/modules/stalker_youtube.sh" ;;
            03|3) bash "$SCRIPT_DIR/modules/stalker_instagram.sh" ;;
            04|4) bash "$SCRIPT_DIR/modules/stalker_twitter.sh" ;;
            05|5) bash "$SCRIPT_DIR/modules/stalker_spotify.sh" ;;
            06|6) bash "$SCRIPT_DIR/modules/cek_ip.sh" ;;
            07|7) bash "$SCRIPT_DIR/modules/cek_security.sh" ;;
            08|8) bash "$SCRIPT_DIR/modules/screenshot_web.sh" ;;
            09|9) bash "$SCRIPT_DIR/modules/screenrecord_web.sh" ;;
            00|0) echo -e "\n${RED}[*] Keluar dari XcorpiChek01...${RESET}\n"; exit 0 ;;
            *) echo -e "${RED}[!] Pilihan tidak valid!${RESET}"; sleep 1 ;;
        esac
        echo -e "\n${YELLOW}[*] Tekan ENTER untuk kembali ke menu...${RESET}"
        read -r
    done
}

main
