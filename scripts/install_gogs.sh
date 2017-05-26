#!/bin/bash
echo 'Ejecutando: install_gogs.sh'

# rationale: instalar dependencias git
sudo yum install git

# rationale: servicio/demonio de gogs
file=/usr/lib/systemd/system/gogs.service
if [ -f $file ]
then
  echo "El archivo $file ya existe. Nada que hacer."
else
  sudo tee $file << 'EOF'
[Unit]
Description=Gogs
After=syslog.target
After=network.target
#After=mariadb.service mysqld.service postgresql.service memcached.service redis                                                                                                                                  .service

[Service]
# Modify these two values and uncomment them if you have
# repos with lots of files and get an HTTP error 500 because
# of that
###
#LimitMEMLOCK=infinity
#LimitNOFILE=65535
Type=simple
User=root
Group=root
WorkingDirectory=/opt/gogs
ExecStart=/opt/gogs/gogs web
Restart=always
Environment=USER=root HOME=/root
RestartSec=60
Restart=always
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
fi

sudo systemctl enable gogs
sudo systemctl start gogs

sudo firewall-cmd --zone=public --add-port=3000/tcp --permanent
sudo firewall-cmd --reload
