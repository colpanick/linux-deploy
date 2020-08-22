#!/bin/bash


# Configuration #############

DISK="/dev/sda"     #Standard Installs
#DISK="/dev/vda"    #Vultr installs

HOSTNAME="changeme"

#############################

if [ ! $1 ]
then
    echo "Disk to use"
    echo "  1. /dev/sda (Standard)"
    echo "  2. /dev/vda (Vultr)"
    echo "  3. Other..."
    echo
    read disk_sel
    
    case $disk_sel in
        "1")
            DISK="/dev/sda"
            ;;
        "2")
            DISK="/dev/vda"
            ;;
        "3")
            echo "Disk: "
            read DISK
            ;;
        *)
            echo "Invalid Selection"
            exit 1
        esac

    echo "Hostname: "
    read HOSTNAME
fi

if [ $1 ] && [ ! $1 = "-d" ]
then
    echo
    echo "Usage: install.sh [-d]"
    echo
    echo "-d: Use default configuration"
    echo
    exit 1
fi

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

arch-chroot /mnt passwd -d root

arch-chroot /mnt systemctl enable dhcpcd.service
