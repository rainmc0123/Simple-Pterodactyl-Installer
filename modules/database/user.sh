#!/bin/bash

create_admin_user() {
    print_section "Membuat User Admin"
    
    generate_admin_credentials
    insert_admin_to_database
    
    return 0
}

generate_admin_credentials() {
    ADMIN_PASSWORD=$(generate_simple_password 16)
    
    log_info "Membuat user administratif..."
    
    return 0
}

insert_admin_to_database() {
    local password_hash
    password_hash=$(php -r "echo password_hash('${ADMIN_PASSWORD}', PASSWORD_BCRYPT);")
    
    mysql -u root "${DB_NAME}" -e "
        INSERT INTO users (uuid, username, email, name_first, name_last, password, root_admin, created_at, updated_at)
        VALUES (
            UUID(),
            'admin',
            '${ADMIN_EMAIL}',
            'Admin',
            'User',
            '${password_hash}',
            1,
            NOW(),
            NOW()
        ) ON DUPLICATE KEY UPDATE
            password = '${password_hash}',
            root_admin = 1,
            updated_at = NOW();
    " >> "$LOG_FILE" 2>&1
    
    if [[ $? -eq 0 ]]; then
        log_success "User admin dibuat: $ADMIN_EMAIL"
    else
        log_error "Gagal membuat user admin via database!"
        create_admin_via_artisan
    fi
    
    return 0
}

create_admin_via_artisan() {
    log_info "Mencoba metode alternatif..."
    
    cd "$PANEL_PATH" || return 1
    
    php artisan p:user:make \
        --email="${ADMIN_EMAIL}" \
        --username="admin" \
        --name-first="Admin" \
        --name-last="User" \
        --password="${ADMIN_PASSWORD}" \
        --admin=1 \
        --no-interaction >> "$LOG_FILE" 2>&1 || true
    
    log_success "User admin dibuat dengan metode alternatif"
    
    return 0
}

update_admin_password() {
    local email="$1"
    local new_password="$2"
    
    local password_hash
    password_hash=$(php -r "echo password_hash('${new_password}', PASSWORD_BCRYPT);")
    
    mysql -u root "${DB_NAME}" -e "
        UPDATE users SET password = '${password_hash}', updated_at = NOW() WHERE email = '${email}';
    " >> "$LOG_FILE" 2>&1
    
    return $?
}

get_admin_count() {
    mysql -u root "${DB_NAME}" -sN -e "SELECT COUNT(*) FROM users WHERE root_admin = 1;" 2>/dev/null
}

list_admin_users() {
    mysql -u root "${DB_NAME}" -e "SELECT id, username, email FROM users WHERE root_admin = 1;" 2>/dev/null
}
