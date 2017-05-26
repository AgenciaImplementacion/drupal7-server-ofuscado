#!/bin/bash
# rationale: el usuario predeterminado de apache
#usuario_usuario=apache:apache #si no es vagrant!
usuario_usuario=vagrant:vagrant

sudo yum install -y wget
# rationale: subshell
# link: https://github.com/koalaman/shellcheck/wiki/SC2103
(
cd /tmp || exit
dir=drupal-7.54
file=$dir.tar.gz
if [ -d $dir ]
then
  echo "El directorio $dir ya existe. Nada que hacer."
else
  wget https://ftp.drupal.org/files/projects/$file
  tar -xf $file
  sudo cp -R $dir/. /var/www/html
  # rm drupal-8.2.5.tar.gz # no es necesario por estar en /tmp
fi
)

# rationale: da permisos al directorio translations
dir=/var/www/html/sites/default/files/translations
if [ -d $dir ]
then
  echo "El directorio $dir ya existe. Nada que hacer."
else
  sudo mkdir -p $dir
  # cambiar por apache:apache en instalación regular
  sudo chown $usuario_usuario $dir
  sudo chmod +x $dir
fi

# rationale: habilitar mod_rewrite en /var/www/html con configuracion en
# /etc/httpd/conf/httpd.conf
# sudo python << 'EOF'
# texto_busqueda_inicio = '<Directory "/var/www/html">'
# texto_busqueda_final = "</Directory>"
# texto_a_buscar = "AllowOverride None"
# texto_a_reemplazar = "AllowOverride All"
# archivo = "/etc/httpd/conf/httpd.conf"
# texto_reemplazo = open(archivo, "r").read()
# index_inicio = texto_reemplazo.find(texto_busqueda_inicio) + len(texto_busqueda_inicio)
# index_final = texto_reemplazo.find(texto_busqueda_final, index_inicio)
# texto_antes = texto_reemplazo[:index_inicio]
# texto_despues = texto_reemplazo[index_final:]
# texto_entre = texto_reemplazo[index_inicio:index_final]
# texto_entre = texto_entre.replace(texto_a_buscar, texto_a_reemplazar)
#
# with open(archivo + ".bak", 'w') as file:
#     file.write(texto_reemplazo)
#
# with open(archivo, 'w') as file:
#     file.write(texto_antes + texto_entre + texto_despues)
# EOF

# rationale: se activa mod_rewrite en la ruta /var/www/html
file=/etc/httpd/conf.d/activarmodrewrite.conf
if [ -f $file ]
then
  echo "El archivo $file ya existe. Nada que hacer."
else
  sudo tee $file << 'EOF'
<Directory "/var/www/html">
AllowOverride All
</Directory>
EOF
sudo systemctl restart httpd.service
fi

# rationale: darle permisos al directorio files y crear archivo de configuración
#sudo mkdir /var/www/html/sites/default/files/ #Linea 25
sudo chown -R $usuario_usuario /var/www/html/sites/default/files/
sudo cp /var/www/html/sites/default/{default.,}settings.php
sudo chown -R $usuario_usuario /var/www/html/sites/default/settings.php

# rationale: dependecias de drupal full
sudo yum install -y php-xcache php-ldap


# rationale: crear base de datos para drupal
# link: https://www.drupal.org/docs/7/installing-drupal-7/step-2-create-the-database
user_mysql="root"
pass_mysql="passwdrootmysql"
#mysql --user=$user_mysql --password=$pass_mysql -e "DROP USER userdrupal;"
mysql --user=$user_mysql --password=$pass_mysql -e "CREATE USER userdrupal@localhost IDENTIFIED BY 'passwordbasededatos';"
#mysql --user=$user_mysql --password=$pass_mysql -e "DROP DATABASE IF EXISTS drupal;"
mysql --user=$user_mysql --password=$pass_mysql -e "CREATE DATABASE drupal CHARACTER SET utf8 COLLATE utf8_general_ci;"
mysql --user=$user_mysql --password=$pass_mysql \
  -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON drupal.* TO 'userdrupal'@'localhost' IDENTIFIED BY 'passwordbasededatos';"
mysql --user=$user_mysql --password=$pass_mysql -e "SHOW DATABASES"
