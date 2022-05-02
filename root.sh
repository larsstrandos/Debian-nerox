#!/bin/bash

# Change Debian to SID Branch
cp /etc/apt/sources.list /etc/apt/sources.list.bak
cp sources.list /etc/apt/sources.list

username=$(id -u -n 1000)
builddir=$(pwd)

# Update packages list
apt update

# Upgrade all packages
apt upgrade -y

# Build and install i3-gaps
apt purge i3
apt install meson dh-autoreconf libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev xcb libxcb1-dev libxcb-icccm4-dev libyajl-dev libev-dev libxcb-xkb-dev libxcb-cursor-dev libxkbcommon-dev libxcb-xinerama0-dev libxkbcommon-x11-dev libstartup-notification0-dev libxcb-randr0-dev libxcb-xrm0 libxcb-xrm-dev libxcb-shape0 libxcb-shape0-dev -y
git clone https://github.com/Airblader/i3 i3-gaps
cd i3-gaps
mkdir -p build && cd build
meson --prefix /usr/local
ninja
ninja install
cd $builddir

# Make .desktop for i3-gaps
mkdir /usr/share/xsessions/
cp i3-gaps.desktop /usr/share/xsessions/i3-gaps.desktop

# Add base packages
apt install unzip picom sddm rofi kitty thunar flameshot polybar neofetch feh git lxpolkit lxappearance xorg rofi wget curl network-manager network-manager-fortisslvpn snapd -y
apt install papirus-icon-theme lxappearance fonts-noto-color-emoji fonts-firacode fonts-font-awesome libqt5svg5 qml-module-qtquick-controls nextcloud-desktop
 thunderbird steam remmina remmina-plugin-rdp remmina-plugin-secret vlc -y

# Install spotify
curl -sS https://download.spotify.com/debian/pubkey_5E3C45D7B312C643.gpg | sudo apt-key add - 
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
apt update
apt install spotify-client -y

# Install Discord
wget -O ./discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
apt install ./discord.deb -y

# Install Teams
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/ms-teams stable main" > /etc/apt/sources.list.d/teams.list'
apt update
apt install teams -y

# Install Onlyoffice
snap install onlyoffice-desktopeditors -y

# Install Vivaldi webbrowser
apt update
apt -y install wget gnupg2 software-properties-common
wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo apt-key add -
add-apt-repository 'deb https://repo.vivaldi.com/archive/deb/ stable main' 
apt update
apt install vivaldi-stable -y

# Install Wine direct from WineHQ
dpkg --add-architecture i386
wget -qO- https://dl.winehq.org/wine-builds/winehq.key | apt-key add -
apt install software-properties-common && sudo add-apt-repository 'deb https://dl.winehq.org/wine-builds/debian/ bullseye main'
apt update
apt install --install-recommends winehq-devel -y

# Install Vulkan drivers
apt install libvulkan1 libvulkan1:i386 -y

# Install Lutris
echo "deb http://download.opensuse.org/repositories/home:/strycore/Debian_11/ ./" | sudo tee /etc/apt/sources.list.d/lutris.list
wget -q https://download.opensuse.org/repositories/home:/strycore/Debian_11/Release.key -O- | sudo apt-key add -
apt update
apt install lutris -y

# Install Heroic launcher
bash <(wget -O- https://raw.githubusercontent.com/Heroic-Games-Launcher/HeroicGamesLauncher/main/madrepo.sh)
apt install heroic -y

# Install GNS3
deb http://ppa.launchpad.net/gns3/ppa/ubuntu trusty main
deb-src http://ppa.launchpad.net/gns3/ppa/ubuntu trusty main
aptupdate
apt install gns3-gui -y

# Fira Code Nerd Font variant needed
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v1.1.0/FiraCode.zip
unzip FiraCode.zip -d /usr/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v1.1.0/Meslo.zip
unzip Meslo.zip -d /usr/share/fonts
fc-cache -vf

# Allow to run reboot, poweroff and halt without sudo password and make alias
echo '%sudo ALL = NOPASSWD: /sbin/halt, /sbin/reboot, /sbin/poweroff' >> /etc/sudoers
echo 'alias poweroff="sudo poweroff"' >> /home/$username/.bashrc
echo 'alias reboot="sudo reboot"' >> /home/$username/.bashrc
echo 'alias halt="sudo halt"' >> /home/$username/.bashrc

cd $builddir
mkdir -p /home/$username/.config
#cp .Xresources /home/$username
#cp .Xnord /home/$username
#cp -R dotfiles/* /home/$username/.config/
chown -R $username:$username /home/$username

# Enable needed packages
systemctl enable NetworkManager.service
systemctl enable sddm