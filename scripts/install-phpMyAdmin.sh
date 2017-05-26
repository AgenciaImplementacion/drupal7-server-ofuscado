#!/bin/bash

# rationale: crear directorio de phpmyadmin
sudo yum install -y unzip
(
cd /tmp || exit
dir=phpMyAdmin-4.4.15.10-all-languages
file=$dir.zip
if [ -d $dir ]
then
  echo "El directorio $dir ya existe. Nada que hacer."
else
  wget https://files.phpmyadmin.net/phpMyAdmin/4.4.15.10/$file
  unzip $file
  sudo cp -R $dir /var/www/phpMyAdmin
  # rm drupal-8.2.5.tar.gz # no es necesario por estar en /tmp
fi
)

# rationale: se agrega la ruta al apache
file=/etc/httpd/conf.d/phpmyadmin.conf
if [ -f $file ]
then
  echo "El archivo $file ya existe. Nada que hacer."
else
  sudo tee $file << 'EOF'
Alias "/phpmyadmin" "/var/www/phpMyAdmin/"
Alias "/phpMyAdmin" "/var/www/phpMyAdmin/"
<Directory "/var/www/phpMyAdmin/">
    Require ip 192.168.98.0/255.255.255.0
    # ErrorDocument 401 /index.php
    # ErrorDocument 403 /index.php
</Directory>
EOF
sudo systemctl restart httpd.service
fi
