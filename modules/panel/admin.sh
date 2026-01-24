#!/bin/bash

check_existing_installation() {
    print_section "Memeriksa Instalasi yang Ada"
    
    if [[ -d "$PANEL_PATH" ]]; then
        log_warning "Instalasi Pterodactyl yang ada terdeteksi di $PANEL_PATH"
        confirm_action "Melanjutkan akan menimpa instalasi yang ada!"
        
        backup_existing_env
    else
        log_success "Tidak ada instalasi sebelumnya"
    fi
    
    return 0
}

backup_existing_env() {
    if [[ -f "$PANEL_PATH/.env" ]]; then
        log_info "Membuat backup file .env yang ada..."
        cp "$PANEL_PATH/.env" "$PANEL_PATH/.env.backup.$(date +%Y%m%d%H%M%S)"
    fi
    
    return 0
}

verify_panel_installation() {
    local errors=0
    
    if [[ -f "$PANEL_PATH/.env" ]] && [[ -f "$PANEL_PATH/artisan" ]]; then
        log_success "File panel ada"
    else
        log_error "File panel tidak ditemukan"
        ((errors++))
    fi
    
    return $errors
}

panel_maintenance_mode() {
    local action="${1:-down}"
    
    cd "$PANEL_PATH" || return 1
    
    case "$action" in
        down)
            php artisan down >> "$LOG_FILE" 2>&1
            ;;
        up)
            php artisan up >> "$LOG_FILE" 2>&1
            ;;
    esac
    
    return $?
}

get_panel_status() {
    local status="unknown"
    
    if [[ -f "${PANEL_PATH}/storage/framework/down" ]]; then
        status="maintenance"
    elif [[ -f "${PANEL_PATH}/.env" ]]; then
        status="active"
    else
        status="not_installed"
    fi
    
    echo "$status"
}

test_panel_access() {
    local url="${APP_URL}/api/application/servers"
    
    local response
    response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
    
    [[ "$response" == "401" ]] || [[ "$response" == "403" ]]
}
