#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/lib/color.sh"
source "$SCRIPT_DIR/lib/banner.sh"

clear
show_banner
section "STALKER SPOTIFY"
echo -e "${DIM}Pilih mode pencarian:${RESET}"
echo -e "  ${GREEN}[1]${RESET} Cari Artist/User by Username"
echo -e "  ${GREEN}[2]${RESET} Cari by Spotify URL/URI"
echo -ne "${GREEN}┃${RESET} Pilihan ${GREEN}»${RESET} "
read -r mode

if [ "$mode" == "2" ]; then
    echo -ne "${GREEN}┃${RESET} Masukkan Spotify URL ${GREEN}»${RESET} "
    read -r spotify_url
    # Extract ID dari URL
    SPOTIFY_ID=$(echo "$spotify_url" | grep -oP '(?<=/)[a-zA-Z0-9]{22}' | head -1)
    TYPE=$(echo "$spotify_url" | grep -oP '(?<=spotify.com/)[^/]+' | head -1)
else
    echo -ne "${GREEN}┃${RESET} Masukkan username/nama artist ${GREEN}»${RESET} "
    read -r search_query
    TYPE="search"
fi

if [ -z "$SPOTIFY_ID" ] && [ -z "$search_query" ]; then
    error "Input tidak boleh kosong!"; exit 1
fi

info "Mengambil data Spotify ..."
echo ""

# Ambil token publik Spotify
TOKEN=$(curl -s "https://open.spotify.com/get_access_token?reason=transport&productType=web_player" \
    -H "User-Agent: Mozilla/5.0" | jq -r '.accessToken')

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
    error "Gagal mendapatkan token Spotify!"
    warn "Coba lagi atau cek koneksi internet."
    exit 1
fi

if [ "$TYPE" == "search" ]; then
    QUERY_ENC=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$search_query'))")
    DATA=$(curl -s "https://api.spotify.com/v1/search?q=$QUERY_ENC&type=artist,user&limit=5" \
        -H "Authorization: Bearer $TOKEN")
    
    echo -e "${CYAN}╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮${RESET}"
    echo -e "${CYAN}┃${RESET}   ${BOLD}Hasil Pencarian Spotify${RESET}      ${CYAN}┃${RESET}"
    echo -e "${CYAN}├━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┤${RESET}"
    
    echo "$DATA" | jq -r '.artists.items[] | "Artist: \(.name)\nFollowers: \(.followers.total)\nGenre: \(.genres[0]//\"N/A\")\nPopularitas: \(.popularity)/100\nID: \(.id)\n---"' 2>/dev/null
    
elif [ "$TYPE" == "artist" ]; then
    DATA=$(curl -s "https://api.spotify.com/v1/artists/$SPOTIFY_ID" \
        -H "Authorization: Bearer $TOKEN")
    
    NAME=$(echo "$DATA" | jq -r '.name')
    FOLLOWERS=$(echo "$DATA" | jq -r '.followers.total')
    GENRES=$(echo "$DATA" | jq -r '.genres | join(", ")')
    POPULARITY=$(echo "$DATA" | jq -r '.popularity')
    IMAGES=$(echo "$DATA" | jq -r '.images[0].url // "N/A"')
    
    echo -e "${CYAN}╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮${RESET}"
    echo -e "${CYAN}┃${RESET}   ${BOLD}Profil Artist Spotify${RESET}        ${CYAN}┃${RESET}"
    echo -e "${CYAN}├━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┤${RESET}"
    echo -e "${CYAN}┃${RESET} Nama       : ${GREEN}$NAME${RESET}"
    echo -e "${CYAN}┃${RESET} Followers  : ${YELLOW}$FOLLOWERS${RESET}"
    echo -e "${CYAN}┃${RESET} Genre      : $GENRES"
    echo -e "${CYAN}┃${RESET} Popularitas: $POPULARITY/100"
    echo -e "${CYAN}┃${RESET} Foto       : $IMAGES"
    echo -e "${CYAN}┃${RESET} URL        : https://open.spotify.com/artist/$SPOTIFY_ID"
    echo -e "${CYAN}╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯${RESET}"
    success "Data berhasil diambil!"

elif [ "$TYPE" == "user" ]; then
    DATA=$(curl -s "https://api.spotify.com/v1/users/$SPOTIFY_ID" \
        -H "Authorization: Bearer $TOKEN")
    
    NAME=$(echo "$DATA" | jq -r '.display_name')
    FOLLOWERS=$(echo "$DATA" | jq -r '.followers.total')
    IMAGES=$(echo "$DATA" | jq -r '.images[0].url // "N/A"')
    
    echo -e "${CYAN}╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮${RESET}"
    echo -e "${CYAN}┃${RESET}   ${BOLD}Profil User Spotify${RESET}          ${CYAN}┃${RESET}"
    echo -e "${CYAN}├━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┤${RESET}"
    echo -e "${CYAN}┃${RESET} Nama      : ${GREEN}$NAME${RESET}"
    echo -e "${CYAN}┃${RESET} Followers : ${YELLOW}$FOLLOWERS${RESET}"
    echo -e "${CYAN}┃${RESET} Foto      : $IMAGES"
    echo -e "${CYAN}┃${RESET} URL       : https://open.spotify.com/user/$SPOTIFY_ID"
    echo -e "${CYAN}╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯${RESET}"
    success "Data berhasil diambil!"
fi
