#!/bin/bash

declare -gr COLOR_RED='\033[0;31m'
declare -gr COLOR_GREEN='\033[0;32m'
declare -gr COLOR_YELLOW='\033[1;33m'
declare -gr COLOR_BLUE='\033[0;34m'
declare -gr COLOR_PURPLE='\033[0;35m'
declare -gr COLOR_CYAN='\033[0;36m'
declare -gr COLOR_WHITE='\033[1;37m'
declare -gr COLOR_GRAY='\033[0;37m'
declare -gr COLOR_DARK_GRAY='\033[1;30m'
declare -gr COLOR_LIGHT_RED='\033[1;31m'
declare -gr COLOR_LIGHT_GREEN='\033[1;32m'
declare -gr COLOR_LIGHT_BLUE='\033[1;34m'
declare -gr COLOR_LIGHT_PURPLE='\033[1;35m'
declare -gr COLOR_LIGHT_CYAN='\033[1;36m'
declare -gr COLOR_NC='\033[0m'

declare -gr STYLE_BOLD='\033[1m'
declare -gr STYLE_DIM='\033[2m'
declare -gr STYLE_UNDERLINE='\033[4m'
declare -gr STYLE_BLINK='\033[5m'
declare -gr STYLE_REVERSE='\033[7m'
declare -gr STYLE_HIDDEN='\033[8m'
declare -gr STYLE_RESET='\033[0m'

declare -gr BG_BLACK='\033[40m'
declare -gr BG_RED='\033[41m'
declare -gr BG_GREEN='\033[42m'
declare -gr BG_YELLOW='\033[43m'
declare -gr BG_BLUE='\033[44m'
declare -gr BG_PURPLE='\033[45m'
declare -gr BG_CYAN='\033[46m'
declare -gr BG_WHITE='\033[47m'

RED="$COLOR_RED"
GREEN="$COLOR_GREEN"
YELLOW="$COLOR_YELLOW"
BLUE="$COLOR_BLUE"
PURPLE="$COLOR_PURPLE"
CYAN="$COLOR_CYAN"
WHITE="$COLOR_WHITE"
NC="$COLOR_NC"

colorize() {
    local color="$1"
    local text="$2"
    
    echo -e "${color}${text}${COLOR_NC}"
}

strip_colors() {
    local text="$1"
    
    echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g'
}

supports_colors() {
    if [[ -t 1 ]]; then
        local colors=$(tput colors 2>/dev/null)
        if [[ -n "$colors" ]] && [[ "$colors" -ge 8 ]]; then
            return 0
        fi
    fi
    
    return 1
}

disable_colors() {
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    PURPLE=""
    CYAN=""
    WHITE=""
    NC=""
}
