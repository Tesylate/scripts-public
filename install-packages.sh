#!/bin/bash

set -e

# Function to check if another dpkg or apt process is running
wait_for_dpkg_lock() {
    echo "Checking for dpkg or apt locks..."

    while fuser /var/lib/dpkg/lock >/dev/null 2>&1 || fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
        echo "Another dpkg process is running. Waiting for 5 seconds..."
        sleep 5
    done

    echo "No dpkg or apt locks detected. Proceeding with installation."
}

# Add Microsoft's package repository and GPG key
wait_for_dpkg_lock
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
add-apt-repository "$(wget -qO- https://packages.microsoft.com/config/debian/11/prod.list)"

# Update package lists
wait_for_dpkg_lock
apt-get update

# Install prerequisites
wait_for_dpkg_lock
apt-get install -y wget gnupg lsb-release

# Install cloudflared
wait_for_dpkg_lock
wget -O /tmp/cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i /tmp/cloudflared.deb || apt-get install -f -y
rm -f /tmp/cloudflared.deb
cloudflared --version

# Install the latest version of msodbcsql18
wait_for_dpkg_lock
apt-get install -y msodbcsql18
odbcinst -j

# Clean up
wait_for_dpkg_lock
apt-get clean && rm -rf /var/lib/apt/lists/*

echo "Installation of cloudflared and Microsoft SQL Server ODBC driver (msodbcsql18) is complete."
