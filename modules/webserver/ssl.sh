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

setup_wings_ssl() {
    print_section "Menyiapkan Sertifikat SSL untuk Wings"
    
    local wings_domain="$WINGS_FQDN"
    local email="${ADMIN_EMAIL:-admin@$wings_domain}"
    
    log_info "Mendapatkan sertifikat SSL untuk Wings node: $wings_domain"
    
    # Check if certificate already exists (might be same as panel domain)
    if check_ssl_certificate_exists "$wings_domain"; then
        log_success "Sertifikat SSL sudah ada untuk $wings_domain"
        return 0
    fi
    
    # Use standalone mode since we don't have nginx configured for wings
    # Stop any service that might be using port 80
    local port_80_in_use=false
    if ss -tlnp | grep -q ':80 '; then
        port_80_in_use=true
        log_info "Port 80 sedang digunakan, mencoba menghentikan sementara..."
        systemctl stop nginx 2>/dev/null || true
    fi
    
    # Get certificate using standalone mode
    run_with_spinner "Mendapatkan sertifikat SSL untuk Wings" "certbot certonly --standalone -d $wings_domain --non-interactive --agree-tos --email $email"
    
    local cert_result=$?
    
    # Restart nginx if it was running
    if [[ "$port_80_in_use" == "true" ]]; then
        systemctl start nginx 2>/dev/null || true
    fi
    
    if [[ $cert_result -eq 0 ]]; then
        log_success "Sertifikat SSL untuk Wings berhasil didapatkan"
        log_info "Lokasi sertifikat:"
        log_info "  - Certificate: /etc/letsencrypt/live/$wings_domain/fullchain.pem"
        log_info "  - Private Key: /etc/letsencrypt/live/$wings_domain/privkey.pem"
    else
        log_warning "Gagal mendapatkan sertifikat SSL untuk Wings"
        log_info "Wings akan menggunakan auto_tls atau HTTP"
        log_info "Anda dapat mencoba lagi nanti dengan:"
        log_info "  certbot certonly --standalone -d $wings_domain"
        WINGS_USE_SSL=false
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
