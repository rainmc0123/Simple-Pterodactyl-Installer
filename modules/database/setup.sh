#!/bin/bash

setup_database() {
    print_section "Menyiapkan Database"
    
    generate_database_credentials
    create_pterodactyl_database
    create_pterodactyl_user
    grant_pterodactyl_privileges
    
    return 0
}

generate_database_credentials() {
    DB_PASSWORD=$(generate_simple_password 24)
    
    log_info "Membuat database dan user..."
    
    return 0
}

create_pterodactyl_database() {
    create_database "$DB_NAME"
    
    if [[ $? -eq 0 ]]; then
        log_success "Database '${DB_NAME}' berhasil dibuat"
    else
        log_error "Gagal membuat database!"
        exit 1
    fi
    
    return 0
}

create_pterodactyl_user() {
    create_database_user "$DB_USER" "$DB_PASSWORD" "$DB_HOST"
    
    if [[ $? -eq 0 ]]; then
        log_success "User '${DB_USER}' dibuat dengan password yang aman"
    else
        log_error "Gagal membuat user database!"
        exit 1
    fi
    
    return 0
}

grant_pterodactyl_privileges() {
    grant_database_privileges "$DB_USER" "$DB_NAME" "$DB_HOST"
    
    return $?
}

verify_database_setup() {
    if test_database_connection "$DB_USER" "$DB_PASSWORD" "$DB_HOST" "$DB_NAME"; then
        log_success "Koneksi database berhasil"
        return 0
    fi
    
    log_error "Gagal terkoneksi ke database"
    return 1
}
