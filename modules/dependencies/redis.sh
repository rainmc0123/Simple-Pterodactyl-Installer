#!/bin/bash

install_redis() {
    print_section "Menginstall Redis"
    
    add_redis_repository
    install_redis_packages
    configure_redis
    start_redis_service
    
    log_success "Redis berhasil diinstall"
    
    return 0
}

add_redis_repository() {
    run_with_spinner "Menambahkan repositori Redis" "curl -fsSL https://packages.redis.io/gpg | gpg --batch --yes --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg"
    
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" > /etc/apt/sources.list.d/redis.list
    
    run_with_spinner "Memperbarui daftar paket" "apt-get update -y"
    
    return 0
}

install_redis_packages() {
    run_with_spinner "Menginstall Redis server" "apt-get -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install redis-server"
    
    return $?
}

configure_redis() {
    local redis_conf="/etc/redis/redis.conf"
    
    if [[ -f "$redis_conf" ]]; then
        sed -i 's/^supervised no/supervised systemd/' "$redis_conf" 2>/dev/null || true
    fi
    
    return 0
}

start_redis_service() {
    start_service "redis-server"
    enable_service "redis-server"
    
    return 0
}

redis_cli() {
    local command="$1"
    
    redis-cli $command 2>/dev/null
}

redis_ping() {
    local response
    response=$(redis-cli ping 2>/dev/null)
    
    [[ "$response" == "PONG" ]]
}

redis_flush_all() {
    redis-cli FLUSHALL >> "$LOG_FILE" 2>&1
    
    return $?
}

get_redis_version() {
    redis-server --version 2>/dev/null | awk '{print $3}' | cut -d'=' -f2
}

verify_redis_installation() {
    if is_service_active "redis-server"; then
        log_success "Redis berjalan"
        return 0
    fi
    
    log_error "Redis tidak berjalan"
    return 1
}

test_redis_connection() {
    local host="${1:-127.0.0.1}"
    local port="${2:-6379}"
    
    redis-cli -h "$host" -p "$port" ping &>/dev/null
}
