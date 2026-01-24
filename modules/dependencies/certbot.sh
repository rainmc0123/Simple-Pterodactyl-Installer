#!/bin/bash

install_certbot() {
    print_section "Menginstall Certbot"
    
    install_certbot_packages
    
    log_success "Certbot berhasil diinstall"
    
    return 0
}

install_certbot_packages() {
    run_with_spinner "Menginstall Certbot untuk SSL" "apt-get -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install certbot python3-certbot-nginx"
    
    return $?
}

obtain_ssl_certificate() {
    local domain="$1"
    local email="$2"
    local webroot="${3:-}"
    
    if [[ -n "$webroot" ]]; then
        certbot certonly --webroot -w "$webroot" -d "$domain" --non-interactive --agree-tos --email "$email" >> "$LOG_FILE" 2>&1
    else
        certbot --nginx -d "$domain" --non-interactive --agree-tos --email "$email" --redirect >> "$LOG_FILE" 2>&1
    fi
    
    return $?
}

renew_ssl_certificates() {
    certbot renew >> "$LOG_FILE" 2>&1
    
    return $?
}

revoke_ssl_certificate() {
    local domain="$1"
    
    certbot revoke --cert-name "$domain" --non-interactive >> "$LOG_FILE" 2>&1
    
    return $?
}

delete_ssl_certificate() {
    local domain="$1"
    
    certbot delete --cert-name "$domain" --non-interactive >> "$LOG_FILE" 2>&1
    
    return $?
}

list_ssl_certificates() {
    certbot certificates 2>/dev/null
}

check_ssl_certificate_exists() {
    local domain="$1"
    local cert_path="/etc/letsencrypt/live/${domain}/fullchain.pem"
    
    [[ -f "$cert_path" ]]
}

get_ssl_certificate_expiry() {
    local domain="$1"
    local cert_path="/etc/letsencrypt/live/${domain}/fullchain.pem"
    
    if [[ -f "$cert_path" ]]; then
        openssl x509 -enddate -noout -in "$cert_path" 2>/dev/null | cut -d'=' -f2
    fi
}

test_ssl_renewal() {
    certbot renew --dry-run >> "$LOG_FILE" 2>&1
    
    return $?
}
