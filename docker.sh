#!/bin/bash

# Script to install Docker on Ubuntu

# Update package index
echo "Updating package index..."
sudo apt-get update

# Install prerequisite packages
echo "Installing prerequisite packages..."
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker’s official GPG key
echo "Adding Docker’s GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker repository
echo "Adding Docker repository..."
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update package index again
echo "Updating package index..."
sudo apt-get update

# Install Docker CE
echo "Installing Docker CE..."
sudo apt-get install -y docker-ce

# Start and enable Docker service
echo "Starting and enabling Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Verify Docker installation
echo "Verifying Docker installation..."
sudo docker --version

# Add the current user to the docker group (optional)
echo "Adding the current user to the docker group..."
sudo usermod -aG docker $USER

echo "Docker installation completed."
