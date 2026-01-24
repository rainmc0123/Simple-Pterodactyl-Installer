#!/bin/bash

ensure_directory() {
    local dir_path="$1"
    local mode="${2:-755}"
    local owner="${3:-}"
    
    if [[ ! -d "$dir_path" ]]; then
        mkdir -p "$dir_path"
        chmod "$mode" "$dir_path"
    fi
    
    if [[ -n "$owner" ]]; then
        chown "$owner" "$dir_path"
    fi
    
    return 0
}

ensure_file() {
    local file_path="$1"
    local mode="${2:-644}"
    local owner="${3:-}"
    
    local dir_path
    dir_path=$(dirname "$file_path")
    ensure_directory "$dir_path"
    
    if [[ ! -f "$file_path" ]]; then
        touch "$file_path"
    fi
    
    chmod "$mode" "$file_path"
    
    if [[ -n "$owner" ]]; then
        chown "$owner" "$file_path"
    fi
    
    return 0
}

file_exists() {
    local file_path="$1"
    
    [[ -f "$file_path" ]]
}

directory_exists() {
    local dir_path="$1"
    
    [[ -d "$dir_path" ]]
}

is_writable() {
    local path="$1"
    
    [[ -w "$path" ]]
}

is_readable() {
    local path="$1"
    
    [[ -r "$path" ]]
}

is_executable() {
    local path="$1"
    
    [[ -x "$path" ]]
}

backup_file() {
    local file_path="$1"
    local backup_suffix="${2:-$(date +%Y%m%d%H%M%S)}"
    
    if [[ -f "$file_path" ]]; then
        cp "$file_path" "${file_path}.backup.${backup_suffix}"
        return 0
    fi
    
    return 1
}

backup_directory() {
    local dir_path="$1"
    local backup_suffix="${2:-$(date +%Y%m%d%H%M%S)}"
    
    if [[ -d "$dir_path" ]]; then
        cp -r "$dir_path" "${dir_path}.backup.${backup_suffix}"
        return 0
    fi
    
    return 1
}

safe_remove() {
    local path="$1"
    
    if [[ -e "$path" ]]; then
        rm -rf "$path"
        return 0
    fi
    
    return 0
}

get_file_size() {
    local file_path="$1"
    
    if [[ -f "$file_path" ]]; then
        stat -c%s "$file_path" 2>/dev/null || stat -f%z "$file_path" 2>/dev/null
        return 0
    fi
    
    echo "0"
    return 1
}

get_directory_size() {
    local dir_path="$1"
    
    if [[ -d "$dir_path" ]]; then
        du -sb "$dir_path" 2>/dev/null | cut -f1
        return 0
    fi
    
    echo "0"
    return 1
}

get_free_space() {
    local path="${1:-/}"
    
    df -BG "$path" 2>/dev/null | awk 'NR==2 {print $4}' | sed 's/G//'
}

get_total_space() {
    local path="${1:-/}"
    
    df -BG "$path" 2>/dev/null | awk 'NR==2 {print $2}' | sed 's/G//'
}

create_symlink() {
    local source="$1"
    local destination="$2"
    
    ln -sf "$source" "$destination"
    
    return $?
}

read_config_value() {
    local file="$1"
    local key="$2"
    local default="${3:-}"
    
    if [[ -f "$file" ]]; then
        local value
        value=$(grep "^${key}=" "$file" 2>/dev/null | cut -d'=' -f2-)
        if [[ -n "$value" ]]; then
            echo "$value"
            return 0
        fi
    fi
    
    echo "$default"
    return 1
}

write_config_value() {
    local file="$1"
    local key="$2"
    local value="$3"
    
    ensure_file "$file"
    
    if grep -q "^${key}=" "$file" 2>/dev/null; then
        sed -i "s|^${key}=.*|${key}=${value}|" "$file"
    else
        echo "${key}=${value}" >> "$file"
    fi
    
    return 0
}

set_file_permissions() {
    local path="$1"
    local owner="$2"
    local mode="$3"
    
    chown -R "$owner" "$path"
    chmod -R "$mode" "$path"
    
    return 0
}
