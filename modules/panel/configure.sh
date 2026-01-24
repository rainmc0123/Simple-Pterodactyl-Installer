#!/bin/bash

configure_environment() {
    print_section "Mengkonfigurasi Environment"
    
    cd "$PANEL_PATH" || exit 1
    
    copy_env_file
    install_panel_dependencies
    generate_app_key
    update_env_settings
    
    log_success "Environment berhasil dikonfigurasi"
    
    return 0
}

copy_env_file() {
    cp .env.example .env
    
    return 0
}

install_panel_dependencies() {
    run_with_spinner "Menginstall dependensi PHP (Composer)" "COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --no-interaction"
    
    return $?
}

generate_app_key() {
    run_with_spinner "Membuat application key" "php artisan key:generate --force --no-interaction"
    
    APP_KEY=$(grep "^APP_KEY=" .env | cut -d'=' -f2)
    
    return 0
}

update_env_settings() {
    echo -e "${CYAN}  ►${NC} Memperbarui file environment..."
    
    update_env_value "APP_URL" "${APP_URL}"
    update_env_value "APP_TIMEZONE" "UTC"
    
    update_env_value "DB_HOST" "${DB_HOST:-127.0.0.1}"
    update_env_value "DB_PORT" "${DB_PORT:-3306}"
    update_env_value "DB_DATABASE" "${DB_NAME}"
    update_env_value "DB_USERNAME" "${DB_USER}"
    update_env_value "DB_PASSWORD" "${DB_PASSWORD}"
    
    update_env_value "CACHE_DRIVER" "redis"
    update_env_value "SESSION_DRIVER" "redis"
    update_env_value "QUEUE_CONNECTION" "redis"
    
    update_env_value "REDIS_HOST" "${REDIS_HOST_DEFAULT:-127.0.0.1}"
    update_env_value "REDIS_PORT" "${REDIS_PORT_DEFAULT:-6379}"
    
    update_env_value "MAIL_MAILER" "log"
    update_env_value "MAIL_HOST" "localhost"
    update_env_value "MAIL_PORT" "25"
    update_env_value "MAIL_FROM" "noreply@${FQDN}"
    update_env_value "MAIL_FROM_NAME" "Pterodactyl"
    
    if ! grep -q "PTERODACTYL_TELEMETRY_ENABLED" .env; then
        echo "PTERODACTYL_TELEMETRY_ENABLED=true" >> .env
    fi
    
    return 0
}

update_env_value() {
    local key="$1"
    local value="$2"
    local env_file="${PANEL_PATH}/.env"
    
    if grep -q "^${key}=" "$env_file" 2>/dev/null; then
        sed -i "s|^${key}=.*|${key}=${value}|g" "$env_file"
    else
        echo "${key}=${value}" >> "$env_file"
    fi
    
    return 0
}

get_env_value() {
    local key="$1"
    local env_file="${PANEL_PATH}/.env"
    
    grep "^${key}=" "$env_file" 2>/dev/null | cut -d'=' -f2-
}

clear_panel_cache() {
    cd "$PANEL_PATH" || return 1
    
    php artisan config:clear >> "$LOG_FILE" 2>&1
    php artisan cache:clear >> "$LOG_FILE" 2>&1
    php artisan view:clear >> "$LOG_FILE" 2>&1
    php artisan route:clear >> "$LOG_FILE" 2>&1
    
    return 0
}

optimize_panel() {
    cd "$PANEL_PATH" || return 1
    
    php artisan config:cache >> "$LOG_FILE" 2>&1
    php artisan route:cache >> "$LOG_FILE" 2>&1
    php artisan view:cache >> "$LOG_FILE" 2>&1
    
    return 0
}
