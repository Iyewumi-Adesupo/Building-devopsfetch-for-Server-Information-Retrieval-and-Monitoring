#!/bin/bash

# Log file location
LOG_FILE="/var/log/devops-fetch.log"

# Ensure the log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Function to display usage information
show_help() {
    echo "Usage: devops-fetch.sh [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -p, --port [PORT]    Display all active ports and services or details of a specific port."
    echo "  -d, --docker [NAME]  List all Docker images and containers or details of a specific container."
    echo "  -n, --nginx [DOMAIN] Display all Nginx domains and their ports or details of a specific domain."
    echo "  -u, --users [USER]   List all users and their last login times or details of a specific user."
    echo "  -t, --time [RANGE]   Display activities within a specified time range."
    echo "  -h, --help           Show this help message and exit."
}

# Function to log messages with timestamps
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to display all active ports and services
display_ports() {
    if [ -n "$1" ]; then
        PORT_NUMBER=$1
        log "Details for port $PORT_NUMBER:"
        ss -tuln | awk -v port="$PORT_NUMBER" '$5 ~ ":"port {print $0}' | tee -a "$LOG_FILE"
    else
        log "Active Ports and Services:"
        ss -tuln | awk '{print $1, $4, $5}' | column -t -N "Proto,Local Address,Remote Address" | tee -a "$LOG_FILE"
    fi
}

# Function to list Docker images and containers
display_docker_info() {
    if ! command -v docker &> /dev/null; then
        log "Docker is not installed on this system."
        return
    fi

    if [ -n "$1" ]; then
        CONTAINER_NAME=$1
        log "Details for Docker container $CONTAINER_NAME:"
        docker inspect "$CONTAINER_NAME" | tee -a "$LOG_FILE"
    else
        log "Docker Images:"
        docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.Size}}" | tee -a "$LOG_FILE"

        log "Docker Containers:"
        docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" | tee -a "$LOG_FILE"
    fi
}

# Function to display Nginx domains and their ports
display_nginx_info() {
    if ! command -v nginx &> /dev/null; then
        log "Nginx is not installed on this system."
        return
    fi

    if [ -n "$1" ]; then
        DOMAIN=$1
        log "Nginx configuration for domain $DOMAIN:"
        nginx -T 2>/dev/null | grep -A 20 "server_name .*${DOMAIN}" | tee -a "$LOG_FILE"
    else
        log "Nginx Domains and Ports:"
        nginx -T 2>/dev/null | awk '/server_name/ {print $2}' | column -t -N "Domain" | tee -a "$LOG_FILE"
    fi
}

# Function to list users and their last login times
display_user_info() {
    if [ -n "$1" ]; then
        USERNAME=$1
        log "Details for user $USERNAME:"
        lastlog -u "$USERNAME" | tee -a "$LOG_FILE"
    else
        log "Users and their last login times:"
        lastlog | tee -a "$LOG_FILE"
    fi
}

# Function to display activities within a specified time range
display_time_range() {
    TIME_RANGE=$1
    log "Displaying activities within the time range: $TIME_RANGE"
    journalctl --since="$TIME_RANGE" | tee -a "$LOG_FILE"
}

# Main script execution
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--port)
            PORT="$2"
            shift 2
            display_ports "$PORT"
            ;;
        -d|--docker)
            DOCKER_NAME="$2"
            shift 2
            display_docker_info "$DOCKER_NAME"
            ;;
        -n|--nginx)
            DOMAIN="$2"
            shift 2
            display_nginx_info "$DOMAIN"
            ;;
        -u|--users)
            USER="$2"
            shift 2
            display_user_info "$USER"
            ;;
        -t|--time)
            TIME="$2"
            shift 2
            display_time_range "$TIME"
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Default action if no arguments are provided
if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi

# End of script
