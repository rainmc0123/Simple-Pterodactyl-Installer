#!/bin/bash

get_user_input() {
    print_section "Configuration"
    
    local domain_prompt=""
    case $INSTALL_MODE in
        panel|both)
            domain_prompt="panel domain (e.g., panel.example.com)"
            ;;
        wings)
            domain_prompt="node FQDN (e.g., node1.example.com)"
            ;;
    esac
    
    if [[ -n "$ARG_DOMAIN" ]]; then
        FQDN=$(echo "$ARG_DOMAIN" | sed -e 's|^https\?://||' -e 's|/$||')
        log_info "Using domain from command line: $FQDN"
    else
        echo -e "${WHITE}Please enter your ${domain_prompt}:${NC}"
        echo -e "${YELLOW}Note: This domain/hostname must be pointed to this server's IP address.${NC}"
        echo ""
        
        while true; do
            read -p "Domain: " FQDN
            
            if [[ -z "$FQDN" ]]; then
                log_error "Domain cannot be empty!"
                continue
            fi
            
            FQDN=$(echo "$FQDN" | sed -e 's|^https\?://||' -e 's|/$||')
            
            if ! validate_domain "$FQDN"; then
                log_error "Invalid domain format! Please enter a valid domain."
                continue
            fi
            
            break
        done
    fi
    
    APP_URL="https://$FQDN"
    
    if [[ "$INSTALL_MODE" == "panel" || "$INSTALL_MODE" == "both" ]]; then
        ADMIN_EMAIL="admin@$FQDN"
        log_success "Domain configured: $FQDN"
        log_info "Panel URL will be: $APP_URL"
    else
        log_success "Node FQDN configured: $FQDN"
    fi
    
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}  All other configurations will be generated automatically.${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    sleep 2
    
    return 0
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
