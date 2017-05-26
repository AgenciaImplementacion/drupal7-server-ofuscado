#!/bin/bash

# rationale: valida que el usuario que ejecute el script sea root
if [ $USER != 'root' ]; then
  echo 'El script debe ser ejecutado como ROOT'
  exit
fi

# rationale: necesitado por phpize
yum install -y php70w-devel

# rationale: instalar xdebug por medio de pasos de https://xdebug.org/wizard.php
(
cd /tmp
wget http://xdebug.org/files/xdebug-2.5.0.tgz
tar -xvzf xdebug-2.5.0.tgz
cd xdebug-2.5.0
phpize
./configure
make
cp modules/xdebug.so /usr/lib64/php/modules
)

# rationale: agregar xdebug a php.ini
file='/etc/php.ini'
line='zend_extension = /usr/lib64/php/modules/xdebug.so'
if grep -i "$line" $file &> /dev/null
then
  echo "La línea $line ya esta en el archivo $file. Nada que hacer."
else
  echo "$line" | tee --append $file
fi

# rationale: reiniciar servidor apache
systemctl restart httpd
