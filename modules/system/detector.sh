#!/bin/bash

detect_os() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        OS_NAME="$ID"
        OS_VERSION="$VERSION_ID"
        OS_PRETTY_NAME="$PRETTY_NAME"
        return 0
    fi
    
    return 1
}

check_os_supported() {
    print_section "Memeriksa Sistem Operasi"
    
    if ! detect_os; then
        log_error "Tidak dapat menentukan sistem operasi"
        exit 1
    fi
    
    log_info "OS Terdeteksi: $OS_PRETTY_NAME"
    
    case "$OS_NAME" in
        ubuntu)
            check_ubuntu_version
            ;;
        debian)
            check_debian_version
            ;;
        *)
            log_error "Sistem operasi tidak didukung: $OS_NAME"
            log_info "Didukung: Ubuntu 20.04/22.04/24.04, Debian 11/12/13"
            exit 1
            ;;
    esac
    
    return 0
}

check_ubuntu_version() {
    local supported=false
    
    for version in "${SUPPORTED_UBUNTU_VERSIONS[@]}"; do
        if [[ "$OS_VERSION" == "$version" ]]; then
            supported=true
            break
        fi
    done
    
    if [[ "$supported" == "true" ]]; then
        log_success "Ubuntu $OS_VERSION didukung"
    else
        log_warning "Ubuntu $OS_VERSION mungkin belum sepenuhnya diuji"
        confirm_action "Versi ini mungkin memiliki masalah kompatibilitas."
    fi
    
    return 0
}

check_debian_version() {
    local supported=false
    
    for version in "${SUPPORTED_DEBIAN_VERSIONS[@]}"; do
        if [[ "$OS_VERSION" == "$version" ]]; then
            supported=true
            break
        fi
    done
    
    if [[ "$supported" == "true" ]]; then
        log_success "Debian $OS_VERSION didukung"
    else
        log_warning "Debian $OS_VERSION mungkin belum sepenuhnya diuji"
        confirm_action "Versi ini mungkin memiliki masalah kompatibilitas."
    fi
    
    return 0
}

detect_virtualization() {
    print_section "Memeriksa Virtualisasi"
    
    VIRT_TYPE=$(systemd-detect-virt 2>/dev/null || echo "unknown")
    
    log_info "Tipe virtualisasi: $VIRT_TYPE"
    
    case "$VIRT_TYPE" in
        openvz|lxc)
            log_error "Container OpenVZ/LXC TIDAK didukung!"
            log_info "Docker tidak dapat berjalan dengan baik di lingkungan ini."
            log_info "Silakan gunakan KVM, VMware, atau hardware dedicated."
            exit 1
            ;;
        none|kvm|vmware|microsoft|oracle|xen|*)
            log_success "Virtualisasi kompatibel"
            ;;
    esac
    
    return 0
}

detect_architecture() {
    local arch
    arch=$(uname -m)
    
    case "$arch" in
        x86_64|amd64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

check_root() {
    print_section "Memeriksa Hak Akses Root"
    
    if [[ $EUID -ne 0 ]]; then
        log_error "Script ini harus dijalankan sebagai root!"
        log_info "Silakan jalankan: sudo bash install.sh"
        exit 1
    fi
    
    log_success "Berjalan sebagai user root"
    
    return 0
}

get_system_info() {
    local info=""
    
    info+="OS: ${OS_PRETTY_NAME:-Unknown}\n"
    info+="Kernel: $(uname -r)\n"
    info+="Architecture: $(detect_architecture)\n"
    info+="Virtualization: ${VIRT_TYPE:-Unknown}\n"
    info+="Hostname: $(hostname)\n"
    
    echo -e "$info"
}
