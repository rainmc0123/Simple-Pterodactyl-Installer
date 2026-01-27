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
    
    # Verify certbot is installed
    if ! command -v certbot &> /dev/null; then
        log_error "Certbot tidak terinstall! Menginstall ulang..."
        apt-get update >> "$LOG_FILE" 2>&1
        apt-get install -y certbot >> "$LOG_FILE" 2>&1
        
        if ! command -v certbot &> /dev/null; then
            log_error "Gagal menginstall certbot"
            WINGS_USE_SSL=false
            return 1
        fi
    fi
    
    # Check if certificate already exists (might be same as panel domain)
    if check_ssl_certificate_exists "$wings_domain"; then
        log_success "Sertifikat SSL sudah ada untuk $wings_domain"
        WINGS_USE_SSL=true
        return 0
    fi
    
    # Stop nginx if running (required for standalone mode)
    local nginx_was_running=false
    if systemctl is-active --quiet nginx 2>/dev/null; then
        nginx_was_running=true
        log_info "Menghentikan Nginx sementara untuk SSL standalone..."
        systemctl stop nginx >> "$LOG_FILE" 2>&1
        sleep 2
    fi
    
    # Also check if any other process is using port 80
    if ss -tlnp 2>/dev/null | grep -q ':80 '; then
        log_warning "Port 80 masih digunakan oleh proses lain"
        # Try to kill whatever is on port 80
        fuser -k 80/tcp >> "$LOG_FILE" 2>&1 || true
        sleep 3
    fi
    
    # Double-check port 80 is free
    local max_wait=10
    local waited=0
    while ss -tlnp 2>/dev/null | grep -q ':80 ' && [[ $waited -lt $max_wait ]]; do
        sleep 1
        ((waited++))
    done
    
    # Get certificate using standalone mode with retry
    local cert_result=1
    local max_retries=2
    local retry=0
    
    while [[ $retry -lt $max_retries ]] && [[ $cert_result -ne 0 ]]; do
        log_info "Menjalankan certbot standalone (attempt $((retry+1))/$max_retries)..."
        
        certbot certonly --standalone \
            -d "$wings_domain" \
            --non-interactive \
            --agree-tos \
            --email "$email" \
            --no-eff-email \
            --force-renewal \
            >> "$LOG_FILE" 2>&1
        
        cert_result=$?
        
        if [[ $cert_result -ne 0 ]]; then
            log_warning "Certbot attempt $((retry+1)) gagal, mencoba lagi..."
            sleep 3
        fi
        
        ((retry++))
    done
    
    # Restart nginx if it was running
    if [[ "$nginx_was_running" == "true" ]]; then
        log_info "Memulai kembali Nginx..."
        systemctl start nginx >> "$LOG_FILE" 2>&1 || true
    fi
    
    if [[ $cert_result -eq 0 ]] && check_ssl_certificate_exists "$wings_domain"; then
        log_success "Sertifikat SSL untuk Wings berhasil didapatkan"
        log_info "Lokasi sertifikat:"
        log_info "  - Certificate: /etc/letsencrypt/live/$wings_domain/fullchain.pem"
        log_info "  - Private Key: /etc/letsencrypt/live/$wings_domain/privkey.pem"
        WINGS_USE_SSL=true
    else
        log_error "Gagal mendapatkan sertifikat SSL untuk Wings"
        log_info "Cek error detail dengan: cat $LOG_FILE | grep -i 'certbot\|error' | tail -20"
        log_info "Pastikan domain $wings_domain sudah pointing ke IP server ini"
        log_info ""
        log_info "Anda dapat mencoba manual dengan:"
        log_info "  1. systemctl stop nginx (jika ada)"
        log_info "  2. certbot certonly --standalone -d $wings_domain"
        log_info "  3. systemctl start nginx"
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
