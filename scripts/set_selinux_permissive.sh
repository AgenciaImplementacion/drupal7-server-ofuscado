#!/bin/bash
echo 'Ejecutando: set_permisive.sh'
if egrep '^SELINUX=permissive' /etc/selinux/config &>/dev/null; then
  echo 'SELINUX permisivo. Nada que hacer.'
  exit  
fi

# rationale: selecciona sudo como comando para obtener permisos
SUDO=sudo

# rationale: se configura SELINUX en modo permisivo para que los programas
# puedan ejecutarse correctamente
echo 'Configurando SELINUX'
if type setenforce &>/dev/null && [ "$(getenforce)" != "Disabled" ]
then
  echo setenforce permissive
  $SUDO setenforce permissive
fi
if [ -f /etc/selinux/config ]
then
  $SUDO sed -i.bak 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
  egrep '^SELINUX=' /etc/selinux/config
fi
