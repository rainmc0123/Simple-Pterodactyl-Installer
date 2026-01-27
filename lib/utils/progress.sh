#!/bin/bash

declare -gr PROGRESS_BAR_WIDTH=40
declare -gr PROGRESS_CHAR_FILLED="█"
declare -gr PROGRESS_CHAR_PARTIAL="▓"
declare -gr PROGRESS_CHAR_EMPTY="░"

show_progress() {
    local current="$1"
    local total="$2"
    local step_name="$3"
    
    local percent=$((current * 100 / total))
    local filled=$((percent * PROGRESS_BAR_WIDTH / 100))
    local empty=$((PROGRESS_BAR_WIDTH - filled))
    
    local bar=""
    local i
    for ((i=0; i<filled; i++)); do
        bar+="${PROGRESS_CHAR_FILLED}"
    done
    for ((i=0; i<empty; i++)); do
        bar+="${PROGRESS_CHAR_EMPTY}"
    done
    
    local elapsed=0
    if [[ -n "$START_TIME" ]]; then
        elapsed=$(($(date +%s) - START_TIME))
    fi
    local elapsed_min=$((elapsed / 60))
    local elapsed_sec=$((elapsed % 60))
    
    local eta="--:--"
    if [[ "$current" -gt 0 ]] && [[ "$elapsed" -gt 0 ]]; then
        local remaining=$(( (elapsed * (total - current)) / current ))
        local eta_min=$((remaining / 60))
        local eta_sec=$((remaining % 60))
        eta=$(printf "%02d:%02d" "$eta_min" "$eta_sec")
    fi
    
    # Futuristic progress display
    echo ""
    echo -e "    ${NEON_CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}  ${NEON_BLUE}⚡${NC} ${STYLE_BOLD}${WHITE}STEP ${current}/${total}${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}  ${DIM}[${NC}${NEON_GREEN}${bar}${NC}${DIM}]${NC} ${WHITE}${percent}%${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}  ${NEON_CYAN}▸${NC} ${WHITE}${step_name}${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}  ${DIM}Elapsed:${NC} ${WHITE}$(printf "%02d:%02d" "$elapsed_min" "$elapsed_sec")${NC}  ${DIM}│${NC}  ${DIM}ETA:${NC} ${WHITE}${eta}${NC}"
    echo -e "    ${NEON_CYAN}┃${NC}"
    
    return 0
}

print_section() {
    local title="$1"
    
    CURRENT_STEP=$((CURRENT_STEP + 1))
    show_progress "$CURRENT_STEP" "$TOTAL_STEPS" "$title"
    echo ""
    
    return 0
}

update_progress() {
    local step="$1"
    local message="$2"
    
    CURRENT_STEP="$step"
    show_progress "$CURRENT_STEP" "$TOTAL_STEPS" "$message"
    
    return 0
}

reset_progress() {
    CURRENT_STEP=0
    START_TIME=$(date +%s)
    
    return 0
}

calculate_eta() {
    local current="$1"
    local total="$2"
    local elapsed="$3"
    
    if [[ "$current" -eq 0 ]] || [[ "$elapsed" -eq 0 ]]; then
        echo "--:--"
        return
    fi
    
    local remaining=$(( (elapsed * (total - current)) / current ))
    local eta_min=$((remaining / 60))
    local eta_sec=$((remaining % 60))
    
    printf "%02d:%02d" "$eta_min" "$eta_sec"
}

format_duration() {
    local seconds="$1"
    
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))
    
    if [[ "$hours" -gt 0 ]]; then
        printf "%dh %dm %ds" "$hours" "$minutes" "$secs"
    elif [[ "$minutes" -gt 0 ]]; then
        printf "%dm %ds" "$minutes" "$secs"
    else
        printf "%ds" "$secs"
    fi
}
