#!/bin/bash

verify_installation() {
    print_section "Memverifikasi Instalasi"
    
    local errors=0
    
    if [[ "$INSTALL_MODE" == "panel" || "$INSTALL_MODE" == "both" ]]; then
        errors=$((errors + $(verify_panel_components)))
    fi
    
    if [[ "$INSTALL_MODE" == "wings" || "$INSTALL_MODE" == "both" ]]; then
        errors=$((errors + $(verify_wings_components)))
    fi
    
    if [[ $errors -eq 0 ]]; then
        log_success "Semua komponen berhasil diverifikasi!"
        return 0
    else
        log_warning "$errors komponen gagal verifikasi"
        return 1
    fi
}

verify_panel_components() {
    local errors=0
    
    if ! verify_service_running "php${PHP_VERSION}-fpm" "PHP-FPM"; then
        ((errors++))
    fi
    
    if ! verify_service_running "mariadb" "MariaDB"; then
        ((errors++))
    fi
    
    if ! verify_service_running "redis-server" "Redis"; then
        ((errors++))
    fi
    
    if ! verify_service_running "nginx" "Nginx"; then
        ((errors++))
    fi
    
    if ! verify_service_running "pteroq" "Queue worker"; then
        ((errors++))
    fi
    
    if ! verify_panel_installation; then
        ((errors++))
    fi
    
    echo $errors
}

verify_wings_components() {
    local errors=0
    
    if ! verify_service_running "docker" "Docker"; then
        ((errors++))
    fi
    
    if ! verify_wings_binary; then
        ((errors++))
    fi
    
    echo $errors
}

run_post_installation_checks() {
    check_http_access
    check_database_connectivity
    check_redis_connectivity
    
    return 0
}

check_http_access() {
    if curl -s -o /dev/null -w "%{http_code}" "http://${FQDN}" 2>/dev/null | grep -qE "200|301|302"; then
        log_success "HTTP access OK"
        return 0
    fi
    
    log_warning "HTTP access check failed"
    return 1
}

check_database_connectivity() {
    if test_database_connection "$DB_USER" "$DB_PASSWORD" "$DB_HOST" "$DB_NAME"; then
        log_success "Database connectivity OK"
        return 0
    fi
    
    log_warning "Database connectivity check failed"
    return 1
}

check_redis_connectivity() {
    if redis_ping; then
        log_success "Redis connectivity OK"
        return 0
    fi
    
    log_warning "Redis connectivity check failed"
    return 1
}

generate_health_report() {
    local report=""
    
    report+="=== PTERODACTYL HEALTH REPORT ===\n"
    report+="Generated: $(date)\n"
    report+="\n"
    report+="=== SERVICES ===\n"
    report+="PHP-FPM: $(is_service_active "php${PHP_VERSION}-fpm" && echo "Running" || echo "Stopped")\n"
    report+="MariaDB: $(is_service_active "mariadb" && echo "Running" || echo "Stopped")\n"
    report+="Redis: $(is_service_active "redis-server" && echo "Running" || echo "Stopped")\n"
    report+="Nginx: $(is_service_active "nginx" && echo "Running" || echo "Stopped")\n"
    report+="Queue Worker: $(is_service_active "pteroq" && echo "Running" || echo "Stopped")\n"
    report+="Docker: $(is_service_active "docker" && echo "Running" || echo "Stopped")\n"
    report+="Wings: $(is_service_active "wings" && echo "Running" || echo "Not Running")\n"
    report+="\n"
    report+="=== RESOURCES ===\n"
    report+="$(resource_summary)\n"
    
    echo -e "$report"
}
