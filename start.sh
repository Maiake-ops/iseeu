#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear

# Banner
echo -e "${CYAN}"
echo "██╗ ███████╗███████╗███████╗██╗   ██╗"
echo "██║ ██╔════╝██╔════╝██╔════╝╚██╗ ██╔╝"
echo "██║ ███████╗█████╗  █████╗   ╚████╔╝ "
echo "██║ ╚════██║██╔══╝  ██╔══╝    ╚██╔╝  "
echo "██║ ███████║███████╗███████╗   ██║   "
echo "╚═╝ ╚══════╝╚══════╝╚══════╝   ╚═╝   "
echo -e "${NC}"
echo -e "${GREEN}        ~ I-See-U Control Panel ~${NC}\n"

# Menu
echo -e "${CYAN}[1]${NC} Start I-See-U"
echo -e "${CYAN}[2]${NC} Start I-See-U for Termux"
echo -e "${CYAN}[3]${NC} Stop services and restart helper"
echo -e "${CYAN}[0]${NC} Exit"

read -rp $'\n> ' choice

case "$choice" in
  1)
    clear
    chmod +x Iseeu.sh
    bash Iseeu.sh
    ;;
  2)
    clear
    chmod +x Iseeu-termux.sh
    bash Iseeu-termux.sh
    ;;
  3)
    clear
    chmod +x kill-server.sh start.sh
    ./kill-server.sh
    exec ./start.sh
    ;;
  0)
    echo -e "${GREEN}Goodbye!${NC}"
    exit 0
    ;;
  *)
    echo -e "${RED}[!] Invalid option. Try again.${NC}"
    sleep 2
    exec "$0"
    ;;
esac
