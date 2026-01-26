#!/bin/bash

declare -gr INSTALLER_NAME="PTERODACTYL PANEL AUTO INSTALLER"
declare -gr INSTALLER_VERSION="1.0.3"
declare -gr INSTALLER_AUTHOR="ClouviaID"
declare -gr INSTALLER_LICENSE="MIT"
declare -gr INSTALLER_WEBSITE="https://clouvia.id"
declare -gr INSTALLER_COPYRIGHT="© 2024-2026 ClouviaID"

declare -gr PANEL_PATH="/var/www/pterodactyl"
declare -gr WINGS_CONFIG_PATH="/etc/pterodactyl"
declare -gr LOG_FILE="/var/log/pterodactyl-installer.log"
declare -gr CREDENTIALS_FILE="/root/pterodactyl-credentials.txt"

declare -gr PHP_VERSION="8.3"
declare -gr MINIMUM_RAM_MB=1024
declare -gr RECOMMENDED_RAM_MB=2048
declare -gr MINIMUM_DISK_GB=5
declare -gr RECOMMENDED_DISK_GB=10

declare -gr TELEMETRY_ENDPOINT="https://telemetry.clouvia.id/api/install"

declare -gr MODE_PANEL="panel"
declare -gr MODE_WINGS="wings"
declare -gr MODE_BOTH="both"
declare -gr MODE_UNINSTALL="uninstall"

declare -gr STATUS_PENDING="PENDING"
declare -gr STATUS_RUNNING="RUNNING"
declare -gr STATUS_SUCCESS="SUCCESS"
declare -gr STATUS_FAILED="FAILED"

declare -gr EXIT_SUCCESS=0
declare -gr EXIT_ERROR=1
declare -gr EXIT_USER_ABORT=2
declare -gr EXIT_PREREQ_FAILED=3
declare -gr EXIT_NETWORK_ERROR=4

declare -gr OS_UBUNTU="ubuntu"
declare -gr OS_DEBIAN="debian"

declare -ga SUPPORTED_UBUNTU_VERSIONS=("20.04" "22.04" "24.04")
declare -ga SUPPORTED_DEBIAN_VERSIONS=("11" "12" "13")

declare -ga REQUIRED_PORTS_PANEL=(22 80 443)
declare -ga REQUIRED_PORTS_WINGS=(8080 2022)

declare -gr DB_NAME_DEFAULT="panel"
declare -gr DB_USER_DEFAULT="pterodactyl"
declare -gr DB_HOST_DEFAULT="127.0.0.1"
declare -gr DB_PORT_DEFAULT="3306"

declare -gr REDIS_HOST_DEFAULT="127.0.0.1"
declare -gr REDIS_PORT_DEFAULT="6379"
