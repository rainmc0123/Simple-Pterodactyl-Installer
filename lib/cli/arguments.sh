#!/bin/bash

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--domain)
                ARG_DOMAIN="$2"
                shift 2
                ;;
            -m|--mode)
                ARG_INSTALL_MODE="$2"
                UNATTENDED=true
                shift 2
                ;;
            -y|--yes)
                UNATTENDED=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            --debug)
                export DEBUG=true
                shift
                ;;
            --no-telemetry)
                export TELEMETRY_DISABLED=true
                shift
                ;;
            *)
                log_error "Opsi tidak dikenal: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    return 0
}

show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -m, --mode MODE       Mode: panel, wings, both, atau uninstall"
    echo "  -d, --domain DOMAIN   Set domain panel/wings"
    echo "  -y, --yes             Auto-konfirmasi semua prompt"
    echo "  -v, --version         Tampilkan versi installer"
    echo "  --debug               Enable debug mode"
    echo "  --no-telemetry        Disable telemetry"
    echo "  -h, --help            Tampilkan pesan bantuan ini"
    echo ""
    echo "Contoh:"
    echo "  $0                                    Mode interaktif"
    echo "  $0 -m panel -d panel.example.com      Install Panel saja"
    echo "  $0 -m wings -d node1.example.com      Install Wings saja"
    echo "  $0 -m both -d panel.example.com       Install Panel + Wings"
    echo "  $0 -m uninstall                       Uninstall Pterodactyl"
    echo ""
    echo "${INSTALLER_COPYRIGHT:-© 2024-2026 ClouviaID} - ${INSTALLER_WEBSITE:-https://clouvia.id}"
    echo ""
    
    return 0
}

show_version() {
    echo "Pterodactyl Auto Installer v${INSTALLER_VERSION:-1.0.0}"
    echo "${INSTALLER_COPYRIGHT:-© 2024-2026 ClouviaID}"
    
    return 0
}

validate_args() {
    if [[ -n "$ARG_INSTALL_MODE" ]]; then
        case "$ARG_INSTALL_MODE" in
            panel|wings|both|uninstall)
                ;;
            *)
                log_error "Mode tidak valid: $ARG_INSTALL_MODE"
                log_info "Mode yang valid: panel, wings, both, uninstall"
                exit 1
                ;;
        esac
    fi
    
    if [[ -n "$ARG_DOMAIN" ]]; then
        if ! validate_domain "$ARG_DOMAIN"; then
            log_error "Domain tidak valid: $ARG_DOMAIN"
            exit 1
        fi
    fi
    
    return 0
}
