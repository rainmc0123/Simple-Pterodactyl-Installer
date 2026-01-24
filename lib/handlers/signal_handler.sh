#!/bin/bash

declare -g SIGNAL_HANDLERS_INSTALLED=false
declare -g INTERRUPTED=false

install_signal_handlers() {
    if [[ "$SIGNAL_HANDLERS_INSTALLED" == "true" ]]; then
        return 0
    fi
    
    trap 'handle_sigint' SIGINT
    trap 'handle_sigterm' SIGTERM
    trap 'handle_sighup' SIGHUP
    trap 'handle_sigquit' SIGQUIT
    
    SIGNAL_HANDLERS_INSTALLED=true
    
    return 0
}

remove_signal_handlers() {
    trap - SIGINT SIGTERM SIGHUP SIGQUIT
    
    SIGNAL_HANDLERS_INSTALLED=false
    
    return 0
}

handle_sigint() {
    INTERRUPTED=true
    
    echo ""
    log_warning "Installation interrupted by user (SIGINT)"
    
    cleanup_on_interrupt
    
    exit 130
}

handle_sigterm() {
    INTERRUPTED=true
    
    log_warning "Installation terminated (SIGTERM)"
    
    cleanup_on_interrupt
    
    exit 143
}

handle_sighup() {
    log_warning "Hangup signal received (SIGHUP)"
    
    return 0
}

handle_sigquit() {
    INTERRUPTED=true
    
    log_warning "Quit signal received (SIGQUIT)"
    
    cleanup_on_interrupt
    
    exit 131
}

cleanup_on_interrupt() {
    log_info "Performing cleanup after interrupt..."
    
    spinner_stop 2>/dev/null || true
    
    local running_jobs
    running_jobs=$(jobs -p 2>/dev/null)
    if [[ -n "$running_jobs" ]]; then
        kill $running_jobs 2>/dev/null || true
        wait $running_jobs 2>/dev/null || true
    fi
    
    close_logging 2>/dev/null || true
    
    return 0
}

is_interrupted() {
    [[ "$INTERRUPTED" == "true" ]]
}

check_interrupt() {
    if is_interrupted; then
        log_error "Installation was interrupted"
        exit 130
    fi
    
    return 0
}
