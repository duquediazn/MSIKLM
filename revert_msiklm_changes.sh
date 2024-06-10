#!/bin/bash

# Deshabilitar el servicio
sudo systemctl disable msiklm.service

# Detener el servicio si está corriendo
sudo systemctl stop msiklm.service

# Eliminar el archivo de servicio
sudo rm /etc/systemd/system/msiklm.service

# Recargar los demonios de systemd
sudo systemctl daemon-reload

# Eliminar el archivo de sudoers
sudo rm /etc/sudoers.d/extraPermissions

echo "All changes have been reverted."

