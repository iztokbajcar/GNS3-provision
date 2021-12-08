
export DEBIAN_FRONTEND=noninteractive 

# Adds GNS3 ppa repository (and updates the package lists)
add-apt-repository ppa:gns3/ppa

# Guacamole dependencies
apt-get install -y gcc vim curl wget g++ libcairo2-dev libjpeg-turbo8-dev libpng-dev libtool-bin libossp-uuid-dev libavcodec-dev libavutil-dev libswscale-dev \
    build-essential libpango1.0-dev libssh2-1-dev libvncserver-dev libtelnet-dev libssl-dev libvorbis-dev libwebp-dev freerdp2-dev freerdp2-x11 openjdk-11-jdk tomcat9

# Tomcat
cat <<EOT >> /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat 9 servlet container
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom -Djava.awt.headless=true"

Environment="CATALINA_BASE=/opt/tomcat/tomcatapp"
Environment="CATALINA_HOME=/opt/tomcat/tomcatapp"
Environment="CATALINA_PID=/opt/tomcat/tomcatapp/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/tomcatapp/bin/startup.sh
ExecStop=/opt/tomcat/tomcatapp/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
EOT

systemctl daemon-reload
systemctl enable --now tomcat
ufw allow 8080/tcp

# Guacamole
wget https://downloads.apache.org/guacamole/1.3.0/source/guacamole-server-1.3.0.tar.gz -P ~
tar xzf ~/guacamole-server-1.3.0.tar.gz
cd ~/guacamole-server-1.3.0
./configure --with-init-dir=/etc/init.d
make
make install
ldconfig
systemctl daemon-reload
systemctl start guacd
systemctl enable guacd

mkdir /etc/guacamole
wget https://downloads.apache.org/guacamole/1.3.0/binary/guacamole-1.3.0.war -P ~
mv ~/guacamole-1.3.0.war /etc/guacamole/guacamole.war

ln -s /etc/guacamole/guacamole.war /opt/tomcat/tomcatapp/webapps

echo "GUACAMOLE_HOME=/etc/guacamole" | sudo tee -a /etc/default/tomcat
cat <<EOT > /etc/guacamole/guacamole.properties
guacd-hostname: localhost
guacd-port:    4822
user-mapping:    /etc/guacamole/user-mapping.xml
auth-provider:    net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
EOT

ln -s /etc/guacamole /opt/tomcat/tomcatapp/.guacamole

# TODO passwords

systemctl restart tomcat guacd
ufw allow 4822/tcp

# Desktop
apt-get install -y gnome-session gnome-terminal gnome-tweaks gnome-shell-extension-ubuntu-docks
gnome-extensions enable ubuntu-dock@ubuntu.com

# Installs GNS3
apt-get install -y gns3-server gns3-gui

# Adds vagrant into the ubridge group
usermod -aG ubridge vagrant

reboot
