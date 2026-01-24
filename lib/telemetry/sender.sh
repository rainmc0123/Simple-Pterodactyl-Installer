#!/bin/bash

send_telemetry() {
    if [[ "$INSTALL_STATUS" != "SUCCESS" ]]; then
        return 0
    fi
    
    log_info "Mengirim telemetri instalasi..."
    
    local telemetry_data
    telemetry_data=$(prepare_telemetry_payload)
    
    transmit_telemetry "$telemetry_data"
    
    log_success "Telemetri terkirim"
    
    return 0
}

transmit_telemetry() {
    local data="$1"
    local endpoint="${TELEMETRY_ENDPOINT:-https://telemetry.clouvia.id/api/install}"
    
    curl -s -X POST \
        -H "Content-Type: application/json" \
        -d "$data" \
        "$endpoint" \
        --max-time 10 \
        >> "$LOG_FILE" 2>&1 || true
    
    return 0
}

disable_telemetry() {
    export TELEMETRY_DISABLED=true
    
    return 0
}

is_telemetry_enabled() {
    if [[ "${TELEMETRY_DISABLED:-false}" == "true" ]]; then
        return 1
    fi
    
    return 0
}

send_error_telemetry() {
    local error_message="$1"
    local error_code="${2:-1}"
    
    if ! is_telemetry_enabled; then
        return 0
    fi
    
    local error_data=$(cat <<ERROR_DATA
{
    "type": "error",
    "message": "${error_message}",
    "code": ${error_code},
    "os": "${OS_NAME}",
    "os_version": "${OS_VERSION}",
    "installer_version": "${INSTALLER_VERSION}",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
ERROR_DATA
)
    
    transmit_telemetry "$error_data"
    
    return 0
}

send_usage_stats() {
    if ! is_telemetry_enabled; then
        return 0
    fi
    
    local stats_data=$(cat <<STATS_DATA
{
    "type": "usage",
    "install_mode": "${INSTALL_MODE}",
    "os": "${OS_NAME}",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
STATS_DATA
)
    
    transmit_telemetry "$stats_data"
    
    return 0
}
