#!/bin/bash

declare -ga SPINNER_FRAMES_DOTS=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
declare -ga SPINNER_FRAMES_LINE=('|' '/' '-' '\')
declare -ga SPINNER_FRAMES_BOUNCE=('⠁' '⠂' '⠄' '⡀' '⢀' '⠠' '⠐' '⠈')
declare -ga SPINNER_FRAMES_ARROW=('←' '↖' '↑' '↗' '→' '↘' '↓' '↙')
declare -ga SPINNER_FRAMES_CIRCLE=('◐' '◓' '◑' '◒')

declare -g SPINNER_PID=""
declare -g SPINNER_ACTIVE=false

spinner_start() {
    local message="$1"
    local frames=("${SPINNER_FRAMES_DOTS[@]}")
    local delay=0.1
    local i=0
    
    SPINNER_ACTIVE=true
    
    while [[ "$SPINNER_ACTIVE" == "true" ]]; do
        local frame="${frames[$((i % ${#frames[@]}))]}"
        printf "\r${CYAN}  %s${NC} %s   " "$frame" "$message"
        i=$((i + 1))
        sleep $delay
    done &
    
    SPINNER_PID=$!
    
    return 0
}

spinner_stop() {
    local status="${1:-success}"
    
    SPINNER_ACTIVE=false
    
    if [[ -n "$SPINNER_PID" ]]; then
        kill "$SPINNER_PID" 2>/dev/null
        wait "$SPINNER_PID" 2>/dev/null
    fi
    
    printf "\r\033[K"
    
    SPINNER_PID=""
    
    return 0
}

run_with_spinner() {
    local message="$1"
    shift
    local command="$*"
    local start_time
    local elapsed
    
    start_time=$(date +%s)
    
    eval "$command" >> "$LOG_FILE" 2>&1 &
    local cmd_pid=$!
    
    local frames=("${SPINNER_FRAMES_DOTS[@]}")
    local i=0
    
    while kill -0 "$cmd_pid" 2>/dev/null; do
        elapsed=$(($(date +%s) - start_time))
        local frame="${frames[$((i % ${#frames[@]}))]}"
        printf "\r${CYAN}  %s${NC} %s ${WHITE}(%ds)${NC}   " "$frame" "$message" "$elapsed"
        i=$((i + 1))
        sleep 0.1
    done
    
    wait "$cmd_pid"
    local exit_code=$?
    
    elapsed=$(($(date +%s) - start_time))
    
    printf "\r\033[K"
    
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}  ✓${NC} ${message} ${WHITE}(completed in ${elapsed}s)${NC}"
        return 0
    else
        echo -e "${RED}  ✗${NC} ${message} ${WHITE}(failed after ${elapsed}s)${NC}"
        log_error "Command failed: $command"
        return $exit_code
    fi
}

run_silent() {
    local command="$1"
    
    eval "$command" >> "$LOG_FILE" 2>&1
    
    return $?
}

run_verbose() {
    local command="$1"
    
    eval "$command" 2>&1 | tee -a "$LOG_FILE"
    
    return "${PIPESTATUS[0]}"
}
