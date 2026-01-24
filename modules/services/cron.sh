#!/bin/bash

setup_cron() {
    print_section "Menyiapkan Cron Job"
    
    add_pterodactyl_cron
    
    log_success "Cron job berhasil dikonfigurasi"
    
    return 0
}

add_pterodactyl_cron() {
    log_info "Menambahkan cron job untuk scheduled tasks..."
    
    local cron_job="* * * * * php ${PANEL_PATH}/artisan schedule:run >> /dev/null 2>&1"
    
    (crontab -l 2>/dev/null | grep -v "pterodactyl/artisan schedule:run"; echo "$cron_job") | crontab -
    
    return 0
}

remove_pterodactyl_cron() {
    log_info "Menghapus cron job Pterodactyl..."
    
    crontab -l 2>/dev/null | grep -v "pterodactyl" | crontab - 2>/dev/null || true
    
    return 0
}

list_cron_jobs() {
    crontab -l 2>/dev/null
}

verify_cron_setup() {
    if crontab -l 2>/dev/null | grep -q "pterodactyl/artisan schedule:run"; then
        log_success "Cron job Pterodactyl aktif"
        return 0
    fi
    
    log_warning "Cron job Pterodactyl tidak ditemukan"
    return 1
}

run_scheduler_manually() {
    cd "$PANEL_PATH" || return 1
    
    php artisan schedule:run >> "$LOG_FILE" 2>&1
    
    return $?
}

list_scheduled_tasks() {
    cd "$PANEL_PATH" || return 1
    
    php artisan schedule:list 2>/dev/null
}

test_scheduler() {
    cd "$PANEL_PATH" || return 1
    
    php artisan schedule:test --no-interaction 2>/dev/null
    
    return $?
}
