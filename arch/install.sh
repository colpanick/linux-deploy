#!/bin/bash


# Configuration #############

DISK="/dev/sda"     #Standard Installs
#DISK="/dev/vda"    #Vultr installs

HOSTNAME="changeme"

#############################

# Let's get those partitions going
sfdisk $DISK << EOF
,2GiB,S
,200MiB,L,*
,,L
EOF


# Make and enable swap partition
mkswap $DISK"1"
swapon $DISK"1"

mkfs.ext4 $DISK"2" # Format boot partition
mkfs.ext4 $DISK"3" # Format root partition

# Mount root and boot partitions
mount $DISK"3" /mnt
mkdir /mnt/boot
mount $DISK"2" /mnt/boot

# Only use fastest mirrors
pacman --noconfirm -S pacman-contrib
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
cat /etc/pacman.d/mirrorlist | grep "United States" -A 1 > /etc/pacman.d/mirrorlist.USA
rankmirrors -n 6 /etc/pacman.d/mirrorlist.USA > /etc/pacman.d/mirrorlist

# Install arch on new root partition
pacstrap /mnt/ base base-devel linux mkinitcpio grub dhcpcd

# Generate fstab
genfstab -p /mnt > /mnt/etc/fstab

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /mnt/etc/locale.gen

arch-chroot /mnt locale-gen

echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf

rm /mnt/etc/localtime
ln -s /mnt/usr/share/zoneinfo/US/Eastern /mnt/etc/localtime

echo $HOSTNAME > /mnt/etc/hostname

arch-chroot /mnt mkinitcpio -p linux

arch-chroot /mnt grub-install $DISK
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

arch-chroot /mnt systemctl enable dhcpcd.service
