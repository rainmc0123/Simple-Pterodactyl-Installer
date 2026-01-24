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
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                    ${WHITE}PILIH TIPE INSTALASI${NC}                                ${CYAN}║${NC}"
    echo -e "${CYAN}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${GREEN}[1]${NC} ${WHITE}Install Panel Saja${NC}                                             ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}       └─ Web interface untuk mengelola game server                       ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}       └─ Menginstall: PHP, MariaDB, Redis, Nginx, Certbot                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${GREEN}[2]${NC} ${WHITE}Install Wings Saja${NC}                                             ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}       └─ Daemon untuk menjalankan game server (install di node server)   ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}       └─ Menginstall: Docker, Wings binary                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${GREEN}[3]${NC} ${WHITE}Install Keduanya (Panel + Wings)${NC}                               ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}       └─ Instalasi lengkap di satu server                                ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}       └─ Cocok untuk testing atau setup kecil                            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${YELLOW}[4]${NC} ${WHITE}Uninstall Pterodactyl${NC}                                         ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}       └─ Hapus Panel dan/atau Wings dari server                          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}       └─ Opsi untuk backup database sebelum menghapus                    ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}   ${RED}[0]${NC} ${WHITE}Keluar${NC}                                                          ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}                                                                           ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    while true; do
        read -p "Pilih opsi [0-4]: " choice
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
                echo -e "${YELLOW}Instalasi dibatalkan.${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Opsi tidak valid. Silakan pilih 0-4.${NC}"
                ;;
        esac
    done
    
    set_total_steps
    
    echo ""
    case $INSTALL_MODE in
        panel)
            echo -e "${GREEN}► Menginstall Panel Saja${NC}"
            ;;
        wings)
            echo -e "${GREEN}► Menginstall Wings Saja${NC}"
            ;;
        both)
            echo -e "${GREEN}► Menginstall Panel + Wings${NC}"
            ;;
        uninstall)
            echo -e "${YELLOW}► Mode Uninstall${NC}"
            ;;
    esac
    echo ""
    sleep 1
    
    return 0
}

set_total_steps() {
    case $INSTALL_MODE in
        panel)
            TOTAL_STEPS=15
            ;;
        wings)
            TOTAL_STEPS=6
            ;;
        both)
            TOTAL_STEPS=20
            ;;
        uninstall)
            TOTAL_STEPS=5
            ;;
    esac
    
    return 0
}

show_uninstall_menu() {
    echo ""
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${NC}                    ${WHITE}UNINSTALL PTERODACTYL${NC}                                 ${RED}║${NC}"
    echo -e "${RED}╠═══════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${RED}║${NC}                                                                           ${RED}║${NC}"
    echo -e "${RED}║${NC}   ${YELLOW}[1]${NC} ${WHITE}Uninstall Panel Saja${NC}                                          ${RED}║${NC}"
    echo -e "${RED}║${NC}       └─ Hapus Panel, database, dan konfigurasi web                      ${RED}║${NC}"
    echo -e "${RED}║${NC}                                                                           ${RED}║${NC}"
    echo -e "${RED}║${NC}   ${YELLOW}[2]${NC} ${WHITE}Uninstall Wings Saja${NC}                                          ${RED}║${NC}"
    echo -e "${RED}║${NC}       └─ Hapus Wings daemon dan konfigurasi                              ${RED}║${NC}"
    echo -e "${RED}║${NC}                                                                           ${RED}║${NC}"
    echo -e "${RED}║${NC}   ${YELLOW}[3]${NC} ${WHITE}Uninstall Keduanya (Panel + Wings)${NC}                            ${RED}║${NC}"
    echo -e "${RED}║${NC}       └─ Hapus semua komponen Pterodactyl                                ${RED}║${NC}"
    echo -e "${RED}║${NC}                                                                           ${RED}║${NC}"
    echo -e "${RED}║${NC}   ${GREEN}[0]${NC} ${WHITE}Kembali${NC}                                                         ${RED}║${NC}"
    echo -e "${RED}║${NC}                                                                           ${RED}║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    while true; do
        read -p "Pilih opsi [0-3]: " choice
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
                echo -e "${YELLOW}Kembali ke menu utama...${NC}"
                exec "$0"
                ;;
            *)
                echo -e "${RED}Opsi tidak valid.${NC}"
                ;;
        esac
    done
    
    return 0
}

confirm_action() {
    local message="$1"
    
    if [[ "$UNATTENDED" == "true" ]]; then
        log_info "Konfirmasi otomatis: $message"
        return 0
    fi
    
    echo -e "${YELLOW}$message${NC}"
    read -p "Lanjutkan? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_error "Instalasi dibatalkan oleh pengguna."
        exit 1
    fi
    
    return 0
}
