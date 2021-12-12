##############################################
# Please change these to your desired values #
export GUACAMOLE_ADMIN_PASSWORD=Ge5L0
export VNC_CONNECTION_PASSWORD=GNS3JeZ4k0n
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
apt-get install -y xserver-xorg-core openbox lxpanel xcompmgr pcmanfm midori --no-install-recommends --no-install-suggests
apt-get install -y xinit slim
sed -i '70s/.*/default_user vagrant/' /etc/slim.conf
sed -i '78s/.*/auto_login yes/' /etc/slim.conf

mkdir -p /home/vagrant/.config/openbox
cat <<EOT > /home/vagrant/.config/openbox/autostart.sh
xcompmgr &
lxpanel &
gns3
EOT

# Installs GNS3
apt-get install -y gns3-server=2.2.27~focal1 gns3-gui=2.2.27~focal1
mkdir -p /home/vagrant/.config/GNS3/2.2
cat <<EOT > /home/vagrant/.config/GNS3/2.2/gns3_gui.conf
{
    "Builtin": {
        "default_nat_interface": "virbr0"
    },
    "Docker": {
        "containers": []
    },
    "Dynamips": {
        "allocate_aux_console_ports": false,
        "dynamips_path": "",
        "ghost_ios_support": true,
        "mmap_support": true,
        "sparse_memory_support": true
    },
    "GraphicsView": {
        "default_label_color": "#000000",
        "default_label_font": "TypeWriter,10,-1,5,75,0,0,0,0,0",
        "default_note_color": "#000000",
        "default_note_font": "TypeWriter,10,-1,5,75,0,0,0,0,0",
        "draw_link_status_points": true,
        "draw_rectangle_selected_item": false,
        "drawing_grid_size": 25,
        "grid_size": 75,
        "limit_size_node_symbols": true,
        "scene_height": 1000,
        "scene_width": 2000,
        "show_grid": false,
        "show_grid_on_new_project": false,
        "show_interface_labels": false,
        "show_interface_labels_on_new_project": false,
        "show_layers": false,
        "snap_to_grid": false,
        "snap_to_grid_on_new_project": false,
        "zoom": null
    },
    "IOU": {
        "iourc_content": "",
        "license_check": true
    },
    "MainWindow": {
        "check_for_update": true,
        "debug_level": 0,
        "delay_console_all": 500,
        "direct_file_upload": false,
        "experimental_features": false,
        "geometry": "",
        "hdpi": false,
        "hide_getting_started_dialog": true,
        "hide_new_template_button": false,
        "hide_setup_wizard": true,
        "last_check_for_update": 0,
        "multi_profiles": false,
        "overlay_notifications": true,
        "recent_files": [],
        "recent_projects": [],
        "send_stats": true,
        "spice_console_command": "remote-viewer spice://%h:%p",
        "state": "",
        "stats_visitor_id": "757a5f9f-2dd8-46c4-b7d5-9b97cfc4c8bd",
        "style": "Charcoal",
        "symbol_theme": "Classic",
        "telnet_console_command": "xterm -T \"%d\" -e \"telnet %h %p\"",
        "vnc_console_command": "vncviewer %h:%p"
    },
    "NodesView": {
        "nodes_view_filter": 0
    },
    "Qemu": {
        "enable_hardware_acceleration": true,
        "require_hardware_acceleration": true
    },
    "Servers": {},
    "VMware": {
        "block_host_traffic": false,
        "host_type": "ws",
        "vmnet_end_range": 100,
        "vmnet_start_range": 2,
        "vmrun_path": ""
    },
    "VPCS": {
        "vpcs_path": ""
    },
    "VirtualBox": {
        "vboxmanage_path": ""
    },
    "version": "2.2.27"
}
EOT

# Adds vagrant into the ubridge group
usermod -aG ubridge vagrant

# VNC
mkdir /home/vagrant/.vnc
touch /home/vagrant/.vnc/passwd
chown vagrant:vagrant /home/vagrant/.vnc/passwd
x11vnc -storepasswd $VNC_CONNECTION_PASSWORD /home/vagrant/.vnc/passwd

cat <<EOT > /etc/systemd/system/x11vnc.service
[Unit]
Description=x11vnc remote desktop server
After=multi-user.target

[Service]
User=vagrant
Group=vagrant
Type=simple
ExecStart=/usr/bin/x11vnc -forever -loop -noxdamage -repeat -rfbauth /home/vagrant/.vnc/passwd -rfbport 5900 -shared

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOT

chown -R vagrant:vagrant /home/vagrant/.config/

systemctl daemon-reload
systemctl enable x11vnc

#sudo -i -u vagrant x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbauth /home/vagrant/.vnc/passwd -rfbport 5900 -shared

reboot
