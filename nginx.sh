#!/bin/bash

# Script to install Nginx on Ubuntu

# Update package index
echo "Updating package index..."
sudo apt-get update

# Install Nginx
echo "Installing Nginx..."
sudo apt-get install -y nginx

# Start and enable Nginx service
echo "Starting and enabling Nginx service..."
sudo systemctl start nginx
sudo systemctl enable nginx

# Verify Nginx installation
echo "Verifying Nginx installation..."
sudo nginx -v

echo "Nginx installation completed."
