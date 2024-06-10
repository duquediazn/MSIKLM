#!/bin/bash

# Detectar el nombre de usuario
USERNAME=$(whoami)

# Comprobar si el script está siendo ejecutado como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit 1
fi

# Solicitar los parámetros para msiklm
read -p "Introduce los parámetros para msiklm (por ejemplo, 'green'): " MSIKLM_PARAMS

# Añadir msiklm a sudoers si no existe
if [ ! -f /etc/sudoers.d/extraPermissions ]; then
  echo "Añadiendo msiklm a sudoers..."
  echo "$USERNAME ALL=(ALL:ALL) NOPASSWD: /usr/local/bin/msiklm" | sudo tee /etc/sudoers.d/extraPermissions
  sudo chmod 440 /etc/sudoers.d/extraPermissions
else
  echo "El archivo de sudoers ya existe, omitiendo este paso..."
fi

# Crear o actualizar el archivo de servicio systemd
echo "Creando o actualizando el archivo de servicio systemd..."
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

# Recargar los demonios de systemd
sudo systemctl daemon-reload

# Habilitar el servicio
sudo systemctl enable msiklm.service

# Reiniciar el servicio para aplicar los nuevos parámetros
sudo systemctl restart msiklm.service

echo "Configuración completada. El servicio msiklm está ahora habilitado y en ejecución con los parámetros: $MSIKLM_PARAMS."

