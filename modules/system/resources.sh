#!/bin/bash

check_resources() {
    print_section "Memeriksa Sumber Daya Sistem"
    
    check_ram
    check_disk_space
    check_cpu
    
    return 0
}

check_ram() {
    TOTAL_RAM_MB=$(free -m | awk '/^Mem:/{print $2}')
    log_info "Total RAM: ${TOTAL_RAM_MB}MB"
    
    if [[ "$TOTAL_RAM_MB" -lt "${MINIMUM_RAM_MB:-1024}" ]]; then
        log_warning "RAM kurang dari 1GB terdeteksi. Instalasi mungkin gagal."
        confirm_action "Minimum 2GB RAM direkomendasikan untuk Pterodactyl."
    elif [[ "$TOTAL_RAM_MB" -lt "${RECOMMENDED_RAM_MB:-2048}" ]]; then
        log_warning "RAM kurang dari 2GB terdeteksi. Performa mungkin terpengaruh."
    else
        log_success "RAM: ${TOTAL_RAM_MB}MB (OK)"
    fi
    
    return 0
}

check_disk_space() {
    FREE_DISK_GB=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    log_info "Ruang disk tersedia: ${FREE_DISK_GB}GB"
    
    if [[ "$FREE_DISK_GB" -lt "${MINIMUM_DISK_GB:-5}" ]]; then
        log_error "Ruang disk kurang dari 5GB. Tidak dapat melanjutkan."
        exit 1
    elif [[ "$FREE_DISK_GB" -lt "${RECOMMENDED_DISK_GB:-10}" ]]; then
        log_warning "Ruang disk kurang dari 10GB. Pertimbangkan untuk menambah storage."
    else
        log_success "Ruang disk: ${FREE_DISK_GB}GB (OK)"
    fi
    
    return 0
}

check_cpu() {
    CPU_CORES=$(nproc 2>/dev/null || grep -c ^processor /proc/cpuinfo 2>/dev/null || echo "1")
    log_info "CPU Cores: $CPU_CORES"
    
    if [[ "$CPU_CORES" -lt 1 ]]; then
        log_warning "Tidak dapat mendeteksi jumlah CPU cores"
    else
        log_success "CPU: $CPU_CORES core(s) (OK)"
    fi
    
    return 0
}

get_total_ram() {
    free -m | awk '/^Mem:/{print $2}'
}

get_free_ram() {
    free -m | awk '/^Mem:/{print $7}'
}

get_used_ram() {
    free -m | awk '/^Mem:/{print $3}'
}

get_swap_total() {
    free -m | awk '/^Swap:/{print $2}'
}

get_swap_used() {
    free -m | awk '/^Swap:/{print $3}'
}

get_load_average() {
    cat /proc/loadavg | awk '{print $1, $2, $3}'
}

get_uptime() {
    uptime -p 2>/dev/null || uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}'
}

resource_summary() {
    local summary=""
    
    summary+="RAM: $(get_used_ram)MB / $(get_total_ram)MB\n"
    summary+="Disk: $(get_free_space /)GB free\n"
    summary+="CPU: $CPU_CORES core(s)\n"
    summary+="Load: $(get_load_average)\n"
    summary+="Uptime: $(get_uptime)\n"
    
    echo -e "$summary"
}
