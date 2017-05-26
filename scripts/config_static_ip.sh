#!/bin/bash

# rationale: valida que el usuario que ejecute el script sea root
if [ $USER != 'root' ]; then
  echo 'El script debe ser ejecutado como ROOT'
  exit
fi

# rationale: poner IP estática
archivo='/etc/sysconfig/network-scripts/ifcfg-enp0s3'
if grep -i 'BOOTPROTO=static' $archivo &> /dev/null
then
  echo "Ya existe la línea BOOTPROTO=static el archivo $archivo"
else
  sed -i.bak '/^ONBOOT=/ s/no/yes/g' $archivo
  sed -i '/^BOOTPROTO=/ s/dhcp/static/g' $archivo
  cat << 'EOF' >> $archivo
IPADDR=192.168.98.222
NETMASK=255.255.255.0
GATEWAY=192.168.98.1
NT_CONTROLLED=no
EOF

  # rationale: configurar el DNS
  archivo='/etc/resolv.conf'
  cat << 'EOF' > $archivo
nameserver 192.168.98.20
nameserver 8.8.8.8
EOF
fi

# rationale: se cambia NetworkManager por network
# si el servicio "network" no inicia significa que la IP tal vez está ocupada
systemctl enable network.service
systemctl disable NetworkManager.service
systemctl stop NetworkManager.service
systemctl restart network.service
