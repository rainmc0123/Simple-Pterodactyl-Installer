#!/bin/bash

install_wings() {
    print_section "Menginstall Wings"
    
    prepare_wings_directory
    download_wings_binary
    setup_wings_service
    
    # Wait for user to configure Wings from Panel
    wait_for_wings_config
    
    # Validate and start Wings
    validate_and_start_wings
    
    return 0
}

wait_for_wings_config() {
    echo ""
    echo -e "    ${NEON_CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}  ${NEON_ORANGE}⚡${NC} ${STYLE_BOLD}${WHITE}KONFIGURASI WINGS${NC}"
    echo -e "    ${NEON_CYAN}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}  ${WHITE}Sekarang Anda perlu mengkonfigurasi Wings dari Panel:${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}  ${NEON_GREEN}1.${NC} Login ke Panel sebagai Admin"
    echo -e "    ${NEON_CYAN}┃${NC}  ${NEON_GREEN}2.${NC} Pergi ke ${WHITE}Admin → Locations${NC} → Buat lokasi baru"
    echo -e "    ${NEON_CYAN}┃${NC}  ${NEON_GREEN}3.${NC} Pergi ke ${WHITE}Admin → Nodes${NC} → Buat node baru"
    echo -e "    ${NEON_CYAN}┃${NC}  ${NEON_GREEN}4.${NC} Klik node → Tab ${WHITE}Configuration${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}  ${NEON_GREEN}5.${NC} Copy konfigurasi ke ${WHITE}/etc/pterodactyl/config.yml${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}  ${DIM}Atau gunakan Auto-Deploy token dari Panel${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}"
    echo -e "    ${NEON_CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Wait for user to configure
    while true; do
        echo -ne "    ${NEON_CYAN}▸${NC} ${WHITE}Tekan Enter setelah selesai konfigurasi...${NC} "
        read -r
        
        # Check if config.yml exists and is valid
        if [[ -f "/etc/pterodactyl/config.yml" ]]; then
            local config_size=$(stat -c%s "/etc/pterodactyl/config.yml" 2>/dev/null || echo "0")
            if [[ "$config_size" -gt 100 ]]; then
                echo -e "    ${NEON_GREEN}✓${NC} ${WHITE}Konfigurasi Wings ditemukan${NC}"
                break
            fi
        fi
        
        echo -e "    ${RED}✗${NC} ${DIM}File /etc/pterodactyl/config.yml belum ada atau kosong${NC}"
        echo -e "    ${DIM}   Pastikan Anda sudah menyalin konfigurasi dari Panel${NC}"
        echo ""
    done
    
    return 0
}

validate_and_start_wings() {
    echo ""
    log_info "Menguji konfigurasi Wings..."
    
    # Always stop nginx first before any SSL operation
    local nginx_was_running=false
    if systemctl is-active --quiet nginx 2>/dev/null; then
        nginx_was_running=true
        log_info "Menghentikan Nginx sementara..."
        systemctl stop nginx >> "$LOG_FILE" 2>&1
        sleep 2
    fi
    
    # Test run wings and capture output
    local wings_output
    local wings_exit_code
    
    log_info "Menjalankan wings untuk validasi..."
    
    # Run wings in background and capture output
    timeout 15 wings 2>&1 | tee /tmp/wings_test_output.txt &
    local wings_pid=$!
    
    sleep 8
    
    # Kill the test process
    kill $wings_pid 2>/dev/null || true
    wait $wings_pid 2>/dev/null || true
    
    wings_output=$(cat /tmp/wings_test_output.txt 2>/dev/null)
    
    # Check for SSL certificate error
    if echo "$wings_output" | grep -q "no such file or directory" && echo "$wings_output" | grep -q "letsencrypt"; then
        log_warning "SSL certificate tidak ditemukan, mencoba auto-fix..."
        
        # Extract domain from config.yml
        local wings_domain
        wings_domain=$(grep -oP '(?<=host: ).*' /etc/pterodactyl/config.yml 2>/dev/null | head -1 | tr -d ' ')
        
        if [[ -z "$wings_domain" ]]; then
            # Try another pattern
            wings_domain=$(grep -A5 'api:' /etc/pterodactyl/config.yml 2>/dev/null | grep 'host:' | awk '{print $2}' | tr -d ' ')
        fi
        
        if [[ -z "$wings_domain" ]]; then
            wings_domain="$WINGS_FQDN"
        fi
        
        if [[ -n "$wings_domain" ]]; then
            auto_fix_wings_ssl "$wings_domain"
        else
            log_error "Tidak dapat mendeteksi domain Wings dari config"
            log_info "Jalankan manual: certbot certonly --standalone -d YOUR_DOMAIN"
        fi
    elif echo "$wings_output" | grep -qi "error\|fatal"; then
        log_error "Wings mengalami error:"
        echo "$wings_output" | grep -i "error\|fatal" | head -5
    else
        log_success "Wings berjalan tanpa error"
    fi
    
    # Restart nginx if it was running
    if [[ "$nginx_was_running" == "true" ]]; then
        log_info "Memulai kembali Nginx..."
        systemctl start nginx >> "$LOG_FILE" 2>&1 || true
    fi
    
    # Now start wings service
    log_info "Memulai service Wings..."
    systemctl start wings >> "$LOG_FILE" 2>&1
    
    sleep 3
    
    if systemctl is-active --quiet wings; then
        log_success "Wings berhasil dijalankan!"
    else
        log_warning "Wings mungkin memerlukan konfigurasi tambahan"
        log_info "Cek status: systemctl status wings"
        log_info "Cek log: journalctl -u wings -f"
    fi
    
    # Cleanup
    rm -f /tmp/wings_test_output.txt
    
    return 0
}

auto_fix_wings_ssl() {
    local domain="$1"
    local email="${ADMIN_EMAIL:-admin@$domain}"
    
    echo ""
    log_info "Auto-fixing SSL untuk domain: $domain"
    
    # Make sure port 80 is free
    if ss -tlnp 2>/dev/null | grep -q ':80 '; then
        log_info "Membebaskan port 80..."
        fuser -k 80/tcp >> "$LOG_FILE" 2>&1 || true
        sleep 2
    fi
    
    # Run certbot standalone
    log_info "Menjalankan certbot standalone..."
    certbot certonly --standalone \
        -d "$domain" \
        --non-interactive \
        --agree-tos \
        --email "$email" \
        --no-eff-email \
        >> "$LOG_FILE" 2>&1
    
    if [[ -f "/etc/letsencrypt/live/$domain/fullchain.pem" ]]; then
        log_success "SSL certificate berhasil didapatkan untuk $domain"
    else
        log_error "Gagal mendapatkan SSL certificate"
        log_info "Pastikan domain $domain sudah pointing ke IP server ini"
        log_info "Coba manual: certbot certonly --standalone -d $domain"
    fi
    
    return 0
}

prepare_wings_directory() {
    mkdir -p "$WINGS_CONFIG_PATH"
    
    return 0
}

download_wings_binary() {
    local arch="amd64"
    
    if [[ "$(uname -m)" != "x86_64" ]]; then
        arch="arm64"
    fi
    
    run_with_spinner "Mengunduh binary Wings ($arch)" "curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_${arch}"
    
    chmod u+x /usr/local/bin/wings
    
    log_success "Wings berhasil diunduh"
    
    return 0
}

setup_wings_service() {
    echo -e "${CYAN}  ►${NC} Membuat service Wings..."
    
    create_wings_systemd_service
    
    reload_systemd
    enable_service "wings"
    
    log_success "Service Wings berhasil dibuat"
    
    return 0
}

create_wings_systemd_service() {
    cat > /etc/systemd/system/wings.service <<SERVICE_EOF
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service
PartOf=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
SERVICE_EOF

    return 0
}

start_wings() {
    start_service "wings"
    
    return $?
}

stop_wings() {
    stop_service "wings"
    
    return $?
}

restart_wings() {
    restart_service "wings"
    
    return $?
}

get_wings_version() {
    wings --version 2>/dev/null || echo "unknown"
}

verify_wings_binary() {
    if [[ -x "/usr/local/bin/wings" ]]; then
        log_success "Binary Wings terinstall"
        return 0
    fi
    
    log_error "Binary Wings tidak ditemukan"
    return 1
}

remove_wings() {
    stop_wings
    disable_service "wings"
    
    rm -f /etc/systemd/system/wings.service
    rm -f /usr/local/bin/wings
    rm -rf "$WINGS_CONFIG_PATH"
    
    reload_systemd
    
    return 0
}
