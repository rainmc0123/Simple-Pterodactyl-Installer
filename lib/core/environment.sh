#!/bin/bash

init_environment() {
    export DEBIAN_FRONTEND=noninteractive
    export NEEDRESTART_MODE=a
    export NEEDRESTART_SUSPEND=1
    export COMPOSER_ALLOW_SUPERUSER=1
    export LC_ALL=C.UTF-8
    export LANG=C.UTF-8
    
    umask 022
    
    set +e
    
    return 0
}

reset_environment() {
    unset DEBIAN_FRONTEND
    unset NEEDRESTART_MODE
    unset NEEDRESTART_SUSPEND
    
    return 0
}

check_environment_variable() {
    local var_name="$1"
    local var_value="${!var_name}"
    
    if [[ -z "$var_value" ]]; then
        return 1
    fi
    
    return 0
}

set_runtime_variable() {
    local var_name="$1"
    local var_value="$2"
    
    declare -g "$var_name"="$var_value"
    
    return 0
}

get_runtime_variable() {
    local var_name="$1"
    local var_value="${!var_name}"
    
    echo "$var_value"
    
    return 0
}

export_runtime_variables() {
    export DB_PASSWORD
    export DB_USER
    export DB_NAME
    export DB_HOST
    export DB_PORT
    export ADMIN_EMAIL
    export ADMIN_PASSWORD
    export APP_URL
    export FQDN
    export INSTALL_MODE
    export INSTALL_STATUS
    
    return 0
}
