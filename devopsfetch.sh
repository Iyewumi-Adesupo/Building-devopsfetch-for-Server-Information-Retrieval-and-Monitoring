#!/bin/bash

# Function to display help message
display_help() {
    echo "Usage: devops-fetch [OPTION]"
    echo "Collect and display system information for DevOps purposes."
    echo
    echo "Options:"
    echo "  -p, --port [PORT]    Display active ports or info about a specific port"
    echo "  -d, --docker [ID]    Display Docker info or info about a specific container"
    echo "  -n, --nginx [DOMAIN] Display Nginx domains or info about a specific domain"
    echo "  -u, --users [USER]   Display users or info about a specific user"
    echo "  -t, --time START END Display activities within a time range"
    echo "  -h, --help           Display this help message"
}

# Function to get active ports along with user and service
get_active_ports() {
    ss -tuln -p | awk 'NR>1 {print $1, $4, $6, $7}' | while read proto local_addr state details; do
        port=$(echo $local_addr | awk -F: '{print $NF}')
        user=$(echo $details | sed -n 's/.*uid:\([0-9]\+\).*/\1/p')
        service=$(echo $details | awk -F\" '{print $2}')
        echo -e "$port\t$user\t$service\tLISTENING"
    done | sort -n | uniq | awk 'BEGIN {print "Port\tUser\tService\tState"} {print}'
}


# Function to get port info
get_port_info() {
    local port=$1
    ss -tlpn | grep ":$port " | awk '{print "Port: " $4 "\nProcess: " $6}'
}

# Function to get Docker info
get_docker_info() {
    docker ps -a --format "ID\t{{.ID}}\nImage\t{{.Image}}\nStatus\t{{.Status}}\n" | format_table
}

# Function to get container info
get_container_info() {
    local container_id=$1
    docker inspect $container_id | jq '.[0] | {Id, Name, Image, State}'
}

# Function to get Nginx domains
get_nginx_domains() {
    grep -r server_name /etc/nginx/sites-enabled/ | awk '{print $2}' | sort | uniq | \
    awk 'BEGIN {print "Domain"} {print $1}' | format_table
}

# Function to get Nginx domain info
get_nginx_domain_info() {
    local domain=$1
    grep -r -A20 "server_name $domain" /etc/nginx/sites-enabled/
}

# Function to get users
get_users() {
    last | awk '{print $1}' | sort | uniq | \
    awk 'BEGIN {print "User\tLast Login"} {print $1 "\t" systime()}' | format_table
}

# Function to get user info
get_user_info() {
    local username=$1
    id $username
    last $username | head -n5
}

# Function to get activities within a time range
get_activities() {
    local start_time=$1
    local end_time=$2
    journalctl --since "$start_time" --until "$end_time"
}

# Main script logic
case "$1" in
    -p|--port)
        if [ -z "$2" ]; then
            get_active_ports
        else
            get_port_info "$2"
        fi
        ;;
    -d|--docker)
        if [ -z "$2" ]; then
            get_docker_info
        else
            get_container_info "$2"
        fi
        ;;
    -n|--nginx)
        if [ -z "$2" ]; then
            get_nginx_domains
        else
            get_nginx_domain_info "$2"
        fi
        ;;
    -u|--users)
        if [ -z "$2" ]; then
            get_users
        else
            get_user_info "$2"
        fi
        ;;
    -t|--time)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Error: Start and end times are required for -t option"
            exit 1
        else
            get_activities "$2" "$3"
        fi
        ;;
    -h|--help)
        display_help
        ;;
    *)
        echo "Error: Invalid option"
        display_help
        exit 1
        ;;
esac