#!/bin/bash

declare -g DB_PASSWORD=""
declare -g DB_USER="${DB_USER_DEFAULT:-pterodactyl}"
declare -g DB_NAME="${DB_NAME_DEFAULT:-panel}"
declare -g DB_HOST="${DB_HOST_DEFAULT:-127.0.0.1}"
declare -g DB_PORT="${DB_PORT_DEFAULT:-3306}"

declare -g ADMIN_PASSWORD=""
declare -g ADMIN_EMAIL=""
declare -g ADMIN_USERNAME="admin"

declare -g APP_URL=""
declare -g APP_KEY=""
declare -g FQDN=""
declare -g WINGS_FQDN=""
declare -g WINGS_USE_SSL=true

declare -g UNATTENDED=false
declare -g ARG_DOMAIN=""
declare -g ARG_INSTALL_MODE=""

declare -g INSTALL_MODE=""
declare -g INSTALL_STATUS="${STATUS_PENDING:-PENDING}"

declare -g OS_NAME=""
declare -g OS_VERSION=""
declare -g OS_PRETTY_NAME=""

declare -g PANEL_VERSION=""
declare -g WINGS_VERSION=""
declare -g DOCKER_VERSION=""
declare -g COMPOSER_VERSION=""

declare -g TOTAL_STEPS=20
declare -g CURRENT_STEP=0
declare -g START_TIME=""
declare -g END_TIME=""

declare -g VIRT_TYPE=""
declare -g TOTAL_RAM_MB=0
declare -g FREE_DISK_GB=0
declare -g CPU_CORES=0

declare -g UNINSTALL_MODE=""
