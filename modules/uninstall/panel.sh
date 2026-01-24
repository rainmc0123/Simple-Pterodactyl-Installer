#!/bin/bash

uninstall_panel() {
    print_section "Menghapus Pterodactyl Panel"
    
    show_uninstall_warning
    ask_database_backup
    confirm_uninstall
    
    perform_panel_uninstall
    
    log_success "Panel berhasil dihapus!"
    
    return 0
}

show_uninstall_warning() {
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ⚠️  PERINGATAN: Ini akan menghapus Panel dan semua datanya!               ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    return 0
}

ask_database_backup() {
    read -p "Backup database sebelum menghapus? (y/n): " backup_choice
    
    if [[ "$backup_choice" =~ ^[Yy]$ ]]; then
        log_info "Membuat backup database..."
        local backup_file="/root/pterodactyl-backup-$(date +%Y%m%d%H%M%S).sql"
        
        if backup_database "$DB_NAME" "$backup_file" 2>/dev/null; then
            log_success "Database di-backup ke: $backup_file"
        else
            log_warning "Gagal membuat backup database (mungkin tidak ada)"
        fi
    fi
    
    return 0
}

confirm_uninstall() {
    echo ""
    echo -e "${RED}Ketik 'HAPUS' untuk konfirmasi penghapusan:${NC}"
    read -p "> " confirm
    
    if [[ "$confirm" != "HAPUS" ]]; then
        log_error "Konfirmasi tidak cocok. Uninstall dibatalkan."
        exit 1
    fi
    
    return 0
}

perform_panel_uninstall() {
    log_info "Menghentikan services..."
    stop_service "pteroq" 2>/dev/null || true
    disable_service "pteroq" 2>/dev/null || true
    rm -f /etc/systemd/system/pteroq.service
    
    log_info "Menghapus cron job..."
    remove_pterodactyl_cron
    
    log_info "Menghapus konfigurasi Nginx..."
    remove_pterodactyl_nginx_config
    
    log_info "Menghapus database..."
    drop_database "$DB_NAME" 2>/dev/null || true
    drop_database_user "$DB_USER" "$DB_HOST" 2>/dev/null || true
    
    log_info "Menghapus file Panel..."
    remove_panel_files
    
    log_info "Menghapus sertifikat SSL..."
    if [[ -n "$FQDN" ]]; then
        delete_ssl_certificate "$FQDN" 2>/dev/null || true
    fi
    
    log_info "Menghapus file kredensial..."
    rm -f "${CREDENTIALS_FILE:-/root/pterodactyl-credentials.txt}"
    
    return 0
}

cleanup_panel_remnants() {
    rm -rf /var/www/pterodactyl
    rm -f /etc/nginx/sites-enabled/pterodactyl.conf
    rm -f /etc/nginx/sites-available/pterodactyl.conf
    rm -f /etc/systemd/system/pteroq.service
    
    crontab -l 2>/dev/null | grep -v "pterodactyl" | crontab - 2>/dev/null || true
    
    return 0
}
