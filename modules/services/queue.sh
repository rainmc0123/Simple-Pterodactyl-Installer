#!/bin/bash

setup_queue_worker() {
    print_section "Menyiapkan Queue Worker"
    
    create_queue_service
    enable_queue_service
    
    log_success "Queue worker dikonfigurasi dan dijalankan"
    
    return 0
}

create_queue_service() {
    log_info "Membuat service queue worker..."
    
    cat > /etc/systemd/system/pteroq.service <<QUEUE_SERVICE
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service

[Service]
User=www-data
Group=www-data
Restart=always
ExecStart=/usr/bin/php ${PANEL_PATH}/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
QUEUE_SERVICE

    return 0
}

enable_queue_service() {
    log_info "Mengaktifkan service queue worker..."
    
    reload_systemd
    enable_service "pteroq.service"
    start_service "pteroq.service"
    
    return 0
}

restart_queue_worker() {
    restart_service "pteroq"
    
    return $?
}

stop_queue_worker() {
    stop_service "pteroq"
    
    return $?
}

verify_queue_worker() {
    if is_service_active "pteroq"; then
        log_success "Queue worker berjalan"
        return 0
    fi
    
    log_error "Queue worker tidak berjalan"
    return 1
}

clear_failed_jobs() {
    cd "$PANEL_PATH" || return 1
    
    php artisan queue:flush >> "$LOG_FILE" 2>&1
    
    return $?
}

retry_failed_jobs() {
    cd "$PANEL_PATH" || return 1
    
    php artisan queue:retry all >> "$LOG_FILE" 2>&1
    
    return $?
}

get_queue_status() {
    cd "$PANEL_PATH" || return 1
    
    php artisan queue:work --once --no-interaction 2>/dev/null
}

remove_queue_service() {
    stop_service "pteroq"
    disable_service "pteroq"
    rm -f /etc/systemd/system/pteroq.service
    reload_systemd
    
    return 0
}
