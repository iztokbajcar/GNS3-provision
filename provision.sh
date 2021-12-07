
export DEBIAN_FRONTEND=noninteractive 

# Adds GNS3 ppa repository (and updates the package lists)
add-apt-repository ppa:gns3/ppa

# Desktop
apt-get install -y gnome-session gnome-terminal

# Installs GNS3
apt-get install -y gns3-server gns3-gui

usermod -aG ubridge vagrant
reboot
