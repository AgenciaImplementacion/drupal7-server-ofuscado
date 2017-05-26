#!/bin/bash
echo 'Ejecutando: install_php71.sh'

# this need epel https://fedoraproject.org/wiki/EPEL
# yum install epel-release

# rationale: install php 7.1
# link: https://webtatic.com/packages/php71/
sudo rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm
sudo yum install -y php71w-fpm php71w-opcache php71w-common
sudo yum install -y php71w-cli \
  php71w-gd \
  php71w-mcrypt \
  php71w-xml \
  php71w-mbstring \
  php71w-mysql \
  php71w-zip \
  php71w-pgsql
# no included yet
# php71w-pdo php71w-mysqlnd php71w-pecl-mongodb php71w-pecl-redis \
# php71w-pecl-memcache php71w-pecl-memcached php71w-bcmath \

# rationale: recomendado por digitalocean por seguridad cgi.fix_pathinfo=0
# link: https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mysql-php-lemp-stack-on-centos-7
file=/etc/php.ini
if [ -f $file.bak ]
then
  echo "El archivo $file.bak ya existe. Nada que hacer."
else
  sudo sed -i.bak '/^;cgi.fix_pathinfo/ s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/' $file
fi

#systemctl start php-fpm.service
sudo systemctl enable php-fpm.service

#systemctl start nginx
sudo systemctl enable nginx

sudo firewall-cmd --permanent --zone=public --add-service=https
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --reload
