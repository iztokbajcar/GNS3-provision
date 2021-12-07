
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

# Desktop
apt-get install -y gnome-session gnome-terminal

# Installs GNS3
apt-get install -y gns3-server gns3-gui

# Adds vagrant into the ubridge group
usermod -aG ubridge vagrant

reboot
