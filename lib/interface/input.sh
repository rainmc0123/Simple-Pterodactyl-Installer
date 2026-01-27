#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# FUTURISTIC INPUT HANDLER - Simple & Clean
# ═══════════════════════════════════════════════════════════════════════════════

get_user_input() {
    echo ""
    echo -e "    ${NEON_CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}  ${NEON_BLUE}⚡${NC} ${STYLE_BOLD}${WHITE}CONFIGURATION${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}"
    
    # Get Panel domain for panel and both modes
    if [[ "$INSTALL_MODE" == "panel" || "$INSTALL_MODE" == "both" ]]; then
        get_panel_domain
    fi
    
    # Get Wings FQDN for wings and both modes
    if [[ "$INSTALL_MODE" == "wings" || "$INSTALL_MODE" == "both" ]]; then
        get_wings_fqdn
    fi
    
    # Configuration complete message
    echo ""
    echo -e "    ${DIM}──────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${NEON_GREEN}✓${NC} ${WHITE}Configuration complete${NC}"
    echo -e "    ${DIM}──────────────────────────────────────────────────────────────────────────${NC}"
    echo ""
    
    sleep 0.5
    return 0
}

get_panel_domain() {
    echo ""
    echo -e "    ${DIM}Enter your panel domain (pointed to this server)${NC}"
    echo ""
    
    local server_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    
    if [[ -n "$ARG_DOMAIN" ]]; then
        FQDN=$(echo "$ARG_DOMAIN" | sed -e 's|^https\?://||' -e 's|/$||')
        echo -e "    ${NEON_GREEN}▸${NC} ${WHITE}Domain${NC}: ${NEON_CYAN}$FQDN${NC} ${DIM}(from args)${NC}"
        
        # Validate DNS even for args
        if ! validate_domain_dns "$FQDN" "$server_ip"; then
            log_error "Domain dari argument tidak valid. Silakan perbaiki DNS dan coba lagi."
            exit 1
        fi
    else
        while true; do
            echo -ne "    ${NEON_CYAN}▸${NC} ${WHITE}Domain${NC}: "
            read -r FQDN
            
            [[ -z "$FQDN" ]] && { echo -e "    ${RED}✗${NC} ${DIM}Required${NC}"; continue; }
            
            FQDN=$(echo "$FQDN" | sed -e 's|^https\?://||' -e 's|/$||')
            validate_domain "$FQDN" || { echo -e "    ${RED}✗${NC} ${DIM}Invalid format${NC}"; continue; }
            
            # Validate DNS
            if ! validate_domain_dns "$FQDN" "$server_ip"; then
                continue
            fi
            
            break
        done
    fi
    
    APP_URL="https://$FQDN"
    ADMIN_EMAIL="admin@$FQDN"
}

validate_domain_dns() {
    local domain="$1"
    local server_ip="$2"
    
    echo -e "    ${DIM}Memeriksa DNS untuk ${domain}...${NC}"
    
    # Get DNS A record
    local dns_ip
    dns_ip=$(dig +short "$domain" A 2>/dev/null | head -1)
    
    # If dig not available, try host command
    if [[ -z "$dns_ip" ]]; then
        dns_ip=$(host "$domain" 2>/dev/null | grep "has address" | head -1 | awk '{print $NF}')
    fi
    
    # If still empty, try getent
    if [[ -z "$dns_ip" ]]; then
        dns_ip=$(getent hosts "$domain" 2>/dev/null | awk '{print $1}' | head -1)
    fi
    
    if [[ -z "$dns_ip" ]]; then
        echo -e "    ${RED}✗${NC} ${WHITE}DNS tidak ditemukan untuk ${domain}${NC}"
        echo -e "    ${DIM}  Pastikan domain sudah memiliki A record${NC}"
        echo ""
        return 1
    fi
    
    if [[ "$dns_ip" != "$server_ip" ]]; then
        echo -e "    ${RED}✗${NC} ${WHITE}IP DNS tidak cocok!${NC}"
        echo -e "    ${DIM}  DNS IP    : ${NEON_CYAN}${dns_ip}${NC}"
        echo -e "    ${DIM}  Server IP : ${NEON_GREEN}${server_ip}${NC}"
        echo -e "    ${NEON_ORANGE}⚠${NC} ${DIM}Pastikan A record domain mengarah ke IP server ini${NC}"
        echo ""
        return 1
    fi
    
    echo -e "    ${NEON_GREEN}✓${NC} ${DIM}DNS OK (${dns_ip})${NC}"
    return 0
}

get_wings_fqdn() {
    echo ""
    
    local server_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    
    # For 'both' mode, default to panel domain
    if [[ "$INSTALL_MODE" == "both" && -n "$FQDN" ]]; then
        echo -e "    ${DIM}Wings FQDN (Enter = same as panel: ${FQDN})${NC}"
    else
        echo -e "    ${DIM}Enter your Wings node FQDN${NC}"
    fi
    echo ""
    
    while true; do
        echo -ne "    ${NEON_CYAN}▸${NC} ${WHITE}FQDN${NC}: "
        read -r WINGS_FQDN
        
        # Default to panel domain if empty in 'both' mode
        if [[ -z "$WINGS_FQDN" && "$INSTALL_MODE" == "both" && -n "$FQDN" ]]; then
            WINGS_FQDN="$FQDN"
            echo -e "    ${NEON_GREEN}▸${NC} ${DIM}Using:${NC} ${NEON_CYAN}$WINGS_FQDN${NC}"
            # Already validated for panel, skip
            break
        fi
        
        [[ -z "$WINGS_FQDN" ]] && { echo -e "    ${RED}✗${NC} ${DIM}Required${NC}"; continue; }
        
        WINGS_FQDN=$(echo "$WINGS_FQDN" | sed -e 's|^https\?://||' -e 's|/$||')
        validate_domain "$WINGS_FQDN" || { echo -e "    ${RED}✗${NC} ${DIM}Invalid format${NC}"; continue; }
        
        # Validate DNS
        if ! validate_domain_dns "$WINGS_FQDN" "$server_ip"; then
            continue
        fi
        
        break
    done
    
    # Get email for wings-only mode (for SSL certificate)
    if [[ -z "$ADMIN_EMAIL" ]]; then
        echo ""
        echo -e "    ${DIM}Email for SSL certificate${NC}"
        echo ""
        while true; do
            echo -ne "    ${NEON_CYAN}▸${NC} ${WHITE}Email${NC}: "
            read -r ADMIN_EMAIL
            
            [[ -z "$ADMIN_EMAIL" ]] && { echo -e "    ${RED}✗${NC} ${DIM}Required${NC}"; continue; }
            validate_email "$ADMIN_EMAIL" || { echo -e "    ${RED}✗${NC} ${DIM}Invalid format${NC}"; continue; }
            break
        done
    fi
    
    # SSL will be auto-detected and fixed during Wings configuration
    echo -e "    ${DIM}ℹ SSL akan dikonfigurasi otomatis saat Wings dijalankan${NC}"
}

prompt_input() {
    local prompt="$1"
    local variable_name="$2"
    local default_value="${3:-}"
    local validation_func="${4:-}"
    
    local value=""
    
    while true; do
        if [[ -n "$default_value" ]]; then
            read -p "$prompt [$default_value]: " value
            value="${value:-$default_value}"
        else
            read -p "$prompt: " value
        fi
        
        if [[ -n "$validation_func" ]]; then
            if ! eval "$validation_func \"$value\""; then
                log_error "Invalid input. Please try again."
                continue
            fi
        fi
        
        break
    done
    
    eval "$variable_name=\"$value\""
    
    return 0
}

prompt_password() {
    local prompt="$1"
    local variable_name="$2"
    
    local password=""
    local password_confirm=""
    
    while true; do
        read -s -p "$prompt: " password
        echo
        read -s -p "Confirm password: " password_confirm
        echo
        
        if [[ "$password" != "$password_confirm" ]]; then
            log_error "Passwords do not match. Please try again."
            continue
        fi
        
        if [[ ${#password} -lt 8 ]]; then
            log_error "Password must be at least 8 characters."
            continue
        fi
        
        break
    done
    
    eval "$variable_name=\"$password\""
    
    return 0
}

prompt_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    
    local response=""
    
    if [[ "$default" == "y" ]]; then
        read -p "$prompt [Y/n]: " response
        response="${response:-y}"
    else
        read -p "$prompt [y/N]: " response
        response="${response:-n}"
    fi
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0
    fi
    
    return 1
}

prompt_selection() {
    local prompt="$1"
    shift
    local options=("$@")
    
    echo -e "${WHITE}$prompt${NC}"
    echo ""
    
    local i=1
    for option in "${options[@]}"; do
        echo -e "  ${GREEN}[$i]${NC} $option"
        ((i++))
    done
    
    echo ""
    
    local selection=""
    while true; do
        read -p "Selection [1-${#options[@]}]: " selection
        
        if [[ "$selection" =~ ^[0-9]+$ ]] && [[ "$selection" -ge 1 ]] && [[ "$selection" -le ${#options[@]} ]]; then
            break
        fi
        
        log_error "Invalid selection. Please try again."
    done
    
    return $((selection - 1))
}
