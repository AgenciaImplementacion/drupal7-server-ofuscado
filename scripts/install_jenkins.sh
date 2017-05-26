#!/bin/bash
echo 'Ejecutando: install_jenkins.sh'

# rationale: instalar repositorio jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

# rationale: instalar jenkins
sudo yum install jenkins

# rationale: iniciar jenkins
sudo systemctl start jenkins

# rationale: agregar jenkins a las excepciones del firewall
sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent
sudo firewall-cmd --zone=public --add-service=http --permanent
sudo firewall-cmd --reload

# rationale: programas necesarios para hacer pipelines
sudo yum install -y git maven
