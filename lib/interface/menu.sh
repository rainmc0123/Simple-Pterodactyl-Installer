#!/bin/bash

show_install_menu() {
    if [[ -n "$ARG_INSTALL_MODE" ]]; then
        case "$ARG_INSTALL_MODE" in
            panel|Panel|PANEL|1)
                INSTALL_MODE="panel"
                ;;
            wings|Wings|WINGS|2)
                INSTALL_MODE="wings"
                ;;
            both|Both|BOTH|3)
                INSTALL_MODE="both"
                ;;
            uninstall|Uninstall|UNINSTALL|4)
                INSTALL_MODE="uninstall"
                ;;
            *)
                log_error "Mode instalasi tidak valid: $ARG_INSTALL_MODE"
                log_info "Opsi yang valid: panel, wings, both, uninstall"
                exit 1
                ;;
        esac
        log_info "Mode instalasi dari command line: $INSTALL_MODE"
        set_total_steps
        return
    fi
    
    echo ""
    echo -e "    ${NEON_CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}              ${STYLE_BOLD}${WHITE}⚡ SELECT INSTALLATION MODE ⚡${NC}"
    echo -e "    ${NEON_CYAN}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}   ${NEON_GREEN}[1]${NC} ${WHITE}Panel Only${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}       ${DIM}Web interface + Database + SSL${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}   ${NEON_BLUE}[2]${NC} ${WHITE}Wings Only${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}       ${DIM}Docker + Wings daemon + SSL${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}   ${NEON_PURPLE}[3]${NC} ${WHITE}Full Stack (Panel + Wings)${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}       ${DIM}Complete installation on single server${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}   ${NEON_ORANGE}[4]${NC} ${WHITE}Uninstall${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}       ${DIM}Remove Pterodactyl components${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}   ${RED}[0]${NC} ${DIM}Exit${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}"
    echo -e "    ${NEON_CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    while true; do
        echo -ne "    ${NEON_CYAN}▸${NC} ${WHITE}Enter option${NC} ${DIM}[0-4]${NC}: "
        read -r choice
        case $choice in
            1)
                INSTALL_MODE="panel"
                break
                ;;
            2)
                INSTALL_MODE="wings"
                break
                ;;
            3)
                INSTALL_MODE="both"
                break
                ;;
            4)
                INSTALL_MODE="uninstall"
                break
                ;;
            0)
                echo ""
                echo -e "    ${DIM}[SYSTEM] Terminating...${NC}"
                exit 0
                ;;
            *)
                echo -e "    ${RED}✗${NC} ${DIM}Invalid option. Try again.${NC}"
                ;;
        esac
    done
    
    set_total_steps
    
    echo ""
    case $INSTALL_MODE in
        panel)
            echo -e "    ${NEON_GREEN}▸${NC} ${WHITE}Mode:${NC} ${NEON_GREEN}Panel Installation${NC}"
            ;;
        wings)
            echo -e "    ${NEON_BLUE}▸${NC} ${WHITE}Mode:${NC} ${NEON_BLUE}Wings Installation${NC}"
            ;;
        both)
            echo -e "    ${NEON_PURPLE}▸${NC} ${WHITE}Mode:${NC} ${NEON_PURPLE}Full Stack Installation${NC}"
            ;;
        uninstall)
            echo -e "    ${NEON_ORANGE}▸${NC} ${WHITE}Mode:${NC} ${NEON_ORANGE}Uninstall${NC}"
            ;;
    esac
    echo ""
    sleep 0.5
    
    return 0
}

set_total_steps() {
    case $INSTALL_MODE in
        panel)
            TOTAL_STEPS=15
            ;;
        wings)
            TOTAL_STEPS=8
            ;;
        both)
            TOTAL_STEPS=22
            ;;
        uninstall)
            TOTAL_STEPS=5
            ;;
    esac
    
    return 0
}

show_uninstall_menu() {
    echo ""
    echo -e "    ${RED}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${RED}┃${NC}                    ${STYLE_BOLD}${WHITE}⚠ UNINSTALL MODE ⚠${NC}"
    echo -e "    ${RED}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${RED}┃${NC}"
    echo -e "    ${RED}┃${NC}   ${NEON_ORANGE}[1]${NC} ${WHITE}Panel Only${NC}"
    echo -e "    ${RED}┃${NC}       ${DIM}Remove Panel, database, and web config${NC}"
    echo -e "    ${RED}┃${NC}"
    echo -e "    ${RED}┃${NC}   ${NEON_BLUE}[2]${NC} ${WHITE}Wings Only${NC}"
    echo -e "    ${RED}┃${NC}       ${DIM}Remove Wings daemon and config${NC}"
    echo -e "    ${RED}┃${NC}"
    echo -e "    ${RED}┃${NC}   ${NEON_PURPLE}[3]${NC} ${WHITE}Full Uninstall${NC}"
    echo -e "    ${RED}┃${NC}       ${DIM}Remove all Pterodactyl components${NC}"
    echo -e "    ${RED}┃${NC}"
    echo -e "    ${RED}┃${NC}   ${NEON_GREEN}[0]${NC} ${DIM}Back${NC}"
    echo -e "    ${RED}┃${NC}"
    echo -e "    ${RED}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    while true; do
        echo -ne "    ${RED}▸${NC} ${WHITE}Enter option${NC} ${DIM}[0-3]${NC}: "
        read -r choice
        case $choice in
            1)
                UNINSTALL_MODE="panel"
                break
                ;;
            2)
                UNINSTALL_MODE="wings"
                break
                ;;
            3)
                UNINSTALL_MODE="both"
                break
                ;;
            0)
                echo ""
                echo -e "    ${DIM}[SYSTEM] Returning to main menu...${NC}"
                exec "$0"
                ;;
            *)
                echo -e "    ${RED}✗${NC} ${DIM}Invalid option.${NC}"
                ;;
        esac
    done
    
    return 0
}

confirm_action() {
    local message="$1"
    
    if [[ "$UNATTENDED" == "true" ]]; then
        log_info "Auto-confirmed: $message"
        return 0
    fi
    
    echo ""
    echo -e "    ${NEON_ORANGE}⚠${NC} ${WHITE}$message${NC}"
    echo -ne "    ${DIM}Continue?${NC} ${WHITE}[y/N]${NC}: "
    read -r -n 1
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "    ${RED}✗${NC} ${DIM}Operation cancelled.${NC}"
        exit 1
    fi
    
    return 0
}
