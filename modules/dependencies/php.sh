#!/bin/bash

install_php() {
    print_section "Menginstall PHP ${PHP_VERSION}"
    
    add_php_repository
    install_php_packages
    configure_php
    start_php_fpm
    
    log_success "PHP ${PHP_VERSION} berhasil diinstall"
    
    return 0
}

add_php_repository() {
    case "$OS_NAME" in
        ubuntu)
            run_with_spinner "Menambahkan repositori PHP (PPA)" "LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php"
            ;;
        debian)
            run_with_spinner "Mengunduh keyring PHP Debian" "curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb"
            dpkg -i /tmp/debsuryorg-archive-keyring.deb >> "$LOG_FILE" 2>&1
            echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/sury-php.list
            rm -f /tmp/debsuryorg-archive-keyring.deb
            ;;
    esac
    
    run_with_spinner "Memperbarui daftar paket" "apt-get update -y"
    
    return 0
}

install_php_packages() {
    local php_packages=(
        "php${PHP_VERSION}"
        "php${PHP_VERSION}-common"
        "php${PHP_VERSION}-cli"
        "php${PHP_VERSION}-gd"
        "php${PHP_VERSION}-mysql"
        "php${PHP_VERSION}-mbstring"
        "php${PHP_VERSION}-bcmath"
        "php${PHP_VERSION}-xml"
        "php${PHP_VERSION}-fpm"
        "php${PHP_VERSION}-curl"
        "php${PHP_VERSION}-zip"
        "php${PHP_VERSION}-intl"
        "php${PHP_VERSION}-sqlite3"
    )
    
    local packages_string="${php_packages[*]}"
    
    run_with_spinner "Menginstall PHP ${PHP_VERSION} dan ekstensi" "apt-get -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install $packages_string"
    
    return 0
}

configure_php() {
    local php_ini="/etc/php/${PHP_VERSION}/fpm/php.ini"
    
    if [[ -f "$php_ini" ]]; then
        sed -i 's/upload_max_filesize = .*/upload_max_filesize = 100M/' "$php_ini" 2>/dev/null || true
        sed -i 's/post_max_size = .*/post_max_size = 100M/' "$php_ini" 2>/dev/null || true
        sed -i 's/memory_limit = .*/memory_limit = 256M/' "$php_ini" 2>/dev/null || true
    fi
    
    return 0
}

start_php_fpm() {
    start_service "php${PHP_VERSION}-fpm"
    enable_service "php${PHP_VERSION}-fpm"
    
    return 0
}

get_php_version() {
    php -v 2>/dev/null | head -1 | awk '{print $2}'
}

verify_php_installation() {
    if command -v php &>/dev/null; then
        local version
        version=$(get_php_version)
        log_success "PHP terinstall: $version"
        return 0
    fi
    
    log_error "PHP tidak terinstall"
    return 1
}
