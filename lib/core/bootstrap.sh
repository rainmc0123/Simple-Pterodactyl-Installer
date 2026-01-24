#!/bin/bash

set -o pipefail

INSTALLER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

export INSTALLER_ROOT

declare -g BOOTSTRAP_LOADED=1

source_module() {
    local module_path="$1"
    local full_path="${INSTALLER_ROOT}/${module_path}"
    
    if [[ -f "$full_path" ]]; then
        source "$full_path"
        return 0
    fi
    
    return 1
}

load_core_modules() {
    source_module "lib/core/constants.sh"
    source_module "lib/core/globals.sh"
    source_module "lib/core/environment.sh"
}

load_utilities() {
    source_module "lib/utils/colors.sh"
    source_module "lib/utils/logger.sh"
    source_module "lib/utils/spinner.sh"
    source_module "lib/utils/progress.sh"
    source_module "lib/utils/password.sh"
    source_module "lib/utils/validation.sh"
    source_module "lib/utils/network.sh"
    source_module "lib/utils/filesystem.sh"
}

load_handlers() {
    source_module "lib/handlers/error_handler.sh"
    source_module "lib/handlers/signal_handler.sh"
    source_module "lib/handlers/exit_handler.sh"
}

load_modules() {
    source_module "modules/system/detector.sh"
    source_module "modules/system/resources.sh"
    source_module "modules/system/packages.sh"
    source_module "modules/system/services.sh"
    
    source_module "modules/dependencies/php.sh"
    source_module "modules/dependencies/composer.sh"
    source_module "modules/dependencies/mariadb.sh"
    source_module "modules/dependencies/redis.sh"
    source_module "modules/dependencies/nginx.sh"
    source_module "modules/dependencies/docker.sh"
    source_module "modules/dependencies/certbot.sh"
    
    source_module "modules/database/setup.sh"
    source_module "modules/database/migrate.sh"
    source_module "modules/database/user.sh"
    
    source_module "modules/panel/download.sh"
    source_module "modules/panel/configure.sh"
    source_module "modules/panel/permissions.sh"
    source_module "modules/panel/admin.sh"
    
    source_module "modules/wings/install.sh"
    source_module "modules/wings/service.sh"
    
    source_module "modules/webserver/nginx_config.sh"
    source_module "modules/webserver/ssl.sh"
    
    source_module "modules/services/queue.sh"
    source_module "modules/services/cron.sh"
    
    source_module "modules/firewall/ufw.sh"
    
    source_module "modules/uninstall/panel.sh"
    source_module "modules/uninstall/wings.sh"
}

load_interface() {
    source_module "lib/interface/banner.sh"
    source_module "lib/interface/menu.sh"
    source_module "lib/interface/input.sh"
    source_module "lib/interface/summary.sh"
}

load_telemetry() {
    source_module "lib/telemetry/collector.sh"
    source_module "lib/telemetry/sender.sh"
}

initialize_installer() {
    load_core_modules
    load_utilities
    load_handlers
    load_interface
    load_modules
    load_telemetry
    
    init_environment
    init_logging
    
    return 0
}
