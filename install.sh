#!/bin/bash

# Check if Script is Run as Root
if [[ $EUID -ne 0 ]]; then
  echo "You must be a root user to run this script, please run sudo ./install.sh" 2>&1
  exit 1
fi

username=$(id -u -n 1000)
builddir=$(pwd)

# Install Terminus Fonts
sudo apt install fonts-terminus

# Set the font to Terminus Fonts
setfont /usr/share/consolefonts/Uni3-TerminusBold28x14.psf.gz

# Update packages list and update system
apt update
apt upgrade -y

# Install nala
apt install nala -y

# Clear the screen
clear

# Installing Essential Programs 
nala install git sudo awesome awesome-extra plymouth alacritty flatpak lightdm feh rofi picom thunar x11-xserver-utils unzip wget curl apt-transport-https gpg pipewire wireplumber pavucontrol build-essential libx11-dev firefox-esr papirus-icon-theme -y

# Setup VSCode Repository
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg

nala update

# Installing Other less important Programs
nala install code -y

# installs fnm (Fast Node Manager)
# sudo -u $username curl -fsSL https://fnm.vercel.app/install | bash
# download and install Node.js
# sudo -u $username fnm use --install-if-missing 20


# Configure Flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak override --filesystem=/usr/share/themes
flatpak override --filesystem=/usr/share/icons
flatpak override --env=GTK_THEME=Nordic
flatpak override --env=ICON_THEME=Papirus-Dark


# Setup dot config files
cd $builddir

cp -R user/. /home/$username/
chown -R $username:$username /home/$username

# System wide configuration
cp -Rf root/* /

update-grub
plymouth-set-default-theme joi
update-initramfs -u
fc-cache -vf

# Enable graphical login and change target from CLI to GUI
#systemctl enable lightdm
#systemctl set-default graphical.target

# Enable wireplumber audio service
#sudo -u $username systemctl --user enable wireplumber.service

# Use nala
bash scripts/usenala.sh