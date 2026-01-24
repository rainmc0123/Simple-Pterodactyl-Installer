#!/bin/bash

install_mariadb() {
    print_section "Menginstall MariaDB"
    
    install_mariadb_packages
    start_mariadb_service
    
    log_success "MariaDB berhasil diinstall"
    
    return 0
}

install_mariadb_packages() {
    run_with_spinner "Menginstall MariaDB server" "apt-get -y -o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' install mariadb-server mariadb-client"
    
    return $?
}

start_mariadb_service() {
    start_service "mariadb"
    enable_service "mariadb"
    
    return 0
}

mysql_execute() {
    local query="$1"
    local database="${2:-}"
    
    if [[ -n "$database" ]]; then
        mysql -u root "$database" -e "$query" 2>/dev/null
    else
        mysql -u root -e "$query" 2>/dev/null
    fi
    
    return $?
}

mysql_execute_file() {
    local file="$1"
    local database="${2:-}"
    
    if [[ -n "$database" ]]; then
        mysql -u root "$database" < "$file" 2>/dev/null
    else
        mysql -u root < "$file" 2>/dev/null
    fi
    
    return $?
}

create_database() {
    local db_name="$1"
    
    mysql_execute "CREATE DATABASE IF NOT EXISTS \`${db_name}\`;"
    
    return $?
}

create_database_user() {
    local username="$1"
    local password="$2"
    local host="${3:-127.0.0.1}"
    
    mysql_execute "CREATE USER IF NOT EXISTS '${username}'@'${host}' IDENTIFIED BY '${password}';"
    
    return $?
}

grant_database_privileges() {
    local username="$1"
    local database="$2"
    local host="${3:-127.0.0.1}"
    
    mysql_execute "GRANT ALL PRIVILEGES ON \`${database}\`.* TO '${username}'@'${host}' WITH GRANT OPTION;"
    mysql_execute "FLUSH PRIVILEGES;"
    
    return $?
}

drop_database() {
    local db_name="$1"
    
    mysql_execute "DROP DATABASE IF EXISTS \`${db_name}\`;"
    
    return $?
}

drop_database_user() {
    local username="$1"
    local host="${2:-127.0.0.1}"
    
    mysql_execute "DROP USER IF EXISTS '${username}'@'${host}';"
    
    return $?
}

backup_database() {
    local db_name="$1"
    local backup_file="$2"
    
    mysqldump -u root "$db_name" > "$backup_file" 2>/dev/null
    
    return $?
}

restore_database() {
    local db_name="$1"
    local backup_file="$2"
    
    mysql -u root "$db_name" < "$backup_file" 2>/dev/null
    
    return $?
}

test_database_connection() {
    local username="$1"
    local password="$2"
    local host="${3:-127.0.0.1}"
    local database="${4:-}"
    
    if [[ -n "$database" ]]; then
        mysql -u "$username" -p"$password" -h "$host" "$database" -e "SELECT 1;" &>/dev/null
    else
        mysql -u "$username" -p"$password" -h "$host" -e "SELECT 1;" &>/dev/null
    fi
    
    return $?
}

get_mariadb_version() {
    mysql --version 2>/dev/null | awk '{print $5}' | tr -d ','
}

verify_mariadb_installation() {
    if is_service_active "mariadb"; then
        log_success "MariaDB berjalan"
        return 0
    fi
    
    log_error "MariaDB tidak berjalan"
    return 1
}
