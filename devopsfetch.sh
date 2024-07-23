#!/bin/bash

# Function to display help message
display_help() {
    echo "Usage: devopsfetch [OPTION]"
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

    # Use ss with sudo to ensure we have the required permissions
    port_info=$(sudo ss -tlpn | awk -v port=":$port" '$4 ~ port {print $0}')

    # Check if port_info is empty
    if [ -z "$port_info" ]; then
        echo "Port: $port not found"
    else
        echo "Port information found: $port_info"
        # Extract user, service, and port information
        echo "$port_info" | awk '{
            split($4, addr_port, ":")
            split($6, user_service, ",")
            user = ""
            service = ""
            for (i = 1; i <= length(user_service); i++) {
                if (user_service[i] ~ /uid=/) {
                    split(user_service[i], user_split, "=")
                    user = user_split[2]
                } else if (user_service[i] ~ /name=/) {
                    split(user_service[i], service_split, "=")
                    service = service_split[2]
                }
            }
            printf "Port\tUser\tService\n"
            printf "%s\t%s\t%s\n", addr_port[length(addr_port)], user, service
        }'
    fi
}

# Function to format output as a table
format_table() {
    # Use column command to format output into a table
    column -t -s $'\t'
}

# Function to get Docker info
get_docker_info() {
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}\t{{.Size}}"
    

    echo -e "\nDocker Containers:"
    docker ps -a --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Names}}" |
    (read -r; printf "%s\n" "$REPLY"; sort -k 2 ) |
    column -t -s $'\t' | sed 's/^/  /'
}

# Function to get container info and format it into a table
get_container_info() {
    local container_name=$1

    # Retrieve container info using docker inspect and format it with jq
    docker inspect "$container_name" | jq -r '
        [
            .[0] | 
            {
                Id: .Id,
                Name: .Name,
                Image: .Config.Image,
                State: .State.Status
            }
        ] | 
        (.[0] | to_entries | map(.key) | join("\t")) as $keys |
        (.[0] | to_entries | map(.value) | join("\t")) as $values |
        $keys + "\n" + $values
    ' | column -t -s $'\t'
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