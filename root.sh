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
apt install unzip picom sddm rofi kitty thunar flameshot polybar neofetch feh git lxpolkit lxappearance xorg rofi wget curl network-manager network-manager-fortisslvpn snapd debian-goodies xfce4-notifyd -y
apt install papirus-icon-theme lxappearance fonts-noto-color-emoji fonts-firacode fonts-font-awesome libqt5svg5 qml-module-qtquick-controls nextcloud-desktop thunderbird remmina remmina-plugin-rdp remmina-plugin-secret vlc vim -y

# Install VSCode
curl -sSL https://packages.microsoft.com/keys/microsoft.asc -o microsoft.asc
gpg --no-default-keyring --keyring ./ms_signing_key_temp.gpg --import ./microsoft.asc
gpg --no-default-keyring --keyring ./ms_signing_key_temp.gpg --export > ./ms_signing_key.gpg
mv ms_signing_key.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
apt update
apt install code -y

# Install vivaldi web browser
wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | gpg --dearmor | dd of=/usr/share/keyrings/vivaldi-browser.gpg
echo "deb [signed-by=/usr/share/keyrings/vivaldi-browser.gpg arch=$(dpkg --print-architecture)] https://repo.vivaldi.com/archive/deb/ stable main" | dd of=/etc/apt/sources.list.d/vivaldi-archive.list
apt update && apt install vivaldi-stable -y


# Install Wine direct from WineHQ
wget -qO- https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor > /etc/apt/trusted.gpg.d/wine.gpg
echo 'deb http://dl.winehq.org/wine-builds/debian/ bullseye main' > /etc/apt/sources.list.d/wine.list
dpkg --add-architecture i386
apt update
apt install --install-recommends winehq-staging -y

# Install Vulkan drivers
apt install libvulkan1 mesa-vulkan-drivers vulkan-utils libgl1-mesa-glx:i386 libgl1-mesa-dri:i386 mesa-vulkan-drivers mesa-vulkan-drivers:i386 -y

# Fira Code Nerd Font variant needed
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v1.1.0/FiraCode.zip
unzip FiraCode.zip -d /usr/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v1.1.0/Meslo.zip
unzip Meslo.zip -d /usr/share/fonts
fc-cache -vf
apt install fonts-font-awesome -y

# Allow to run reboot, poweroff and halt without sudo password and make alias
echo '%sudo ALL = NOPASSWD: /sbin/halt, /sbin/reboot, /sbin/poweroff' >> /etc/sudoers
echo 'alias poweroff="sudo poweroff"' >> /home/$username/.bashrc
echo 'alias reboot="sudo reboot"' >> /home/$username/.bashrc
echo 'alias halt="sudo halt"' >> /home/$username/.bashrc

cd $builddir
mkdir -p /home/$username/.config
#cp .Xresources /home/$username
#cp .Xnord /home/$username
cp -R dotfiles/* /home/$username/.config/
chown -R $username:$username /home/$username

# Enable needed packages
systemctl enable NetworkManager.service
systemctl enable sddm

echo "Debian-nerox is installed! \nExit root and run the user.sh script."
