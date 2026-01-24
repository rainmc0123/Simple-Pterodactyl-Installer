#!/bin/bash

install_composer() {
    print_section "Menginstall Composer"
    
    download_composer
    verify_composer_installation
    
    return 0
}

download_composer() {
    run_with_spinner "Mengunduh dan menginstall Composer" "curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer"
    
    return $?
}

verify_composer_installation() {
    if command -v composer &>/dev/null; then
        COMPOSER_VERSION=$(COMPOSER_ALLOW_SUPERUSER=1 composer --version --no-interaction 2>/dev/null | head -1)
        log_success "Composer terinstall: $COMPOSER_VERSION"
        return 0
    fi
    
    log_error "Instalasi Composer gagal!"
    exit 1
}

composer_install() {
    local path="${1:-.}"
    local flags="${2:---no-dev --optimize-autoloader --no-interaction}"
    
    cd "$path" || return 1
    COMPOSER_ALLOW_SUPERUSER=1 composer install $flags >> "$LOG_FILE" 2>&1
    
    return $?
}

composer_update() {
    local path="${1:-.}"
    local flags="${2:---no-dev --optimize-autoloader --no-interaction}"
    
    cd "$path" || return 1
    COMPOSER_ALLOW_SUPERUSER=1 composer update $flags >> "$LOG_FILE" 2>&1
    
    return $?
}

composer_dump_autoload() {
    local path="${1:-.}"
    
    cd "$path" || return 1
    COMPOSER_ALLOW_SUPERUSER=1 composer dump-autoload --optimize >> "$LOG_FILE" 2>&1
    
    return $?
}

get_composer_version() {
    COMPOSER_ALLOW_SUPERUSER=1 composer --version --no-interaction 2>/dev/null | awk '{print $3}'
}
