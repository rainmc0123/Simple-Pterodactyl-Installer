#!/bin/bash

configure_firewall() {
    print_section "Mengkonfigurasi Firewall"
    
    if command -v ufw &>/dev/null; then
        configure_ufw_rules
    else
        log_info "UFW tidak ditemukan, melewati konfigurasi firewall"
        log_warning "Silakan konfigurasi firewall secara manual untuk mengizinkan port: 22, 80, 443, 8080, 2022"
    fi
    
    return 0
}

configure_ufw_rules() {
    log_info "Mengkonfigurasi firewall UFW..."
    
    ufw allow 22/tcp >> "$LOG_FILE" 2>&1
    ufw allow 80/tcp >> "$LOG_FILE" 2>&1
    ufw allow 443/tcp >> "$LOG_FILE" 2>&1
    ufw allow 8080/tcp >> "$LOG_FILE" 2>&1
    ufw allow 2022/tcp >> "$LOG_FILE" 2>&1
    
    echo "y" | ufw enable >> "$LOG_FILE" 2>&1
    
    log_success "Firewall berhasil dikonfigurasi"
    
    return 0
}

allow_port() {
    local port="$1"
    local protocol="${2:-tcp}"
    
    if command -v ufw &>/dev/null; then
        ufw allow "${port}/${protocol}" >> "$LOG_FILE" 2>&1
    fi
    
    return $?
}

deny_port() {
    local port="$1"
    local protocol="${2:-tcp}"
    
    if command -v ufw &>/dev/null; then
        ufw deny "${port}/${protocol}" >> "$LOG_FILE" 2>&1
    fi
    
    return $?
}

get_firewall_status() {
    if command -v ufw &>/dev/null; then
        ufw status 2>/dev/null
    else
        echo "UFW not installed"
    fi
}

is_firewall_enabled() {
    if command -v ufw &>/dev/null; then
        ufw status 2>/dev/null | grep -q "Status: active"
    else
        return 1
    fi
}

disable_firewall() {
    if command -v ufw &>/dev/null; then
        ufw disable >> "$LOG_FILE" 2>&1
    fi
    
    return $?
}

reset_firewall() {
    if command -v ufw &>/dev/null; then
        ufw --force reset >> "$LOG_FILE" 2>&1
    fi
    
    return $?
}

list_firewall_rules() {
    if command -v ufw &>/dev/null; then
        ufw status numbered 2>/dev/null
    fi
}

delete_firewall_rule() {
    local rule_number="$1"
    
    if command -v ufw &>/dev/null; then
        echo "y" | ufw delete "$rule_number" >> "$LOG_FILE" 2>&1
    fi
    
    return $?
}
