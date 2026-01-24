#!/bin/bash

declare -gr DOMAIN_REGEX='^[a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]*[a-zA-Z0-9])?)*$'
declare -gr EMAIL_REGEX='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
declare -gr IP_REGEX='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
declare -gr IPV6_REGEX='^([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}$'
declare -gr PORT_REGEX='^([1-9]|[1-9][0-9]{1,3}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])$'

validate_domain() {
    local domain="$1"
    
    if [[ -z "$domain" ]]; then
        return 1
    fi
    
    domain=$(echo "$domain" | sed -e 's|^https\?://||' -e 's|/$||')
    
    if [[ "$domain" =~ $DOMAIN_REGEX ]]; then
        return 0
    fi
    
    return 1
}

validate_email() {
    local email="$1"
    
    if [[ -z "$email" ]]; then
        return 1
    fi
    
    if [[ "$email" =~ $EMAIL_REGEX ]]; then
        return 0
    fi
    
    return 1
}

validate_ip() {
    local ip="$1"
    
    if [[ "$ip" =~ $IP_REGEX ]]; then
        return 0
    fi
    
    return 1
}

validate_ipv6() {
    local ip="$1"
    
    if [[ "$ip" =~ $IPV6_REGEX ]]; then
        return 0
    fi
    
    return 1
}

validate_port() {
    local port="$1"
    
    if [[ "$port" =~ $PORT_REGEX ]]; then
        return 0
    fi
    
    return 1
}

validate_not_empty() {
    local value="$1"
    local name="${2:-value}"
    
    if [[ -z "$value" ]]; then
        return 1
    fi
    
    return 0
}

validate_numeric() {
    local value="$1"
    
    if [[ "$value" =~ ^[0-9]+$ ]]; then
        return 0
    fi
    
    return 1
}

validate_alphanumeric() {
    local value="$1"
    
    if [[ "$value" =~ ^[a-zA-Z0-9]+$ ]]; then
        return 0
    fi
    
    return 1
}

validate_path() {
    local path="$1"
    
    if [[ -z "$path" ]]; then
        return 1
    fi
    
    if [[ ! "$path" =~ ^/ ]]; then
        return 2
    fi
    
    return 0
}

validate_url() {
    local url="$1"
    
    if [[ "$url" =~ ^https?:// ]]; then
        return 0
    fi
    
    return 1
}

sanitize_domain() {
    local domain="$1"
    
    domain=$(echo "$domain" | sed -e 's|^https\?://||' -e 's|/$||' -e 's|/.*||')
    
    echo "$domain"
}

sanitize_input() {
    local input="$1"
    
    input=$(echo "$input" | sed -e 's/[<>\"'\''&;|`$()]//g')
    
    echo "$input"
}
