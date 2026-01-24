#!/bin/bash

save_credentials() {
    local creds_file="${CREDENTIALS_FILE:-/root/pterodactyl-credentials.txt}"
    
    cat > "$creds_file" <<CREDENTIALS_EOF
╔═══════════════════════════════════════════════════════════════════════════╗
║                    KREDENSIAL INSTALASI PTERODACTYL                      ║
║                         ${INSTALLER_COPYRIGHT:-© ClouviaID}                                       ║
╚═══════════════════════════════════════════════════════════════════════════╝

Dibuat: $(date)

═══════════════════════════════════════════════════════════════════════════
AKSES PANEL
═══════════════════════════════════════════════════════════════════════════
URL:        ${APP_URL}
Admin:      ${ADMIN_EMAIL}
Password:   ${ADMIN_PASSWORD}

═══════════════════════════════════════════════════════════════════════════
KREDENSIAL DATABASE
═══════════════════════════════════════════════════════════════════════════
Host:       ${DB_HOST:-127.0.0.1}
Port:       ${DB_PORT:-3306}
Database:   ${DB_NAME}
Username:   ${DB_USER}
Password:   ${DB_PASSWORD}

═══════════════════════════════════════════════════════════════════════════
APPLICATION KEY
═══════════════════════════════════════════════════════════════════════════
APP_KEY:    $(grep "^APP_KEY=" "${PANEL_PATH}/.env" 2>/dev/null | cut -d'=' -f2- || echo "N/A")

═══════════════════════════════════════════════════════════════════════════
LOKASI PENTING
═══════════════════════════════════════════════════════════════════════════
Panel:      ${PANEL_PATH}
Wings:      ${WINGS_CONFIG_PATH}
Nginx:      /etc/nginx/sites-available/pterodactyl.conf
Logs:       ${LOG_FILE}

═══════════════════════════════════════════════════════════════════════════
LANGKAH SELANJUTNYA
═══════════════════════════════════════════════════════════════════════════
1. Akses panel di: ${APP_URL}
2. Login dengan kredensial admin di atas
3. Buat Location (Admin > Locations)
4. Buat Node (Admin > Nodes)
5. Salin konfigurasi Wings dari Node
6. Paste ke: ${WINGS_CONFIG_PATH}/config.yml
7. Jalankan Wings: systemctl start wings

═══════════════════════════════════════════════════════════════════════════

PERINGATAN KEAMANAN: Hapus file ini setelah menyimpan kredensial dengan aman!
    rm ${creds_file}

CREDENTIALS_EOF

    chmod 600 "$creds_file"
    log_success "Kredensial disimpan ke: $creds_file"
    
    return 0
}

print_summary() {
    print_section "Instalasi Selesai!"
    
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║                    🎉 INSTALASI BERHASIL! 🎉                            ║"
    echo "║                        ${INSTALLER_COPYRIGHT:-© ClouviaID}                                   ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo ""
    echo -e "${WHITE}URL Panel:${NC}        ${CYAN}${APP_URL}${NC}"
    echo ""
    echo -e "${WHITE}Login Admin:${NC}"
    echo -e "  Email:          ${CYAN}${ADMIN_EMAIL}${NC}"
    echo -e "  Password:       ${CYAN}${ADMIN_PASSWORD}${NC}"
    echo ""
    echo -e "${WHITE}Database:${NC}"
    echo -e "  Host:           ${CYAN}${DB_HOST:-127.0.0.1}${NC}"
    echo -e "  Database:       ${CYAN}${DB_NAME}${NC}"
    echo -e "  Username:       ${CYAN}${DB_USER}${NC}"
    echo -e "  Password:       ${CYAN}${DB_PASSWORD}${NC}"
    echo ""
    echo -e "${WHITE}Versi Terinstall:${NC}"
    echo -e "  Panel:          ${CYAN}${PANEL_VERSION:-latest}${NC}"
    echo -e "  PHP:            ${CYAN}${PHP_VERSION}${NC}"
    echo -e "  OS:             ${CYAN}${OS_NAME} ${OS_VERSION}${NC}"
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}PENTING: Semua kredensial telah disimpan ke:${NC}"
    echo -e "${WHITE}${CREDENTIALS_FILE:-/root/pterodactyl-credentials.txt}${NC}"
    echo ""
    echo -e "${YELLOW}Silakan simpan kredensial dengan aman dan hapus file tersebut!${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Langkah Selanjutnya:${NC}"
    echo "1. Akses panel di: ${APP_URL}"
    echo "2. Login dengan kredensial admin"
    echo "3. Buat Location (Admin > Locations)"
    echo "4. Buat Node (Admin > Nodes)"
    echo "5. Konfigurasi Wings menggunakan token dari halaman Node"
    echo "6. Jalankan Wings: systemctl start wings"
    echo ""
    echo -e "${GREEN}Terima kasih telah menggunakan Pterodactyl Auto Installer by ClouviaID!${NC}"
    echo ""
    
    return 0
}

print_wings_summary() {
    echo ""
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║                    🎉 INSTALASI WINGS BERHASIL! 🎉                       ║"
    echo "║                        ${INSTALLER_COPYRIGHT:-© ClouviaID}                                   ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo ""
    echo -e "${WHITE}FQDN Node:${NC}        ${CYAN}${FQDN}${NC}"
    echo ""
    echo -e "${WHITE}Komponen Terinstall:${NC}"
    echo -e "  Docker:         ${CYAN}$(docker --version 2>/dev/null | cut -d' ' -f3 | tr -d ',' || echo 'latest')${NC}"
    echo -e "  Wings:          ${CYAN}$(wings --version 2>/dev/null || echo 'latest')${NC}"
    echo -e "  OS:             ${CYAN}${OS_NAME} ${OS_VERSION}${NC}"
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}PENTING: Wings harus dikonfigurasi sebelum dijalankan!${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Langkah Selanjutnya:${NC}"
    echo "1. Buka Pterodactyl Panel Anda"
    echo "2. Buat Node baru (Admin > Nodes > Create New)"
    echo "3. Isi detail node:"
    echo "   - FQDN: ${FQDN}"
    echo "   - Use SSL: Yes"
    echo "4. Buka tab Configuration"
    echo "5. Klik 'Generate Token' dan salin perintah auto-deploy"
    echo "6. Jalankan perintah di server ini, ATAU buat manual:"
    echo "   ${CYAN}nano /etc/pterodactyl/config.yml${NC}"
    echo "7. Paste konfigurasi dari Panel"
    echo "8. Jalankan Wings:"
    echo "   ${CYAN}systemctl start wings${NC}"
    echo ""
    echo -e "${GREEN}Terima kasih telah menggunakan Pterodactyl Auto Installer by ClouviaID!${NC}"
    echo ""
    
    return 0
}

print_uninstall_complete() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    ✓ UNINSTALL SELESAI                                    ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Komponen berikut mungkin masih terinstall (tidak dihapus):${NC}"
    echo "  - PHP dan ekstensi"
    echo "  - MariaDB/MySQL"
    echo "  - Redis"
    echo "  - Nginx"
    echo "  - Docker"
    echo "  - Certbot"
    echo ""
    echo -e "${YELLOW}Untuk menghapus sepenuhnya, jalankan:${NC}"
    echo "  apt remove --purge php* mariadb-* redis-server nginx docker-ce -y"
    echo "  apt autoremove -y"
    echo ""
    
    return 0
}
