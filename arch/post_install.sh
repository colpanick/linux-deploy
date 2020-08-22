#!/bin/bash

sdir=$(dirname $0)

# At one point, installer should move linux-deploy to /root
echo "configuring dotfiles for root"
cp /root/linux-deploy/get_dotfiles /root
. /root/get_dotfiles
. /root/.bashrc

echo "Installing common packages"
pkgs=$(cat $sdir/pkglists/common | tr "\n" " ")
pacman --noconfirm -S $pkgs

# This is too specific to virtual box
echo "Installing Virtual Box utils and video driver"
pkgs=$(cat $sdir/pkglists/vbox | tr "\n" " ")
pacman --noconfirm -S $pkgs

echo "Installing GUI"
pkgs=$(cat $sdir/pkglists/gui | tr "\n" " ")
pacman --noconfirm -S $pkgs

echo "Installing GUI apps"
pkgs=$(cat $sdir/pkglists/gui-apps | tr "\n" " ")
pacman --noconfirm -S $pkgs

echo "Creating user jorge"
useradd -m jorge
usermod -G wheel -a jorge

echo "Password for jorge:"
passwd jorge

echo "Password for root"
passwd

echo setting up dotfiles script for jorge
cp /root/linux-deploy/get_dotfiles /home/jorge
# auto run get_dotfiles upon first login of intractive shell
echo "[[ $- != *i* ]] && . /home/jorge/get_dotfiles" >> /home/jorge/.bashrc

echo setting up sudo
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

echo "installing yay"
git clone https://aur.archlinux.org/yay.git /tmp/yay
chown jorge:jorge /tmp/yay
cd /tmp/yay
sudo -u jorge makepkg -si --noconfirm
cd -


echo "Installing AUR apps"
pkgs=$(cat $sdir/pkglists/aur-apps | tr "\n" " ")
sudo -u jorge yay --noconfirm -S $pkgs
