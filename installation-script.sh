#!/bin/bash

# Define installation directories and files
SCRIPT_DIR="/opt/devops-tools"
SCRIPT_FILE="$SCRIPT_DIR/devopsfetch.sh"
LOG_FILE="/var/log/devopsfetch.log"
SYSTEMD_SERVICE_FILE="/etc/systemd/system/devopsfetch.service"
SYSTEMD_TIMER_FILE="/etc/systemd/system/devopsfetch.timer"

# Ensure necessary directories exist
sudo mkdir -p "$SCRIPT_DIR"
sudo mkdir -p "$(dirname "$log")"

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    sudo -E "$0" "$@"
    exit 1
fi

# Install dependencies
apt update

# Update the package list
sudo apt update

# Install Nginx
sudo apt install -y nginx

# Install Docker
sudo apt install -y docker.io

# Install jq
sudo apt install -y jq


# Copy the main script to /usr/local/bin
cp devopsfetch.sh /usr/local/bin/devopsfetch
chmod +x /usr/local/bin/devopsfetch
chmod +x devopsfetch.sh

# Create a systemd service file
cat << EOF > /etc/systemd/system/devopsfetch.service
[Unit]
Description=DevOps Fetch Monitoring Service
After=network.target

[Service]
ExecStart=/usr/local/bin/devopsfetch -t "1 hour ago" "now"
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start the service
systemctl daemon-reload
systemctl enable devopsfetch.service
systemctl start devopsfetch.service

# Create systemd timer file for periodic execution
    sudo tee "$SYSTEMD_TIMER_FILE" > /dev/null << EOF
[Unit]
Description=Runs devops-fetch every 10 minutes

[Timer]
OnBootSec=5min
OnUnitActiveSec=10min
Unit=devopsfetch.service

[Install]
WantedBy=timers.target
EOF

    # Reload systemd daemon
    sudo systemctl daemon-reload

    # Enable and start the timer
    sudo systemctl enable devopsfetch.timer
    sudo systemctl start devopsfetch.timer

# Create systemd timer file for periodic execution
    sudo tee "$SYSTEMD_TIMER_FILE" > /dev/null << EOF
[Unit]
Description=Runs devopsfetch every 10 minutes

[Timer]
OnBootSec=5min
OnUnitActiveSec=10min
Unit=devopsfetch.service

[Install]
WantedBy=timers.target
EOF

    # Reload systemd daemon
    sudo systemctl daemon-reload

    # Enable and start the timer
    sudo systemctl enable devopsfetch.timer
    sudo systemctl start devopsfetch.timer


# Set up log rotation
cat << EOF > /etc/logrotate.d/devopsfetch
/var/log/devopsfetch.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 644 root root
}
EOF

echo "DevOps Fetch has been installed and configured."