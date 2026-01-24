#!/bin/bash

set_permissions() {
    print_section "Mengatur Permission"
    
    set_panel_ownership
    set_panel_file_permissions
    
    log_success "Permission berhasil dikonfigurasi"
    
    return 0
}

set_panel_ownership() {
    log_info "Mengatur kepemilikan ke www-data..."
    
    chown -R www-data:www-data "${PANEL_PATH}"/*
    
    return 0
}

set_panel_file_permissions() {
    log_info "Mengatur permission direktori..."
    
    chmod -R 755 "${PANEL_PATH}/storage" "${PANEL_PATH}/bootstrap/cache"
    
    return 0
}

fix_storage_permissions() {
    chmod -R 755 "${PANEL_PATH}/storage"
    chown -R www-data:www-data "${PANEL_PATH}/storage"
    
    return 0
}

fix_bootstrap_permissions() {
    chmod -R 755 "${PANEL_PATH}/bootstrap/cache"
    chown -R www-data:www-data "${PANEL_PATH}/bootstrap/cache"
    
    return 0
}

secure_env_file() {
    chmod 600 "${PANEL_PATH}/.env"
    chown www-data:www-data "${PANEL_PATH}/.env"
    
    return 0
}

verify_permissions() {
    local errors=0
    
    if [[ ! -w "${PANEL_PATH}/storage" ]]; then
        log_error "Storage directory is not writable"
        ((errors++))
    fi
    
    if [[ ! -w "${PANEL_PATH}/bootstrap/cache" ]]; then
        log_error "Bootstrap cache directory is not writable"
        ((errors++))
    fi
    
    return $errors
}

reset_all_permissions() {
    chown -R www-data:www-data "${PANEL_PATH}"
    find "${PANEL_PATH}" -type f -exec chmod 644 {} \;
    find "${PANEL_PATH}" -type d -exec chmod 755 {} \;
    chmod -R 755 "${PANEL_PATH}/storage" "${PANEL_PATH}/bootstrap/cache"
    chmod 600 "${PANEL_PATH}/.env"
    
    return 0
}
