#!/bin/bash

setup_ssl() {
    print_section "Menyiapkan Sertifikat SSL"
    
    obtain_pterodactyl_ssl
    
    return 0
}

obtain_pterodactyl_ssl() {
    log_info "Mendapatkan sertifikat SSL dari Let's Encrypt..."
    
    certbot --nginx -d "$FQDN" --non-interactive --agree-tos --email "$ADMIN_EMAIL" --redirect >> "$LOG_FILE" 2>&1
    
    if [[ $? -eq 0 ]]; then
        log_success "Sertifikat SSL berhasil didapatkan dan dikonfigurasi"
        create_ssl_nginx_config
    else
        log_warning "Gagal mendapatkan sertifikat SSL. Panel akan berjalan dengan HTTP saja."
        log_info "Anda dapat mencoba lagi nanti dengan: certbot --nginx -d $FQDN"
    fi
    
    return 0
}

renew_pterodactyl_ssl() {
    log_info "Memperbarui sertifikat SSL..."
    
    certbot renew >> "$LOG_FILE" 2>&1
    
    if [[ $? -eq 0 ]]; then
        log_success "Sertifikat SSL berhasil diperbarui"
        reload_service "nginx"
    else
        log_error "Gagal memperbarui sertifikat SSL"
    fi
    
    return $?
}

verify_ssl_setup() {
    if check_ssl_certificate_exists "$FQDN"; then
        log_success "Sertifikat SSL ditemukan untuk $FQDN"
        return 0
    fi
    
    log_warning "Sertifikat SSL tidak ditemukan"
    return 1
}

get_ssl_status() {
    if check_ssl_certificate_exists "$FQDN"; then
        local expiry
        expiry=$(get_ssl_certificate_expiry "$FQDN")
        echo "active (expires: $expiry)"
    else
        echo "not_configured"
    fi
}

remove_pterodactyl_ssl() {
    if check_ssl_certificate_exists "$FQDN"; then
        delete_ssl_certificate "$FQDN"
        log_info "Sertifikat SSL dihapus"
    fi
    
    return 0
}
