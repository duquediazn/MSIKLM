#!/bin/bash

# Disable the service
sudo systemctl disable msiklm.service

# Stop the service if it's running
sudo systemctl stop msiklm.service

# Remove the service file
sudo rm /etc/systemd/system/msiklm.service

# Reload systemd daemons
sudo systemctl daemon-reload

# Remove the sudoers file
sudo rm /etc/sudoers.d/extraPermissions

echo "All changes have been reverted."

