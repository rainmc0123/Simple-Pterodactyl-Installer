#!/bin/bash

collect_telemetry_data() {
    local data=""
    
    data=$(cat <<TELEMETRY_DATA
{
    "domain": "${FQDN}",
    "os": "${OS_NAME}",
    "os_version": "${OS_VERSION}",
    "php_version": "${PHP_VERSION}",
    "panel_version": "${PANEL_VERSION}",
    "installer_version": "${INSTALLER_VERSION}",
    "install_mode": "${INSTALL_MODE}",
    "install_status": "${INSTALL_STATUS}",
    "virt_type": "${VIRT_TYPE}",
    "ram_mb": "${TOTAL_RAM_MB}",
    "disk_gb": "${FREE_DISK_GB}",
    "cpu_cores": "${CPU_CORES}",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
TELEMETRY_DATA
)
    
    echo "$data"
}

anonymize_telemetry() {
    local data="$1"
    
    data=$(echo "$data" | sed 's/"domain": "[^"]*"/"domain": "anonymous"/g')
    
    echo "$data"
}

get_installation_metrics() {
    local metrics=""
    
    if [[ -n "$START_TIME" ]]; then
        local end_time
        end_time=$(date +%s)
        local duration=$((end_time - START_TIME))
        
        metrics+="\"duration_seconds\": $duration,"
    fi
    
    echo "$metrics"
}

prepare_telemetry_payload() {
    local telemetry_data
    telemetry_data=$(collect_telemetry_data)
    
    echo "$telemetry_data"
}
