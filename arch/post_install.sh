#!/bin/bash

install_packages () {
    echo "Installing $1 packages"
    pkgs=$(cat $sdir/pkglists/$1 | tr "\n" " ")
    pacman --noconfirm -S $pkgs
}

sdir=$(dirname $0)

echo "configuring dotfiles for root"
cp /root/linux-deploy/get_dotfiles /root
. /root/get_dotfiles
. /root/.bashrc

install_packages common

read -p Install GUI? [y/n]
drivers=(None virtual-box xf86-video-amdgpu xf86-video-ati xf86-video-intel xf86-video-nouveau nvidia nvidia-390xx)
if [ $REPLY == y ] || [ $REPLY == yes ]
then
    echo Please select video driver
    echo Card(s) found:
    lspci | grep -e VGA -e 3D
    echo Options:
    for num in ${!drivers[*]}
    do
        echo $num. $${drivers[$num]} 
    done
    read -p Selection:
    if [ $REPLY -gt 1 ] || [ $REPLY -lt ${#drivers[*]} ]
    then
        pacman -S --noconfirm ${drivers[$REPLY]}
    elif [ $REPLY -eq 1 ]
    then
        install_packages vbox
    else
        echo Skipping video driver installation
    fi
    
    install_packages gui-apps

fi


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
