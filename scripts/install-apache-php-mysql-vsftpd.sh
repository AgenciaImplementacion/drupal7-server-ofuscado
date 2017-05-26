#!/bin/bash
if httpd -v &> /dev/null
then
  echo 'HTTPD ya está instalado, nada que hacer.'
else
sudo yum install -y httpd
sudo systemctl enable httpd
fi

# rationale: instalar repo epel
sudo yum install -y epel-release

# rationale: instalar php y módulos de php-mysql-apache
sudo yum install -y php php-mysql php-gd php-ldap php-odbc php-pear php-xml \
  php-xmlrpc php-mbstring php-snmp php-soap curl curl-devel
sudo systemctl restart httpd.service

# rationale: instalar mariadb/mysql
sudo yum install -y mariadb-server mariadb
sudo systemctl start mariadb.service
sudo systemctl enable mariadb.service
PASSWDMYSQL='passwordmariadb'
sudo mysql_secure_installation << EOF

Y
$PASSWDMYSQL
$PASSWDMYSQL
Y
Y
Y
Y
EOF

# rationale: configurar firewall para los servicios relacionados
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --permanent --zone=public --add-service=ftp
sudo firewall-cmd --reload

# rationale: se agrega info.php para probar apache-php7
file=/var/www/html/info.php
if [ -f $file ]
then
  echo "El archivo $file ya existe. Nada que hacer."
else
  sudo tee $file << 'EOF'
<?php
phpinfo();
?>
EOF
fi

# rationale: se agrega servicio de FTP para drupal 8
# link: https://www.digitalocean.com/community/tutorials/how-to-set-up-vsftpd-on-centos-6--2
sudo yum install -y vsftpd
file=/etc/vsftpd/vsftpd.conf
if [ -f $file.bak ]
then
  echo "El archivo $file.bak ya existe. Nada que hacer."
else
  sudo sed -i.bak '/^anonymous_enable=/ s/YES/NO/' $file
  sudo sed -i '/^local_enable=/ s/NO/YES/' $file
  sudo sed -i '/^anonymous_enable=/ s/YES/NO/' $file
  sudo sed -i 's/#chroot_local_user=YES/chroot_local_user=YES/' $file
  #sudo tee --append /etc/vsftpd/vsftpd.conf <<< 'allow_writeable_chroot=YES'
  echo 'allow_writeable_chroot=YES' | sudo tee --append $file
  # rationale: agregar usuario de ftp para /var/www/html
  sudo useradd ftpuser
  PASSWDFTPUSER='clavedeusuarioftpuser'
  echo $PASSWDFTPUSER | sudo passwd ftpuser --stdin
  sudo sed -i.bak '/^ftpuser/ s/\/home\/ftpuser/\/var\/www\/html/' /etc/passwd
  sudo chown -R ftpuser:ftpuser /var/www/html/sites/all/modules/
  sudo systemctl restart vsftpd
  sudo systemctl enable vsftpd
fi

# rationale: hacer que los archivos sean ejecutados con permisos de usuario ftpuser
file=/etc/httpd/conf.d/permisos.conf
if [ -f $file ]
then
  echo "El archivo $file ya existe. Nada que hacer."
else
sudo tee $file << 'EOF'
User ftpuser
Group ftpuser
EOF
sudo chown -R ftpuser:ftpuser -R /var/lib/php/
sudo systemctl restart httpd
fi
