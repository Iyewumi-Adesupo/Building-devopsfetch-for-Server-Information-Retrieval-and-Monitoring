#!/bin/bash


# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    sudo -E "$0" "$@"
    exit 1
fi

# Install dependencies
apt update
apt install -y nginx docker.io jq

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