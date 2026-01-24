#!/bin/bash

declare -g EXIT_HANDLER_INSTALLED=false
declare -ga EXIT_CALLBACKS=()

install_exit_handler() {
    if [[ "$EXIT_HANDLER_INSTALLED" == "true" ]]; then
        return 0
    fi
    
    trap 'handle_exit $?' EXIT
    
    EXIT_HANDLER_INSTALLED=true
    
    return 0
}

remove_exit_handler() {
    trap - EXIT
    
    EXIT_HANDLER_INSTALLED=false
    
    return 0
}

register_exit_callback() {
    local callback="$1"
    
    EXIT_CALLBACKS+=("$callback")
    
    return 0
}

handle_exit() {
    local exit_code="$1"
    
    for callback in "${EXIT_CALLBACKS[@]}"; do
        eval "$callback" 2>/dev/null || true
    done
    
    if [[ $exit_code -eq 0 ]]; then
        write_log "EXIT" "Installation completed successfully"
    else
        write_log "EXIT" "Installation exited with code: $exit_code"
    fi
    
    close_logging 2>/dev/null || true
    
    return 0
}

exit_success() {
    local message="${1:-Installation completed successfully}"
    
    log_success "$message"
    
    INSTALL_STATUS="${STATUS_SUCCESS:-SUCCESS}"
    
    exit 0
}

exit_failure() {
    local message="${1:-Installation failed}"
    local exit_code="${2:-1}"
    
    log_error "$message"
    
    INSTALL_STATUS="${STATUS_FAILED:-FAILED}"
    
    exit "$exit_code"
}

exit_user_abort() {
    local message="${1:-Installation cancelled by user}"
    
    log_warning "$message"
    
    INSTALL_STATUS="${STATUS_FAILED:-FAILED}"
    
    exit "${EXIT_USER_ABORT:-2}"
}
