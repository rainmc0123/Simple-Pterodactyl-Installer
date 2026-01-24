#!/bin/bash

declare -gr PASSWORD_CHARSET_FULL='A-Za-z0-9!@#$%^&*()_+'
declare -gr PASSWORD_CHARSET_SIMPLE='A-Za-z0-9'
declare -gr PASSWORD_CHARSET_HEX='0-9a-f'
declare -gr PASSWORD_CHARSET_ALPHA='A-Za-z'
declare -gr PASSWORD_CHARSET_NUMERIC='0-9'

generate_password() {
    local length="${1:-32}"
    local charset="${2:-$PASSWORD_CHARSET_FULL}"
    
    tr -dc "$charset" </dev/urandom | head -c "$length"
    
    return 0
}

generate_simple_password() {
    local length="${1:-24}"
    
    generate_password "$length" "$PASSWORD_CHARSET_SIMPLE"
    
    return 0
}

generate_hex_string() {
    local length="${1:-32}"
    
    generate_password "$length" "$PASSWORD_CHARSET_HEX"
    
    return 0
}

generate_uuid() {
    if command -v uuidgen &>/dev/null; then
        uuidgen
    else
        cat /proc/sys/kernel/random/uuid 2>/dev/null || \
        generate_hex_string 32 | sed 's/\(........\)\(....\)\(....\)\(....\)\(............\)/\1-\2-\3-\4-\5/'
    fi
    
    return 0
}

hash_password() {
    local password="$1"
    local algorithm="${2:-bcrypt}"
    
    case "$algorithm" in
        bcrypt)
            php -r "echo password_hash('$password', PASSWORD_BCRYPT);"
            ;;
        sha256)
            echo -n "$password" | sha256sum | cut -d' ' -f1
            ;;
        sha512)
            echo -n "$password" | sha512sum | cut -d' ' -f1
            ;;
        md5)
            echo -n "$password" | md5sum | cut -d' ' -f1
            ;;
        *)
            php -r "echo password_hash('$password', PASSWORD_BCRYPT);"
            ;;
    esac
    
    return 0
}

validate_password_strength() {
    local password="$1"
    local min_length="${2:-8}"
    
    if [[ ${#password} -lt $min_length ]]; then
        return 1
    fi
    
    if [[ ! "$password" =~ [A-Z] ]]; then
        return 2
    fi
    
    if [[ ! "$password" =~ [a-z] ]]; then
        return 3
    fi
    
    if [[ ! "$password" =~ [0-9] ]]; then
        return 4
    fi
    
    return 0
}

generate_api_key() {
    local prefix="${1:-ptdl}"
    local key_part
    
    key_part=$(generate_hex_string 32)
    
    echo "${prefix}_${key_part}"
    
    return 0
}

generate_token() {
    local length="${1:-64}"
    
    generate_password "$length" "$PASSWORD_CHARSET_SIMPLE"
    
    return 0
}
