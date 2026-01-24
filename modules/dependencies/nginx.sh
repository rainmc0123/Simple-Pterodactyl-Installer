#!/bin/bash

install_nginx() {
    print_section "Menginstall Nginx"
    
    install_nginx_packages
    start_nginx_service
    
    log_success "Nginx berhasil diinstall"
    
    return 0
}

install_nginx_packages() {
    run_with_spinner "Menginstall Nginx web server" "apt-get -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install nginx"
    
    return $?
}

start_nginx_service() {
    start_service "nginx"
    enable_service "nginx"
    
    return 0
}

nginx_test_config() {
    nginx -t >> "$LOG_FILE" 2>&1
    
    return $?
}

nginx_reload() {
    if nginx_test_config; then
        reload_service "nginx"
        return 0
    fi
    
    return 1
}

nginx_restart() {
    restart_service "nginx"
    
    return $?
}

enable_nginx_site() {
    local site_name="$1"
    local available_path="/etc/nginx/sites-available/${site_name}"
    local enabled_path="/etc/nginx/sites-enabled/${site_name}"
    
    if [[ -f "$available_path" ]]; then
        ln -sf "$available_path" "$enabled_path"
        return 0
    fi
    
    return 1
}

disable_nginx_site() {
    local site_name="$1"
    local enabled_path="/etc/nginx/sites-enabled/${site_name}"
    
    if [[ -L "$enabled_path" ]] || [[ -f "$enabled_path" ]]; then
        rm -f "$enabled_path"
        return 0
    fi
    
    return 1
}

remove_nginx_site() {
    local site_name="$1"
    
    disable_nginx_site "$site_name"
    rm -f "/etc/nginx/sites-available/${site_name}"
    
    return 0
}

get_nginx_version() {
    nginx -v 2>&1 | awk -F'/' '{print $2}'
}

verify_nginx_installation() {
    if is_service_active "nginx"; then
        log_success "Nginx berjalan"
        return 0
    fi
    
    log_error "Nginx tidak berjalan"
    return 1
}

remove_default_nginx_site() {
    rm -f /etc/nginx/sites-enabled/default
    
    return 0
}
