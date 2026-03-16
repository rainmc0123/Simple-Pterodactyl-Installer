#!/bin/bash

print_banner() {
    clear
    
    # Futuristic boot sequence effect
    echo -e "${DIM}"
    echo "    [SYSTEM] Initializing Pterodactyl Installer..."
    sleep 0.1
    echo "    [SYSTEM] Loading modules..."
    sleep 0.1
    echo "    [SYSTEM] Boot sequence complete."
    sleep 0.2
    echo -e "${NC}"
    clear
    
    # Main banner with PTERODACTYL text
    echo ""
    echo -e "    ${NEON_CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}          ${NEON_ORANGE}╔═╗╔╦╗╔═╗╦═╗╔═╗╔╦╗╔═╗╔═╗╔╦╗╦ ╦╦  ${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}          ${NEON_ORANGE}╠═╝ ║ ║╣ ╠╦╝║ ║ ║║╠═╣║   ║ ╚╦╝║  ${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}          ${NEON_ORANGE}╩   ╩ ╚═╝╩╚═╚═╝═╩╝╩ ╩╚═╝ ╩  ╩ ╩═╝${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}            ${STYLE_BOLD}${WHITE}⚡ AUTOMATED PANEL INSTALLER ⚡${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}"
    echo -e "    ${NEON_CYAN}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}  ${DIM}Version${NC} ${WHITE}${INSTALLER_VERSION:-1.0.3}${NC}  ${DIM}│${NC}  ${DIM}© 2025${NC} ${NEON_PINK}ClouviaID${NC}"
    echo -e "    ${NEON_CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # System info bar
    local ip_addr=$(get_public_ip 2>/dev/null || echo "N/A")
    local os_info=$(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME" || echo "Linux")
    
    echo -e "    ${DIM}┌━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${DIM}│${NC}  ${NEON_GREEN}▸${NC} ${DIM}System:${NC} ${WHITE}${os_info}${NC}"
    echo -e "    ${DIM}│${NC}  ${NEON_CYAN}▸${NC} ${DIM}IP:${NC} ${NEON_CYAN}${ip_addr}${NC}"
    echo -e "    ${DIM}│${NC}  ${NEON_ORANGE}▸${NC} ${DIM}Community:${NC} ${NEON_CYAN}https://chat.whatsapp.com/I9TD1kQM9kKAeFVzzChysJ${NC}"
    echo -e "    ${DIM}└━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    return 0
}

print_mini_banner() {
    echo ""
    echo -e "    ${NEON_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${NEON_ORANGE}⚡${NC} ${WHITE}PTERODACTYL INSTALLER${NC} ${DIM}v${INSTALLER_VERSION:-1.0.3}${NC}"
    echo -e "    ${NEON_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    return 0
}

print_section_header() {
    local title="$1"
    local icon="${2:-▸}"
    
    echo ""
    echo -e "    ${NEON_CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}  ${NEON_BLUE}${icon}${NC} ${STYLE_BOLD}${WHITE}${title}${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}"
    echo ""
    
    return 0
}

print_box() {
    local content="$1"
    local color="${2:-$NEON_CYAN}"
    
    echo -e "    ${color}╭━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╮${NC}"
    echo -e "    ${color}│${NC} ${content}"
    echo -e "    ${color}╰━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╯${NC}"
    
    return 0
}

print_divider() {
    local style="${1:-single}"
    
    case "$style" in
        double)
            echo -e "    ${NEON_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            ;;
        dim)
            echo -e "    ${DIM}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            ;;
        *)
            echo -e "    ${NEON_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            ;;
    esac
    
    return 0
}

print_footer() {
    echo ""
    echo -e "    ${NEON_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${DIM}Powered by${NC} ${NEON_PINK}ClouviaID${NC}"
    echo -e "    ${NEON_ORANGE}▸${NC} ${DIM}Community:${NC} ${NEON_CYAN}https://chat.whatsapp.com/I9TD1kQM9kKAeFVzzChysJ${NC}"
    echo -e "    ${NEON_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    return 0
}
