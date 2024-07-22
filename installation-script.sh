#!/bin/bash

# Define installation directories and files
SCRIPT_DIR="/opt/devops-tools"
SCRIPT_FILE="$SCRIPT_DIR/devops-fetch.sh"
LOG_FILE="/var/log/devops-fetch.log"
SYSTEMD_SERVICE_FILE="/etc/systemd/system/devops-fetch.service"
SYSTEMD_TIMER_FILE="/etc/systemd/system/devops-fetch.timer"

# Ensure necessary directories exist
sudo mkdir -p "$SCRIPT_DIR"
sudo mkdir -p "$(dirname "$log")"

# Function to install necessary packages
install_dependencies() {
    echo "Installing necessary packages..."
    sudo apt-get update
    sudo apt-get install -y net-tools docker.io nginx
}

# Function to set up the devops-fetch script
setup_script() {
    echo "Setting up devops-fetch script..."

    # Check if devops-fetch.sh is present in the current directory
    if [ ! -f devops-fetch.sh ]; then
        echo "Error: devops-fetch.sh script not found in the current directory."
        exit 1
    fi

    sudo cp devops-fetch.sh "$SCRIPT_FILE"
    sudo chmod +x "$SCRIPT_FILE"
}

# Function to create systemd service
setup_systemd_service() {
    echo "Setting up systemd service..."

    # Create systemd service file
    sudo tee "$SYSTEMD_SERVICE_FILE" > /dev/null << EOF
[Unit]
Description=DevOps Fetch Service
After=network.target

[Service]
Type=simple
ExecStart=$SCRIPT_FILE
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
EOF

    # Create systemd timer file for periodic execution
    sudo tee "$SYSTEMD_TIMER_FILE" > /dev/null << EOF
[Unit]
Description=Runs devops-fetch every 10 minutes

[Timer]
OnBootSec=5min
OnUnitActiveSec=10min
Unit=devops-fetch.service

[Install]
WantedBy=timers.target
EOF

    # Reload systemd daemon
    sudo systemctl daemon-reload

    # Enable and start the timer
    sudo systemctl enable devops-fetch.timer
    sudo systemctl start devops-fetch.timer
}

# Function to set up log rotation
setup_log_rotation() {
    echo "Setting up log rotation for devops-fetch logs..."

    # Create logrotate configuration
    sudo tee /etc/logrotate.d/devops-fetch > /dev/null << EOF
$LOG_FILE {
    rotate 7
    daily
    compress
    missingok
    notifempty
    create 0640 root adm
    postrotate
        systemctl restart devops-fetch.service >/dev/null 2>&1 || true
    endscript
}
EOF
}

# Main installation process
install_dependencies
setup_script
setup_systemd_service
setup_log_rotation

echo "Installation complete. Use 'sudo systemctl status devops-fetch.timer' to check service status."
