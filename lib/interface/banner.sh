#!/bin/bash

print_banner() {
    clear
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                           ║"
    echo "║       ██████╗ ████████╗███████╗██████╗  ██████╗                            ║"
    echo "║       ██╔══██╗╚══██╔══╝██╔════╝██╔══██╗██╔═══██╗                           ║"
    echo "║       ██████╔╝   ██║   █████╗  ██████╔╝██║   ██║                           ║"
    echo "║       ██╔═══╝    ██║   ██╔══╝  ██╔══██╗██║   ██║                           ║"
    echo "║       ██║        ██║   ███████╗██║  ██║╚██████╔╝                           ║"
    echo "║       ╚═╝        ╚═╝   ╚══════╝╚═╝  ╚═╝ ╚═════╝                            ║"
    echo "║                                                                           ║"
    echo "║              PTERODACTYL PANEL AUTO INSTALLER                             ║"
    echo "║                      Versi ${INSTALLER_VERSION:-1.0.0}                                       ║"
    echo "║                                                                           ║"
    echo "║                       © 2026 ClouviaID                                    ║"
    echo "║                                                                           ║"
    echo "║           Email: s.rainstoreid@gmail.com                                  ║"
    echo "║           WhatsApp: https://chat.whatsapp.com/I9TD1kQM9kKAeFVzzChysJ      ║"
    echo "║                                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    return 0
}

print_mini_banner() {
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  PTERODACTYL INSTALLER v${INSTALLER_VERSION:-1.0.0}${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    return 0
}

print_section_header() {
    local title="$1"
    
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  ${WHITE}${title}${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    return 0
}

print_box() {
    local content="$1"
    local color="${2:-$CYAN}"
    
    echo -e "${color}┌───────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${color}│${NC} ${content}"
    echo -e "${color}└───────────────────────────────────────────────────────────────────────────┘${NC}"
    
    return 0
}

print_divider() {
    local char="${1:-─}"
    local color="${2:-$PURPLE}"
    local width="${3:-77}"
    
    local line=""
    for ((i=0; i<width; i++)); do
        line+="$char"
    done
    
    echo -e "${color}${line}${NC}"
    
    return 0
}

print_footer() {
    echo ""
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  ${INSTALLER_COPYRIGHT:-© 2024-2026 ClouviaID} - ${INSTALLER_WEBSITE:-https://clouvia.id}${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    return 0
}
