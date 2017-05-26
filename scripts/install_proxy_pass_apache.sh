#!/bin/bash
echo 'Ejecutando: install_gogs.sh'

# rationale: se configura apache para servir todos los sitios
file=/etc/httpd/conf.d/dominios.conf
if [ -f $file ]
then
  echo "El archivo $file ya existe. Nada que hacer."
else
  sudo tee $file << 'EOF'
<VirtualHost *:*>
    ServerName portal.incige.com
    ServerAlias www.portal.incige.com
    DocumentRoot "/var/www/html"
</VirtualHost>

<VirtualHost *:*>
    ProxyPreserveHost On
    ProxyPass        "/" "http://geo.intranet.incige.com:8080/"
    ProxyPassReverse "/" "http://geo.intranet.incige.com:8080/"
    ServerName geo.portal.incige.com
    #ServerAlias hola.portal.incige.com
</VirtualHost>

<VirtualHost *:*>
    ProxyPreserveHost On
    ProxyPass        "/" "http://jenkins.intranet.incige.com:8080/"
    ProxyPassReverse "/" "http://jenkins.intranet.incige.com:8080/"
    ServerName jenkins.portal.incige.com
</VirtualHost>

<VirtualHost *:*>
    ProxyPreserveHost On
    ProxyRequests off
    ProxyPass        "/" "http://gogs.intranet.incige.com:3000/"
    ProxyPassReverse "/" "http://gogs.intranet.incige.com:3000/"
    ServerName gogs.portal.incige.com
</VirtualHost>
EOF
fi
