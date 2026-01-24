#!/bin/bash

uninstall_wings() {
    print_section "Menghapus Pterodactyl Wings"
    
    show_wings_uninstall_warning
    ask_docker_cleanup
    confirm_wings_uninstall
    
    perform_wings_uninstall
    
    log_success "Wings berhasil dihapus!"
    
    return 0
}

show_wings_uninstall_warning() {
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ⚠️  PERINGATAN: Ini akan menghapus Wings dan semua server containers!     ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    return 0
}

ask_docker_cleanup() {
    read -p "Hapus juga semua Docker containers? (y/n): " docker_choice
    export CLEANUP_DOCKER_CONTAINERS="$docker_choice"
    
    return 0
}

confirm_wings_uninstall() {
    echo ""
    echo -e "${RED}Ketik 'HAPUS' untuk konfirmasi penghapusan:${NC}"
    read -p "> " confirm
    
    if [[ "$confirm" != "HAPUS" ]]; then
        log_error "Konfirmasi tidak cocok. Uninstall dibatalkan."
        exit 1
    fi
    
    return 0
}

perform_wings_uninstall() {
    log_info "Menghentikan Wings..."
    stop_service "wings" 2>/dev/null || true
    disable_service "wings" 2>/dev/null || true
    rm -f /etc/systemd/system/wings.service
    
    log_info "Menghapus binary Wings..."
    rm -f /usr/local/bin/wings
    
    log_info "Menghapus konfigurasi Wings..."
    rm -rf "$WINGS_CONFIG_PATH"
    
    if [[ "${CLEANUP_DOCKER_CONTAINERS:-n}" =~ ^[Yy]$ ]]; then
        cleanup_docker_resources
    fi
    
    log_info "Menghapus data server..."
    rm -rf /var/lib/pterodactyl
    
    return 0
}

cleanup_docker_resources() {
    log_info "Menghapus Docker containers..."
    docker_stop_all
    docker_remove_all_containers
    
    read -p "Hapus juga Docker images? (y/n): " images_choice
    if [[ "$images_choice" =~ ^[Yy]$ ]]; then
        log_info "Menghapus Docker images..."
        docker_remove_all_images
    fi
    
    read -p "Hapus juga Docker volumes? (y/n): " volumes_choice
    if [[ "$volumes_choice" =~ ^[Yy]$ ]]; then
        log_info "Menghapus Docker volumes..."
        docker_volume_prune
    fi
    
    return 0
}

run_uninstall() {
    print_banner
    show_uninstall_menu
    
    case $UNINSTALL_MODE in
        panel)
            uninstall_panel
            ;;
        wings)
            uninstall_wings
            ;;
        both)
            uninstall_panel
            uninstall_wings
            ;;
    esac
    
    print_uninstall_complete
    
    exit 0
}

cleanup_wings_remnants() {
    rm -f /usr/local/bin/wings
    rm -rf /etc/pterodactyl
    rm -f /etc/systemd/system/wings.service
    rm -rf /var/lib/pterodactyl
    
    return 0
}
