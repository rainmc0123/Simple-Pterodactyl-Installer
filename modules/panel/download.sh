#!/bin/bash

download_panel() {
    print_section "Mengunduh Pterodactyl Panel"
    
    prepare_panel_directory
    fetch_panel_release
    extract_panel_files
    detect_panel_version
    
    log_success "Panel berhasil diunduh: v${PANEL_VERSION}"
    
    return 0
}

prepare_panel_directory() {
    mkdir -p "$PANEL_PATH"
    cd "$PANEL_PATH" || exit 1
    
    return 0
}

fetch_panel_release() {
    run_with_spinner "Mengunduh rilis panel terbaru" "curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz"
    
    return $?
}

extract_panel_files() {
    run_with_spinner "Mengekstrak file panel" "tar -xzf panel.tar.gz"
    rm -f panel.tar.gz
    
    chmod -R 755 storage/* bootstrap/cache/
    
    return 0
}

detect_panel_version() {
    if [[ -f "$PANEL_PATH/composer.json" ]]; then
        PANEL_VERSION=$(grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$PANEL_PATH/composer.json" 2>/dev/null | head -1 | cut -d'"' -f4 || echo "1.11.x")
    fi
    
    if [[ -z "$PANEL_VERSION" ]] || [[ "$PANEL_VERSION" == "version" ]]; then
        PANEL_VERSION="1.11.x"
    fi
    
    return 0
}

check_panel_exists() {
    [[ -d "$PANEL_PATH" ]] && [[ -f "$PANEL_PATH/artisan" ]]
}

get_panel_version() {
    if [[ -f "$PANEL_PATH/config/app.php" ]]; then
        grep "'version'" "$PANEL_PATH/config/app.php" 2>/dev/null | grep -oP "'\K[^']+(?=')" | head -1
    fi
}

backup_panel() {
    local backup_path="${1:-/root/pterodactyl-panel-backup-$(date +%Y%m%d%H%M%S).tar.gz}"
    
    if [[ -d "$PANEL_PATH" ]]; then
        tar -czf "$backup_path" -C "$(dirname "$PANEL_PATH")" "$(basename "$PANEL_PATH")" 2>/dev/null
        return $?
    fi
    
    return 1
}

remove_panel_files() {
    if [[ -d "$PANEL_PATH" ]]; then
        rm -rf "$PANEL_PATH"
    fi
    
    return 0
}
