#!/bin/bash

configure_wings() {
    log_info "Konfigurasi Wings..."
    
    return 0
}

check_wings_config() {
    local config_file="${WINGS_CONFIG_PATH}/config.yml"
    
    [[ -f "$config_file" ]]
}

validate_wings_config() {
    if ! check_wings_config; then
        log_warning "File konfigurasi Wings tidak ditemukan"
        log_info "Harap konfigurasi Wings dari Panel"
        return 1
    fi
    
    return 0
}

get_wings_config_token() {
    local config_file="${WINGS_CONFIG_PATH}/config.yml"
    
    if [[ -f "$config_file" ]]; then
        grep "^token:" "$config_file" 2>/dev/null | awk '{print $2}'
    fi
}

verify_wings_service() {
    if is_service_active "wings"; then
        log_success "Wings daemon berjalan"
        return 0
    fi
    
    log_error "Wings daemon tidak berjalan"
    return 1
}

wings_debug_mode() {
    local action="${1:-start}"
    
    case "$action" in
        start)
            stop_wings
            /usr/local/bin/wings --debug
            ;;
        stop)
            start_wings
            ;;
    esac
    
    return 0
}

get_wings_status() {
    if is_service_active "wings"; then
        echo "running"
    elif check_wings_config; then
        echo "configured"
    else
        echo "not_configured"
    fi
}

wings_health_check() {
    local wings_port="${1:-8080}"
    
    if check_port_open "127.0.0.1" "$wings_port" 5; then
        return 0
    fi
    
    return 1
}
