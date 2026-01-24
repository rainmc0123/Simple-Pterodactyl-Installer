#!/bin/bash

declare -g LOG_INITIALIZED=false

init_logging() {
    local log_dir
    log_dir="$(dirname "$LOG_FILE")"
    
    mkdir -p "$log_dir" 2>/dev/null
    
    echo "═══════════════════════════════════════════════════════════════════════════" > "$LOG_FILE"
    echo "PTERODACTYL INSTALLER LOG" >> "$LOG_FILE"
    echo "Started: $(date)" >> "$LOG_FILE"
    echo "Installer Version: ${INSTALLER_VERSION:-1.0.0}" >> "$LOG_FILE"
    echo "═══════════════════════════════════════════════════════════════════════════" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    
    LOG_INITIALIZED=true
    
    return 0
}

write_log() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp="$(date +'%Y-%m-%d %H:%M:%S')"
    
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE" 2>/dev/null
    
    return 0
}

log() {
    local message="$1"
    
    echo -e "${WHITE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $message"
    write_log "LOG" "$(strip_colors "$message")"
    
    return 0
}

log_info() {
    local message="$1"
    
    echo -e "${BLUE}[INFO]${NC} $message"
    write_log "INFO" "$(strip_colors "$message")"
    
    return 0
}

log_success() {
    local message="$1"
    
    echo -e "${GREEN}[SUCCESS]${NC} $message"
    write_log "SUCCESS" "$(strip_colors "$message")"
    
    return 0
}

log_warning() {
    local message="$1"
    
    echo -e "${YELLOW}[WARNING]${NC} $message"
    write_log "WARNING" "$(strip_colors "$message")"
    
    return 0
}

log_error() {
    local message="$1"
    
    echo -e "${RED}[ERROR]${NC} $message"
    write_log "ERROR" "$(strip_colors "$message")"
    
    return 0
}

log_debug() {
    local message="$1"
    
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${GRAY}[DEBUG]${NC} $message"
    fi
    write_log "DEBUG" "$(strip_colors "$message")"
    
    return 0
}

log_fatal() {
    local message="$1"
    local exit_code="${2:-1}"
    
    echo -e "${RED}[FATAL]${NC} $message"
    write_log "FATAL" "$(strip_colors "$message")"
    
    exit "$exit_code"
}

log_section() {
    local title="$1"
    
    echo "" | tee -a "$LOG_FILE"
    echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
    echo -e "${WHITE}  ${title}${NC}" | tee -a "$LOG_FILE"
    echo -e "${PURPLE}══════════════════════════════════════════════════════════════════════════${NC}" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    
    return 0
}

log_command_output() {
    local command="$1"
    
    echo "--- Command: $command ---" >> "$LOG_FILE"
    eval "$command" >> "$LOG_FILE" 2>&1
    local exit_code=$?
    echo "--- Exit Code: $exit_code ---" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    
    return $exit_code
}

close_logging() {
    echo "" >> "$LOG_FILE"
    echo "═══════════════════════════════════════════════════════════════════════════" >> "$LOG_FILE"
    echo "Log closed: $(date)" >> "$LOG_FILE"
    echo "Final Status: ${INSTALL_STATUS:-UNKNOWN}" >> "$LOG_FILE"
    echo "═══════════════════════════════════════════════════════════════════════════" >> "$LOG_FILE"
    
    return 0
}
