#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export SCRIPT_DIR

source "${SCRIPT_DIR}/lib/core/bootstrap.sh"
source "${SCRIPT_DIR}/lib/cli/arguments.sh"

main() {
    parse_args "$@"
    
    initialize_installer
    
    install_signal_handlers
    install_exit_handler
    
    START_TIME=$(date +%s)
    
    print_banner
    
    show_install_menu
    
    if [[ "$INSTALL_MODE" == "uninstall" ]]; then
        run_uninstall
        exit 0
    fi
    
    check_root
    check_os_supported
    detect_virtualization
    check_resources
    
    if [[ "$INSTALL_MODE" == "panel" || "$INSTALL_MODE" == "both" ]]; then
        check_existing_installation
    fi
    
    get_user_input
    
    update_system
    install_dependencies
    
    if [[ "$INSTALL_MODE" == "panel" || "$INSTALL_MODE" == "both" ]]; then
        install_php
        install_composer
        install_mariadb
        install_redis
        install_nginx
        install_certbot
        
        setup_database
        
        download_panel
        configure_environment
        migrate_database
        create_admin_user
        set_permissions
        
        configure_nginx
        setup_ssl
        
        setup_cron
        setup_queue_worker
    fi
    
    if [[ "$INSTALL_MODE" == "wings" || "$INSTALL_MODE" == "both" ]]; then
        install_docker
        install_wings
    fi
    
    configure_firewall
    
    verify_installation
    
    INSTALL_STATUS="SUCCESS"
    
    if [[ "$INSTALL_MODE" == "panel" || "$INSTALL_MODE" == "both" ]]; then
        save_credentials
        print_summary
    else
        print_wings_summary
    fi
    
    send_telemetry
    
    exit 0
}

main "$@"
