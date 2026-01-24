#!/bin/bash

update_system() {
    print_section "Memperbarui Sistem"
    
    run_with_spinner "Memperbarui daftar paket" "apt-get update -y"
    run_with_spinner "Meng-upgrade paket yang terinstall" "apt-get -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' upgrade"
    
    log_success "Sistem berhasil diperbarui"
    
    return 0
}

install_dependencies() {
    print_section "Menginstall Dependencies"
    
    local packages=(
        "software-properties-common"
        "curl"
        "apt-transport-https"
        "ca-certificates"
        "gnupg"
        "lsb-release"
        "tar"
        "unzip"
        "git"
        "cron"
        "acl"
    )
    
    local packages_string="${packages[*]}"
    
    run_with_spinner "Menginstall paket-paket penting" "apt-get -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install $packages_string"
    
    log_success "Paket-paket penting berhasil diinstall"
    
    return 0
}

install_package() {
    local package_name="$1"
    local display_name="${2:-$package_name}"
    
    run_with_spinner "Menginstall $display_name" "apt-get -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install $package_name"
    
    return $?
}

remove_package() {
    local package_name="$1"
    local purge="${2:-false}"
    
    if [[ "$purge" == "true" ]]; then
        apt-get -y remove --purge "$package_name" >> "$LOG_FILE" 2>&1
    else
        apt-get -y remove "$package_name" >> "$LOG_FILE" 2>&1
    fi
    
    return $?
}

is_package_installed() {
    local package_name="$1"
    
    dpkg -l "$package_name" 2>/dev/null | grep -q "^ii"
}

get_package_version() {
    local package_name="$1"
    
    dpkg -l "$package_name" 2>/dev/null | awk '/^ii/{print $3}'
}

add_apt_repository() {
    local repo="$1"
    
    add-apt-repository -y "$repo" >> "$LOG_FILE" 2>&1
    apt-get update -y >> "$LOG_FILE" 2>&1
    
    return $?
}

add_apt_key() {
    local key_url="$1"
    local keyring_path="$2"
    
    curl -fsSL "$key_url" | gpg --batch --yes --dearmor -o "$keyring_path" 2>/dev/null
    
    return $?
}

autoremove_packages() {
    apt-get -y autoremove >> "$LOG_FILE" 2>&1
    
    return $?
}

clean_apt_cache() {
    apt-get -y clean >> "$LOG_FILE" 2>&1
    apt-get -y autoclean >> "$LOG_FILE" 2>&1
    
    return $?
}
