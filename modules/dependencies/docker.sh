#!/bin/bash

install_docker() {
    print_section "Menginstall Docker"
    
    remove_old_docker
    install_docker_engine
    start_docker_service
    verify_docker_installation
    
    return 0
}

remove_old_docker() {
    apt-get remove -y docker docker-engine docker.io containerd runc >> "$LOG_FILE" 2>/dev/null || true
    
    return 0
}

install_docker_engine() {
    run_with_spinner "Mengunduh dan menginstall Docker CE" "curl -sSL https://get.docker.com/ | CHANNEL=stable bash"
    
    return $?
}

start_docker_service() {
    start_service "docker"
    enable_service "docker"
    
    return 0
}

verify_docker_installation() {
    if command -v docker &>/dev/null; then
        DOCKER_VERSION=$(docker --version 2>/dev/null)
        log_success "Docker terinstall: $DOCKER_VERSION"
        return 0
    fi
    
    log_error "Instalasi Docker gagal!"
    exit 1
}

docker_run() {
    local image="$1"
    shift
    local args="$*"
    
    docker run $args "$image" >> "$LOG_FILE" 2>&1
    
    return $?
}

docker_pull() {
    local image="$1"
    
    docker pull "$image" >> "$LOG_FILE" 2>&1
    
    return $?
}

docker_stop_all() {
    local containers
    containers=$(docker ps -aq 2>/dev/null)
    
    if [[ -n "$containers" ]]; then
        docker stop $containers >> "$LOG_FILE" 2>&1
    fi
    
    return 0
}

docker_remove_all_containers() {
    local containers
    containers=$(docker ps -aq 2>/dev/null)
    
    if [[ -n "$containers" ]]; then
        docker rm $containers >> "$LOG_FILE" 2>&1
    fi
    
    return 0
}

docker_remove_all_images() {
    local images
    images=$(docker images -q 2>/dev/null)
    
    if [[ -n "$images" ]]; then
        docker rmi $images >> "$LOG_FILE" 2>&1
    fi
    
    return 0
}

docker_prune() {
    docker system prune -af >> "$LOG_FILE" 2>&1
    
    return $?
}

docker_volume_prune() {
    docker volume prune -f >> "$LOG_FILE" 2>&1
    
    return $?
}

get_docker_version() {
    docker --version 2>/dev/null | awk '{print $3}' | tr -d ','
}

is_docker_running() {
    is_service_active "docker"
}
