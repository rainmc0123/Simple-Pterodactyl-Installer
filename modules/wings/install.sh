#!/bin/bash

install_wings() {
    print_section "Menginstall Wings"
    
    prepare_wings_directory
    download_wings_binary
    setup_wings_service
    
    log_info "Catatan: Wings harus dikonfigurasi dari Panel sebelum dijalankan"
    
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
