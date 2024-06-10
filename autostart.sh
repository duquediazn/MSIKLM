#!/bin/bash

# Detect the username
USERNAME=$(whoami)

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

# Function to enable autostart
function enable_autostart() {
  # Check if at least one argument is provided
  if [ $# -eq 0 ]; then
    echo 'At least one argument is required'
    exit 1
  fi

  # Location of the MSIKLM binary (adjust according to your install target)
  msiklm='/usr/local/bin/msiklm'

  # Check if MSIKLM binary is installed
  if [ ! -f $msiklm ]; then
    echo 'MSI Keyboard Light Manager is not installed, hence no autostart possible'
    exit 1
  fi
    
  # Add msiklm to sudoers if it doesn't exist
    if [ ! -f /etc/sudoers.d/extraPermissions ]; then
      echo "Adding msiklm to sudoers..."
      echo "$USERNAME ALL=(ALL:ALL) NOPASSWD: /usr/local/bin/msiklm" | sudo tee /etc/sudoers.d/extraPermissions
      sudo chmod 440 /etc/sudoers.d/extraPermissions
    else
      echo "The sudoers file already exists, skipping this step..."
    fi

  # Create or update the systemd service file
  echo "Creating or updating the systemd service file..."
  sudo tee /etc/systemd/system/msiklm.service > /dev/null <<EOL
[Unit]
Description=MSIKLM Service
After=network.target

[Service]
ExecStart=sudo $msiklm $@
Restart=always
RestartSec=10
User=$USERNAME

[Install]
WantedBy=default.target
WantedBy=sleep.target
WantedBy=systemd-suspend.service
WantedBy=systemd-hibernate.service
EOL

  # Reload systemd daemons
  sudo systemctl daemon-reload

  # Enable the service
  sudo systemctl enable msiklm.service

  # Restart the service to apply new parameters
  sudo systemctl restart msiklm.service

  echo "Configuration complete. The msiklm service is now enabled and running with the parameters: $@"
}

# Function to disable autostart
function disable_autostart() {
  echo 'Disabling MSIKLM autostart...'
  sudo systemctl stop msiklm.service
  sudo systemctl disable msiklm.service
  sudo rm /etc/systemd/system/msiklm.service
  sudo systemctl daemon-reload
  sudo rm /etc/sudoers.d/extraPermissions
  echo 'MSIKLM autostart disabled.'
}

# Check for --disable argument
if [ "$1" == "--disable" ]; then
  disable_autostart
  exit 0
fi

# Otherwise, enable autostart with provided arguments
enable_autostart "$@"
