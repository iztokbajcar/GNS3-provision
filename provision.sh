##############################################
# Please change these to your desired values #
export GUACAMOLE_ADMIN_PASSWORD=Ge5L0
export VNC_CONNECTION_PASSWORD=GNS3JeZ4k0n_%
############################################
 
export GUACAMOLE_ADMIN_PASSWORD_HASH=$(echo -n $GUACAMOLE_ADMIN_PASSWORD | openssl md5 | awk '{print $NF}')
export DEBIAN_FRONTEND=noninteractive 

# Adds GNS3 ppa repository (and updates the package lists)
add-apt-repository ppa:gns3/ppa

# Guacamole dependencies
apt-get install -y gcc vim nano curl wget g++ libcairo2-dev libjpeg-turbo8-dev libpng-dev libtool-bin libossp-uuid-dev libavcodec-dev libavutil-dev libswscale-dev \
    build-essential libvncserver-dev libtelnet-dev libssl-dev libwebp-dev openjdk-11-jdk tomcat9
# libvorbis-dev

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
wget https://downloads.apache.org/guacamole/1.3.0/source/guacamole-server-1.3.0.tar.gz -P /home/vagrant
tar xzf /home/vagrant/guacamole-server-1.3.0.tar.gz
cd /home/vagrant/guacamole-server-1.3.0
./configure --with-init-dir=/etc/init.d
make
make install
ldconfig
systemctl daemon-reload
systemctl start guacd
systemctl enable guacd

mkdir /etc/guacamole
wget https://downloads.apache.org/guacamole/1.3.0/binary/guacamole-1.3.0.war -P /home/vagrant
mv /home/vagrant/guacamole-1.3.0.war /etc/guacamole/guacamole.war

ln -s /etc/guacamole/guacamole.war /var/lib/tomcat9/webapps/

echo "GUACAMOLE_HOME=/etc/guacamole" | sudo tee -a /etc/default/tomcat
cat <<EOT > /etc/guacamole/guacamole.properties
guacd-hostname: localhost
guacd-port:    4822
user-mapping:    /etc/guacamole/user-mapping.xml
auth-provider:    net.sourceforge.guacamole.net.basic.BasicFileAuthenticationProvider
EOT

ln -s /etc/guacamole /var/lib/tomcat9/webapps/.guacamole

cat <<EOT > /etc/guacamole/user-mapping.xml
<user-mapping>
    <authorize username="admin"
            password="$GUACAMOLE_ADMIN_PASSWORD_HASH"
            encoding="md5"> <connection name="Ubuntu20.04-Server">
            <protocol>SSH</protocol>
            <param name="hostname">localhost</param>
            <param name="port">22</param>
            <param name="username">root</param>
        </connection>
        <connection name="VNC">
            <protocol>vnc</protocol>
            <param name="hostname">localhost</param>
            <param name="port">5900</param>
            <param name="username">vagrant</param>
        </connection>
    </authorize>
</user-mapping>
EOT

systemctl restart tomcat guacd
ufw allow 4822/tcp

# Desktop
apt-get install -y xserver-xorg-core openbox --no-install-recommends --no-install-suggests
apt-get install -y xinit slim
sed -i '70s/.*/default_user vagrant/' /etc/slim.conf
sed -i '78s/.*/auto_login yes/' /etc/slim.conf

# Installs GNS3
apt-get install -y gns3-server gns3-gui

# Adds vagrant into the ubridge group
usermod -aG ubridge vagrant

# VNC
cat <<EOT > /etc/init/x11vnc.conf
# description "Start x11vnc on system boot"

description "x11vnc"

start on runlevel [2345]
stop on runlevel [^2345]

console log

respawn
respawn limit 20 5

exec /usr/bin/x11vnc -forever -loop -noxdamage -repeat -rfbauth /home/vagrant/.vnc/passwd -rfbport 5900 -shared
EOT

x11vnc -storepasswd $VNC_CONNECTION_PASSWORD /home/vagrant/.vnc/passwd

reboot
