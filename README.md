# Servidor Drupal 7
Este es un proyecto con los scripts de generación de un entorno de desarrollo de
Drupal 7.

Puede utilizar vagrant (https://www.vagrantup.com/), este necesita un
hipervisor como virtualbox (https://www.virtualbox.org/).

El orden de ejecución de scripts es es:
- set_selinux_permissive.sh
- install-apache-php-mysql-vsftpd.sh
- install-drupal.sh
- config_static_ip.sh (no aplica para Vagrant)
- otros (la ejecución de estos depende de el software que se quiera instalar.)

De esta manera se puede tener un centos 7 aprovisionado con lo necesario para
correr Drupal 7.
