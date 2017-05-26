# Instrucciones para instalar Jenkins
Se puede hacer lo siguiente:
1. Abrir http://drupal7.portal.incige.com:8080/
2. Desbloquearlo con el key que aparece en:
```bash
cat /var/log/jenkins/jenkins.log
```
3. Usar los datos de conexión:
 - Usuario: usuariojenkins
 - Contraseña: clavejenkins
 - Nombre completo: Administrador Jenkins
 - Dirección de email: agenciadeimplementacion@incige.com

## Configurar maven
1. Acceda a http://drupal7.portal.incige.com:8080/configureTools/
2. Añada una instalación de Maven

# Archivos de configuración

## pipeline
```groovy
node {
   def mvnHome
   stage('Preparation') { // for display purposes
      // Get some code from a GitHub repository
      git 'https://github.com/AgenciaImplementacion/iliValidator.git'
      // Get the Maven tool.
      // ** NOTE: This 'M3' Maven tool must be configured
      // **       in the global configuration.           
      mvnHome = tool 'M3'
   }
   stage('Build') {
      // Run the maven build
      if (isUnix()) {
         sh "git submodule update --recursive --init"
         dir ('./src/shapefile-viewer'){
             sh "npm install"
             sh "npm run build"
         }
         dir ('./src'){
            sh "rm -rf ilivalidator/src/main/resources/static/build || true"
            sh "cp -R shapefile-viewer/build ilivalidator/src/main/resources/static"
         }
         dir ('./src/ilivalidator'){
             sh "'${mvnHome}/bin/mvn' -Dmaven.test.failure.ignore clean package"
             sh "rm -rf /var/www/artifacts/ilivalidator-0.0.1-SNAPSHOT.jar "
             sh "cp target/ilivalidator-0.0.1-SNAPSHOT.jar /var/www/artifacts"
             sh "sudo /bin/systemctl restart ilivalidator"
         }
      } else {
         bat(/"${mvnHome}\bin\mvn" -Dmaven.test.failure.ignore clean package/)
      }
   }
   stage('Results') {
      junit '**/target/surefire-reports/TEST-*.xml'
      archive 'target/*.jar'
   }
}
```
### script bash
```bash
mkdir /var/www/artifacts/
chown jenkins:jenkins -R /var/www/artifacts/
```

## enviroment variables in profile
```bash
# rationale: script para configurar variables de entorno en el servidor
mkdir /tmp/uploads
mkdir /tmp/ili
file=/etc/profile.d/ilivalidator.sh
sudo tee $file << 'EOF'
export interlis_uploadedfiles="/tmp/uploads"
export interlis_ilidir="/tmp/ili"
EOF
```

## systemd service
```bash
# rationale: servicio/demonio de ilivalidator
file=/usr/lib/systemd/system/ilivalidator.service
sudo tee $file << 'EOF'
[Unit]
Description=ilivalidator
After=network.target
#After=network.target remote-fs.target nss-lookup.target

[Service]
#no funciona Enviroment
Enviroment=interlis_uploadedfiles=/tmp/uploads
Enviroment=interlis_ilidir=/tmp/ili
ExecStart=/bin/bash -c "source /etc/profile.d/ilivalidator.sh; env | grep -i interlis; java -jar /var/www/artifacts/ilivalidator-0.0.1-SNAPSHOT.jar"
Type=simple
#ExecStop=/usr/lib/systemd/scripts/apachectl stop
#RemainAfterExit=yes

[Install]
WantedBy=default.target
EOF
```

## sudoers file
```bash
# rationale: agregar permisos al usuario jenkins para realizar acciones con sudo
file=/etc/sudoers.d/jenkins
sudo tee $file << 'EOF'
Defaults:jenkins !requiretty
jenkins ALL= NOPASSWD: /bin/systemctl start ilivalidator
jenkins ALL= NOPASSWD: /bin/systemctl restart ilivalidator
jenkins ALL= NOPASSWD: /bin/systemctl stop ilivalidator
jenkins ALL= NOPASSWD: /bin/systemctl status ilivalidator
jenkins ALL= NOPASSWD: /bin/systemctl status ilivalidator -l
EOF
```
