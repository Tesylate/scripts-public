#!/bin/bash

set -euo pipefail

# Function to check for dpkg or apt locks
wait_for_dpkg_lock() {
    echo "Checking for dpkg or apt locks..."
    while fuser /var/lib/dpkg/lock >/dev/null 2>&1 || fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
        echo "Apt or dpkg is locked. Waiting for 5 seconds..."
        sleep 5
    done
    echo "No dpkg or apt locks detected. Proceeding."
}

# Function to handle errors gracefully
handle_error() {
    echo "An error occurred during the installation process."
    echo "Please check the logs for more details and try again."
    exit 1
}

# Trap errors and call the error handler
trap handle_error ERR

# Update and install prerequisites
echo "Updating package list and installing prerequisites..."
wait_for_dpkg_lock
apt-get update && apt-get install -y wget gnupg lsb-release software-properties-common

# Install cloudflared
echo "Installing cloudflared..."
wait_for_dpkg_lock
wget -O /tmp/cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i /tmp/cloudflared.deb || apt-get install -f -y
rm -f /tmp/cloudflared.deb
cloudflared --version || (echo "Cloudflared installation failed!" && exit 1)

# Add Microsoft repository for msodbcsql18 and mssql-tools
echo "Adding Microsoft package repository for msodbcsql18 and mssql-tools..."
wait_for_dpkg_lock
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
wget -qO /etc/apt/sources.list.d/microsoft-prod.list https://packages.microsoft.com/config/debian/11/prod.list

# Update package lists again to include the Microsoft repository
echo "Updating package list after adding Microsoft repository..."
wait_for_dpkg_lock
apt-get update

# Install msodbcsql18
echo "Installing msodbcsql18 (Microsoft SQL Server ODBC driver)..."
wait_for_dpkg_lock
apt-get install -y msodbcsql18
odbcinst -j || (echo "msodbcsql18 installation failed!" && exit 1)

# Install mssql-tools
echo "Installing mssql-tools (sqlcmd and bcp utilities)..."
wait_for_dpkg_lock
apt-get install -y mssql-tools unixodbc-dev
if [ ! -d "/opt/mssql-tools/bin" ]; then
    echo "mssql-tools installation failed! Exiting..."
    exit 1
fi

# Add mssql-tools to PATH
echo "Adding mssql-tools to PATH..."
if ! grep -q "/opt/mssql-tools/bin" ~/.bashrc; then
    echo 'export PATH="/opt/mssql-tools/bin:$PATH"' >> ~/.bashrc
fi
if ! grep -q "/opt/mssql-tools/bin" ~/.zshrc; then
    echo 'export PATH="/opt/mssql-tools/bin:$PATH"' >> ~/.zshrc
fi
export PATH="/opt/mssql-tools/bin:$PATH"
sqlcmd -? || (echo "sqlcmd is not working! Please check the installation." && exit 1)

# Clean up
echo "Cleaning up unnecessary files and caches..."
wait_for_dpkg_lock
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

echo "Installation of cloudflared, msodbcsql18, and mssql-tools is complete!"
