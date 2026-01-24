#!/bin/bash

declare -g LAST_ERROR_CODE=0
declare -g LAST_ERROR_LINE=0
declare -g LAST_ERROR_COMMAND=""
declare -g ERROR_HANDLING_ENABLED=true

enable_error_handling() {
    ERROR_HANDLING_ENABLED=true
    trap 'handle_error $? $LINENO "$BASH_COMMAND"' ERR
    
    return 0
}

disable_error_handling() {
    ERROR_HANDLING_ENABLED=false
    trap - ERR
    
    return 0
}

handle_error() {
    local exit_code="$1"
    local line_number="$2"
    local command="$3"
    
    LAST_ERROR_CODE="$exit_code"
    LAST_ERROR_LINE="$line_number"
    LAST_ERROR_COMMAND="$command"
    
    if [[ "$ERROR_HANDLING_ENABLED" != "true" ]]; then
        return 0
    fi
    
    write_log "ERROR" "Error occurred at line $line_number: $command (exit code: $exit_code)"
    
    return 0
}

error_exit() {
    local message="$1"
    local exit_code="${2:-1}"
    
    log_error "$message"
    log_error "Check log file for details: $LOG_FILE"
    
    INSTALL_STATUS="${STATUS_FAILED:-FAILED}"
    
    cleanup_on_error
    
    exit "$exit_code"
}

get_last_error() {
    echo "Code: $LAST_ERROR_CODE, Line: $LAST_ERROR_LINE, Command: $LAST_ERROR_COMMAND"
}

try_command() {
    local command="$1"
    local error_message="${2:-Command failed}"
    
    disable_error_handling
    
    eval "$command" >> "$LOG_FILE" 2>&1
    local result=$?
    
    enable_error_handling
    
    if [[ $result -ne 0 ]]; then
        log_error "$error_message"
        return $result
    fi
    
    return 0
}

cleanup_on_error() {
    log_info "Performing cleanup after error..."
    
    spinner_stop 2>/dev/null || true
    
    close_logging 2>/dev/null || true
    
    return 0
}

assert_success() {
    local exit_code="$1"
    local message="${2:-Assertion failed}"
    
    if [[ "$exit_code" -ne 0 ]]; then
        error_exit "$message" "$exit_code"
    fi
    
    return 0
}

assert_not_empty() {
    local value="$1"
    local name="${2:-value}"
    
    if [[ -z "$value" ]]; then
        error_exit "$name cannot be empty"
    fi
    
    return 0
}

assert_file_exists() {
    local file_path="$1"
    
    if [[ ! -f "$file_path" ]]; then
        error_exit "Required file not found: $file_path"
    fi
    
    return 0
}

assert_directory_exists() {
    local dir_path="$1"
    
    if [[ ! -d "$dir_path" ]]; then
        error_exit "Required directory not found: $dir_path"
    fi
    
    return 0
}

assert_command_exists() {
    local command="$1"
    
    if ! command -v "$command" &>/dev/null; then
        error_exit "Required command not found: $command"
    fi
    
    return 0
}
