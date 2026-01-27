#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# FUTURISTIC SUMMARY DISPLAY
# ═══════════════════════════════════════════════════════════════════════════════

save_credentials() {
    local creds_file="${CREDENTIALS_FILE:-/root/pterodactyl-credentials.txt}"
    
    cat > "$creds_file" <<CREDENTIALS_EOF
╔═══════════════════════════════════════════════════════════════════════════╗
║              PTERODACTYL INSTALLATION CREDENTIALS                        ║
║                     © 2026 ClouviaID                                     ║
╚═══════════════════════════════════════════════════════════════════════════╝

Generated: $(date)

═══════════════════════════════════════════════════════════════════════════
PANEL ACCESS
═══════════════════════════════════════════════════════════════════════════
URL:        ${APP_URL}
Admin:      ${ADMIN_EMAIL}
Password:   ${ADMIN_PASSWORD}

═══════════════════════════════════════════════════════════════════════════
DATABASE
═══════════════════════════════════════════════════════════════════════════
Host:       ${DB_HOST:-127.0.0.1}
Port:       ${DB_PORT:-3306}
Database:   ${DB_NAME}
Username:   ${DB_USER}
Password:   ${DB_PASSWORD}

═══════════════════════════════════════════════════════════════════════════
APP KEY
═══════════════════════════════════════════════════════════════════════════
$(grep "^APP_KEY=" "${PANEL_PATH}/.env" 2>/dev/null | cut -d'=' -f2- || echo "N/A")

═══════════════════════════════════════════════════════════════════════════
PATHS
═══════════════════════════════════════════════════════════════════════════
Panel:      ${PANEL_PATH}
Wings:      ${WINGS_CONFIG_PATH}
Nginx:      /etc/nginx/sites-available/pterodactyl.conf
Logs:       ${LOG_FILE}

⚠ DELETE THIS FILE AFTER SAVING CREDENTIALS: rm ${creds_file}
CREDENTIALS_EOF

    chmod 600 "$creds_file"
    return 0
}

print_summary() {
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    
    clear
    echo ""
    echo -e "    ${NEON_GREEN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "    ${NEON_GREEN}┃${NC}                                                                        ${NEON_GREEN}┃${NC}"
    echo -e "    ${NEON_GREEN}┃${NC}       ${STYLE_BOLD}${NEON_GREEN}⚡ INSTALLATION COMPLETE ⚡${NC}                                   ${NEON_GREEN}┃${NC}"
    echo -e "    ${NEON_GREEN}┃${NC}                                                                        ${NEON_GREEN}┃${NC}"
    echo -e "    ${NEON_GREEN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo ""
    echo -e "    ${DIM}Completed in ${duration}s${NC}"
    echo ""
    echo -e "    ${NEON_CYAN}┌──────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "    ${NEON_CYAN}│${NC}  ${NEON_BLUE}▸${NC} ${WHITE}Panel${NC}                                                              ${NEON_CYAN}│${NC}"
    echo -e "    ${NEON_CYAN}│${NC}    URL        ${NEON_CYAN}${APP_URL}${NC}"
    echo -e "    ${NEON_CYAN}│${NC}    Email      ${WHITE}${ADMIN_EMAIL}${NC}"
    echo -e "    ${NEON_CYAN}│${NC}    Password   ${NEON_GREEN}${ADMIN_PASSWORD}${NC}"
    echo -e "    ${NEON_CYAN}├──────────────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "    ${NEON_CYAN}│${NC}  ${NEON_PURPLE}▸${NC} ${WHITE}Database${NC}                                                           ${NEON_CYAN}│${NC}"
    echo -e "    ${NEON_CYAN}│${NC}    Host       ${DIM}${DB_HOST:-127.0.0.1}${NC}"
    echo -e "    ${NEON_CYAN}│${NC}    Name       ${WHITE}${DB_NAME}${NC}"
    echo -e "    ${NEON_CYAN}│${NC}    User       ${WHITE}${DB_USER}${NC}"
    echo -e "    ${NEON_CYAN}│${NC}    Password   ${NEON_GREEN}${DB_PASSWORD}${NC}"
    echo -e "    ${NEON_CYAN}├──────────────────────────────────────────────────────────────────────────┤${NC}"
    echo -e "    ${NEON_CYAN}│${NC}  ${NEON_ORANGE}▸${NC} ${WHITE}Versions${NC}                                                           ${NEON_CYAN}│${NC}"
    echo -e "    ${NEON_CYAN}│${NC}    Panel      ${DIM}${PANEL_VERSION:-latest}${NC}"
    echo -e "    ${NEON_CYAN}│${NC}    PHP        ${DIM}${PHP_VERSION}${NC}"
    echo -e "    ${NEON_CYAN}│${NC}    OS         ${DIM}${OS_NAME} ${OS_VERSION}${NC}"
    echo -e "    ${NEON_CYAN}└──────────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "    ${NEON_ORANGE}⚠${NC}  ${WHITE}Credentials saved:${NC} ${DIM}${CREDENTIALS_FILE:-/root/pterodactyl-credentials.txt}${NC}"
    echo ""
    
    # Show Wings configuration instructions for "both" mode
    if [[ "$INSTALL_MODE" == "both" ]]; then
        echo -e "    ${NEON_CYAN}┌──────────────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "    ${NEON_CYAN}│${NC}  ${NEON_ORANGE}⚡${NC} ${WHITE}KONFIGURASI WINGS${NC}"
        echo -e "    ${NEON_CYAN}│${NC}"
        echo -e "    ${NEON_CYAN}│${NC}  ${NEON_GREEN}1.${NC} Login ke Panel: ${NEON_CYAN}${APP_URL}${NC}"
        echo -e "    ${NEON_CYAN}│${NC}  ${NEON_GREEN}2.${NC} Admin → Locations → Create New"
        echo -e "    ${NEON_CYAN}│${NC}  ${NEON_GREEN}3.${NC} Admin → Nodes → Create New"
        echo -e "    ${NEON_CYAN}│${NC}  ${NEON_GREEN}4.${NC} Klik node → Tab Configuration → ${NEON_ORANGE}Generate Token${NC}"
        echo -e "    ${NEON_CYAN}│${NC}  ${NEON_GREEN}5.${NC} Copy command ${WHITE}Auto-Deploy${NC} lalu jalankan di terminal"
        echo -e "    ${NEON_CYAN}│${NC}  ${NEON_GREEN}6.${NC} Jalankan: ${WHITE}systemctl start wings${NC}"
        echo -e "    ${NEON_CYAN}└──────────────────────────────────────────────────────────────────────────┘${NC}"
        echo ""
    else
        echo -e "    ${DIM}──────────────────────────────────────────────────────────────────────────${NC}"
        echo -e "    ${NEON_CYAN}▸${NC} ${WHITE}Next:${NC} ${DIM}Login → Create Location → Create Node → Configure Wings${NC}"
        echo -e "    ${DIM}──────────────────────────────────────────────────────────────────────────${NC}"
        echo ""
    fi
    
    echo -e "    ${DIM}Powered by${NC} ${NEON_PINK}ClouviaID${NC}"
    echo -e "    ${NEON_ORANGE}⚡${NC} ${DIM}Pterodactyl Community:${NC} ${NEON_CYAN}https://chat.whatsapp.com/I9TD1kQM9kKAeFVzzChysJ${NC}"
    echo ""
    
    return 0
}

print_wings_summary() {
    local end_time=$(date +%s)
    local duration=$((end_time - START_TIME))
    
    clear
    echo ""
    echo -e "    ${NEON_GREEN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "    ${NEON_GREEN}┃${NC}                                                                        ${NEON_GREEN}┃${NC}"
    echo -e "    ${NEON_GREEN}┃${NC}       ${STYLE_BOLD}${NEON_GREEN}⚡ WINGS INSTALLATION COMPLETE ⚡${NC}                              ${NEON_GREEN}┃${NC}"
    echo -e "    ${NEON_GREEN}┃${NC}                                                                        ${NEON_GREEN}┃${NC}"
    echo -e "    ${NEON_GREEN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo ""
    echo -e "    ${DIM}Completed in ${duration}s${NC}"
    echo ""
    echo -e "    ${NEON_CYAN}┌──────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "    ${NEON_CYAN}│${NC}  ${NEON_BLUE}▸${NC} ${WHITE}Node${NC}                                                               ${NEON_CYAN}│${NC}"
    echo -e "    ${NEON_CYAN}│${NC}    FQDN       ${NEON_CYAN}${WINGS_FQDN}${NC}"
    echo -e "    ${NEON_CYAN}│${NC}    Docker     ${DIM}$(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',' || echo 'latest')${NC}"
    echo -e "    ${NEON_CYAN}│${NC}    Wings      ${DIM}$(wings --version 2>/dev/null || echo 'latest')${NC}"
    echo -e "    ${NEON_CYAN}│${NC}    OS         ${DIM}${OS_NAME} ${OS_VERSION}${NC}"
    echo -e "    ${NEON_CYAN}├──────────────────────────────────────────────────────────────────────────┤${NC}"
    
    if check_ssl_certificate_exists "$WINGS_FQDN"; then
        echo -e "    ${NEON_CYAN}│${NC}  ${NEON_GREEN}▸${NC} ${WHITE}SSL${NC}           ${NEON_GREEN}✓ Configured${NC}"
        echo -e "    ${NEON_CYAN}│${NC}    Cert       ${DIM}/etc/letsencrypt/live/${WINGS_FQDN}/fullchain.pem${NC}"
        echo -e "    ${NEON_CYAN}│${NC}    Key        ${DIM}/etc/letsencrypt/live/${WINGS_FQDN}/privkey.pem${NC}"
    else
        echo -e "    ${NEON_CYAN}│${NC}  ${NEON_ORANGE}▸${NC} ${WHITE}SSL${NC}           ${NEON_ORANGE}Not configured${NC}"
    fi
    
    echo -e "    ${NEON_CYAN}└──────────────────────────────────────────────────────────────────────────┘${NC}"
    echo ""
    echo -e "    ${NEON_ORANGE}⚠${NC}  ${WHITE}Wings must be configured before starting!${NC}"
    echo ""
    echo -e "    ${DIM}──────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${NEON_CYAN}▸${NC} ${WHITE}Next Steps:${NC}"
    echo -e "    ${DIM}  1. Open Panel → Admin → Nodes → Create New${NC}"
    echo -e "    ${DIM}  2. Set FQDN: ${WINGS_FQDN}${NC}"
    if check_ssl_certificate_exists "$WINGS_FQDN"; then
        echo -e "    ${DIM}  3. SSL: Use SSL Connection${NC}"
    else
        echo -e "    ${DIM}  3. SSL: Use HTTP or enable auto_tls${NC}"
    fi
    echo -e "    ${DIM}  4. Copy auto-deploy command from Configuration tab${NC}"
    echo -e "    ${DIM}  5. Run: systemctl start wings${NC}"
    echo -e "    ${DIM}──────────────────────────────────────────────────────────────────────────${NC}"
    echo ""
    echo -e "    ${DIM}Powered by${NC} ${NEON_PINK}ClouviaID${NC}"
    echo -e "    ${NEON_ORANGE}⚡${NC} ${DIM}Pterodactyl Community:${NC} ${NEON_CYAN}https://chat.whatsapp.com/I9TD1kQM9kKAeFVzzChysJ${NC}"
    echo ""
    
    return 0
}

print_uninstall_complete() {
    clear
    echo ""
    echo -e "    ${NEON_ORANGE}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "    ${NEON_ORANGE}┃${NC}                                                                        ${NEON_ORANGE}┃${NC}"
    echo -e "    ${NEON_ORANGE}┃${NC}       ${STYLE_BOLD}${NEON_ORANGE}⚡ UNINSTALL COMPLETE ⚡${NC}                                       ${NEON_ORANGE}┃${NC}"
    echo -e "    ${NEON_ORANGE}┃${NC}                                                                        ${NEON_ORANGE}┃${NC}"
    echo -e "    ${NEON_ORANGE}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo ""
    echo -e "    ${DIM}Remaining packages (not removed):${NC}"
    echo -e "    ${DIM}  PHP, MariaDB, Redis, Nginx, Docker, Certbot${NC}"
    echo ""
    echo -e "    ${DIM}To fully purge:${NC}"
    echo -e "    ${DIM}  apt remove --purge php* mariadb-* redis-server nginx docker-ce -y${NC}"
    echo ""
    echo -e "    ${DIM}Powered by${NC} ${NEON_PINK}ClouviaID${NC}"
    echo -e "    ${NEON_ORANGE}⚡${NC} ${DIM}Pterodactyl Community:${NC} ${NEON_CYAN}https://chat.whatsapp.com/I9TD1kQM9kKAeFVzzChysJ${NC}"
    echo ""
    
    return 0
}
