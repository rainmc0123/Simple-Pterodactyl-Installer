#!/bin/bash

migrate_database() {
    print_section "Migrasi Database"
    
    run_migrations
    
    log_success "Migrasi database selesai"
    
    return 0
}

run_migrations() {
    cd "$PANEL_PATH" || return 1
    
    run_with_spinner "Menjalankan migrasi database" "php artisan migrate --seed --force --no-interaction"
    
    return $?
}

run_migrations_only() {
    cd "$PANEL_PATH" || return 1
    
    php artisan migrate --force --no-interaction >> "$LOG_FILE" 2>&1
    
    return $?
}

run_seeders() {
    cd "$PANEL_PATH" || return 1
    
    php artisan db:seed --force --no-interaction >> "$LOG_FILE" 2>&1
    
    return $?
}

rollback_migration() {
    local steps="${1:-1}"
    
    cd "$PANEL_PATH" || return 1
    
    php artisan migrate:rollback --step="$steps" --force --no-interaction >> "$LOG_FILE" 2>&1
    
    return $?
}

reset_database() {
    cd "$PANEL_PATH" || return 1
    
    php artisan migrate:reset --force --no-interaction >> "$LOG_FILE" 2>&1
    
    return $?
}

refresh_database() {
    cd "$PANEL_PATH" || return 1
    
    php artisan migrate:refresh --seed --force --no-interaction >> "$LOG_FILE" 2>&1
    
    return $?
}

check_migration_status() {
    cd "$PANEL_PATH" || return 1
    
    php artisan migrate:status --no-interaction 2>/dev/null
}

get_pending_migrations() {
    cd "$PANEL_PATH" || return 1
    
    php artisan migrate:status --no-interaction 2>/dev/null | grep -c "No" || echo "0"
}
