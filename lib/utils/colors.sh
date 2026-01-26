#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
# FUTURISTIC COLOR SCHEME - PTERO INSTALLER v2.0
# ═══════════════════════════════════════════════════════════════════════════════

# Base Colors
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

# 256 Color Mode - Futuristic Palette
declare -gr NEON_BLUE='\033[38;5;39m'
declare -gr NEON_CYAN='\033[38;5;51m'
declare -gr NEON_GREEN='\033[38;5;46m'
declare -gr NEON_PINK='\033[38;5;199m'
declare -gr NEON_PURPLE='\033[38;5;129m'
declare -gr NEON_ORANGE='\033[38;5;208m'
declare -gr ELECTRIC_BLUE='\033[38;5;33m'
declare -gr MATRIX_GREEN='\033[38;5;47m'
declare -gr CYBER_YELLOW='\033[38;5;226m'
declare -gr STEEL_GRAY='\033[38;5;245m'
declare -gr DARK_STEEL='\033[38;5;238m'

# Styles
declare -gr STYLE_BOLD='\033[1m'
declare -gr STYLE_DIM='\033[2m'
declare -gr STYLE_UNDERLINE='\033[4m'
declare -gr STYLE_BLINK='\033[5m'
declare -gr STYLE_REVERSE='\033[7m'
declare -gr STYLE_HIDDEN='\033[8m'
declare -gr STYLE_RESET='\033[0m'

# Background Colors
declare -gr BG_BLACK='\033[40m'
declare -gr BG_RED='\033[41m'
declare -gr BG_GREEN='\033[42m'
declare -gr BG_YELLOW='\033[43m'
declare -gr BG_BLUE='\033[44m'
declare -gr BG_PURPLE='\033[45m'
declare -gr BG_CYAN='\033[46m'
declare -gr BG_WHITE='\033[47m'

# Theme Colors (Futuristic)
RED="$COLOR_LIGHT_RED"
GREEN="$NEON_GREEN"
YELLOW="$CYBER_YELLOW"
BLUE="$ELECTRIC_BLUE"
PURPLE="$NEON_PURPLE"
CYAN="$NEON_CYAN"
WHITE="$COLOR_WHITE"
NC="$COLOR_NC"
ACCENT="$NEON_BLUE"
HIGHLIGHT="$NEON_PINK"
DIM="$STEEL_GRAY"

# Box Drawing Characters
declare -gr BOX_TL="╭"
declare -gr BOX_TR="╮"
declare -gr BOX_BL="╰"
declare -gr BOX_BR="╯"
declare -gr BOX_H="─"
declare -gr BOX_V="│"

# Decorative Characters
declare -gr ARROW="▸"
declare -gr BULLET="●"
declare -gr DIAMOND="◆"
declare -gr CHECK="✓"
declare -gr CROSS="✗"
declare -gr GEAR="⚙"
declare -gr BOLT="⚡"

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
    ACCENT=""
    HIGHLIGHT=""
    DIM=""
}
