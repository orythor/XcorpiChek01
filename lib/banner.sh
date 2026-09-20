#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/color.sh"

show_banner() {
    echo -e "${CYAN}╭━━━〔 XcorpiChek01 〕━━━━━━━━━━━━${RESET}"
    echo -e "${CYAN}┃${RESET}"
    echo -e "${CYAN}┃${RESET}  ${MAGENTA}▓█▓▒░${RESET}  ██╗  ██╗ ██████╗ ██████╗ ██████╗ ██████╗ ██╗"
    echo -e "${CYAN}┃${RESET}  ${MAGENTA}░▒▓█${RESET}  ╚██╗██╔╝██╔════╝██╔═══██╗██╔══██╗██╔══██╗██║"
    echo -e "${CYAN}┃${RESET}  ${MAGENTA}▓█▓▒${RESET}   ╚███╔╝ ██║     ██║   ██║██████╔╝██████╔╝██║"
    echo -e "${CYAN}┃${RESET}  ${MAGENTA}▒▓█▓${RESET}   ██╔██╗ ██║     ██║   ██║██╔══██╗██╔═══╝ ██║"
    echo -e "${CYAN}┃${RESET}  ${MAGENTA}█▓▒░${RESET}  ██╔╝ ██╗╚██████╗╚██████╔╝██║  ██║██║     ██║"
    echo -e "${CYAN}┃${RESET}  ${MAGENTA}░░▒▒${RESET}  ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝"
    echo -e "${CYAN}┃${RESET}"
    echo -e "${CYAN}╰━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "   ${DIM}By XioNiV ID${RESET}  ${GREEN}v1.0${RESET}"
    echo ""
}
