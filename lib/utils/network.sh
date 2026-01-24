#!/bin/bash

check_internet_connection() {
    local test_hosts=("google.com" "cloudflare.com" "github.com")
    
    for host in "${test_hosts[@]}"; do
        if ping -c 1 -W 3 "$host" &>/dev/null; then
            return 0
        fi
    done
    
    if curl -s --head --connect-timeout 5 "https://www.google.com" &>/dev/null; then
        return 0
    fi
    
    return 1
}

check_dns_resolution() {
    local domain="$1"
    
    if host "$domain" &>/dev/null; then
        return 0
    fi
    
    if dig +short "$domain" &>/dev/null; then
        return 0
    fi
    
    if nslookup "$domain" &>/dev/null; then
        return 0
    fi
    
    return 1
}

get_public_ip() {
    local ip=""
    local services=(
        "https://icanhazip.com"
        "https://ipinfo.io/ip"
        "https://api.ipify.org"
        "https://checkip.amazonaws.com"
    )
    
    for service in "${services[@]}"; do
        ip=$(curl -s --connect-timeout 5 "$service" 2>/dev/null | tr -d '[:space:]')
        if validate_ip "$ip"; then
            echo "$ip"
            return 0
        fi
    done
    
    return 1
}

check_port_available() {
    local port="$1"
    local protocol="${2:-tcp}"
    
    if command -v ss &>/dev/null; then
        if ss -tuln | grep -q ":${port} "; then
            return 1
        fi
    elif command -v netstat &>/dev/null; then
        if netstat -tuln | grep -q ":${port} "; then
            return 1
        fi
    fi
    
    return 0
}

check_port_open() {
    local host="$1"
    local port="$2"
    local timeout="${3:-5}"
    
    if command -v nc &>/dev/null; then
        if nc -z -w "$timeout" "$host" "$port" &>/dev/null; then
            return 0
        fi
    fi
    
    if timeout "$timeout" bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null; then
        return 0
    fi
    
    return 1
}

get_network_interface() {
    local default_route
    default_route=$(ip route | grep default | head -1 | awk '{print $5}')
    
    if [[ -n "$default_route" ]]; then
        echo "$default_route"
        return 0
    fi
    
    return 1
}

get_local_ip() {
    local interface="${1:-}"
    
    if [[ -z "$interface" ]]; then
        interface=$(get_network_interface)
    fi
    
    if [[ -n "$interface" ]]; then
        local ip
        ip=$(ip addr show "$interface" 2>/dev/null | grep 'inet ' | head -1 | awk '{print $2}' | cut -d'/' -f1)
        if [[ -n "$ip" ]]; then
            echo "$ip"
            return 0
        fi
    fi
    
    hostname -I 2>/dev/null | awk '{print $1}'
    return $?
}

verify_domain_points_to_server() {
    local domain="$1"
    local server_ip="${2:-}"
    
    if [[ -z "$server_ip" ]]; then
        server_ip=$(get_public_ip)
    fi
    
    local domain_ip
    domain_ip=$(dig +short "$domain" 2>/dev/null | tail -1)
    
    if [[ "$domain_ip" == "$server_ip" ]]; then
        return 0
    fi
    
    return 1
}

download_file() {
    local url="$1"
    local destination="$2"
    local timeout="${3:-60}"
    
    if command -v curl &>/dev/null; then
        curl -L --connect-timeout "$timeout" -o "$destination" "$url" 2>/dev/null
        return $?
    fi
    
    if command -v wget &>/dev/null; then
        wget --timeout="$timeout" -O "$destination" "$url" 2>/dev/null
        return $?
    fi
    
    return 1
}

fetch_url() {
    local url="$1"
    local timeout="${2:-30}"
    
    if command -v curl &>/dev/null; then
        curl -s --connect-timeout "$timeout" "$url" 2>/dev/null
        return $?
    fi
    
    if command -v wget &>/dev/null; then
        wget -q --timeout="$timeout" -O - "$url" 2>/dev/null
        return $?
    fi
    
    return 1
}
