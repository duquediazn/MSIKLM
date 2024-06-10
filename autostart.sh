#!/bin/bash

# Detect the username
USERNAME=$(whoami)

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

# Check if arguments are provided
if [ $# -eq 0 ]; then
  echo "Usage: sudo ./autostart <your arguments>"
  exit 1
fi

# Take all arguments as parameters for msiklm
MSIKLM_PARAMS="$*"

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
ExecStart=sudo /usr/local/bin/msiklm $MSIKLM_PARAMS
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

echo "Configuration complete. The msiklm service is now enabled and running with the parameters: $MSIKLM_PARAMS."

