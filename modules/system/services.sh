#!/bin/bash

start_service() {
    local service_name="$1"
    
    systemctl start "$service_name" >> "$LOG_FILE" 2>&1
    
    return $?
}

stop_service() {
    local service_name="$1"
    
    systemctl stop "$service_name" >> "$LOG_FILE" 2>&1
    
    return $?
}

restart_service() {
    local service_name="$1"
    
    systemctl restart "$service_name" >> "$LOG_FILE" 2>&1
    
    return $?
}

reload_service() {
    local service_name="$1"
    
    systemctl reload "$service_name" >> "$LOG_FILE" 2>&1
    
    return $?
}

enable_service() {
    local service_name="$1"
    
    systemctl enable "$service_name" >> "$LOG_FILE" 2>&1
    
    return $?
}

disable_service() {
    local service_name="$1"
    
    systemctl disable "$service_name" >> "$LOG_FILE" 2>&1
    
    return $?
}

is_service_active() {
    local service_name="$1"
    
    systemctl is-active --quiet "$service_name"
}

is_service_enabled() {
    local service_name="$1"
    
    systemctl is-enabled --quiet "$service_name"
}

get_service_status() {
    local service_name="$1"
    
    systemctl status "$service_name" 2>/dev/null
}

reload_systemd() {
    systemctl daemon-reload >> "$LOG_FILE" 2>&1
    
    return $?
}

create_service_file() {
    local service_name="$1"
    local content="$2"
    local service_path="/etc/systemd/system/${service_name}.service"
    
    echo "$content" > "$service_path"
    chmod 644 "$service_path"
    reload_systemd
    
    return $?
}

remove_service_file() {
    local service_name="$1"
    local service_path="/etc/systemd/system/${service_name}.service"
    
    if [[ -f "$service_path" ]]; then
        stop_service "$service_name"
        disable_service "$service_name"
        rm -f "$service_path"
        reload_systemd
    fi
    
    return 0
}

verify_service_running() {
    local service_name="$1"
    local display_name="${2:-$service_name}"
    
    if is_service_active "$service_name"; then
        log_success "$display_name berjalan"
        return 0
    else
        log_error "$display_name tidak berjalan"
        return 1
    fi
}
