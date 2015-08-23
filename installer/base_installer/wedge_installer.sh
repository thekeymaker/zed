#!/bin/bash

# Setup apt-get
locale-gen en_US.UTF-8
apt-get update
apt-get install --yes ubuntu-minimal software-properties-common

# Prevent grub from asking to install
export DEBIAN_FRONTEND=noninteractive

apt-add-repository --yes ppa:zfs-native/stable
apt-get update
apt-get install --yes --no-install-recommends linux-image-generic linux-headers-generic
apt-get install --yes ubuntu-zfs
apt-get install --yes grub2-common grub-pc
apt-get install --yes zfs-initramfs
apt-get install --yes vim
apt-get install --yes htop
apt-get --yes dist-upgrade

grub-install /dev/sda

#Fix grub boot parameters
sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/c\GRUB_CMDLINE_LINUX_DEFAULT="boot=zfs rpool=rpool bootfs=rpool/ROOT/zed-1"' /etc/default/grub


update-grub

# Install Gnome3
touch /etc/init.d/modemmanager  #File needed so gnome install doesn't fail
sed -i -e 's/main/main universe/g' /etc/apt/sources.list
apt-get update
apt-get install --yes ubuntu-gnome-desktop


# Set Location
locale-gen
localectl set-locale LANG="en_US.UTF-8"


#ENTRY=`zenity --password --username`
#
#case $? in
#         0)
#	 	echo "User Name: `echo $ENTRY | cut -d'|' -f1`"
#	 	echo "Password : `echo $ENTRY | cut -d'|' -f2`"
#		;;
#         1)
#                echo "Stop login.";;
#        -1)
#                echo "An unexpected error has occurred.";;
#esac

ENTRY=`zenity --forms --title="Install Info" --text="Please fill in all information below:" --add-entry="Hostname:" --add-password="Root Password:" --add-entry="Username:" --add-password="User Password:"`

HOSTNAME=`echo $ENTRY | cut -d'|' -f1`
ROOTPASS=`echo $ENTRY | cut -d'|' -f2`
USERNAME=`echo $ENTRY | cut -d'|' -f3`
USERPASS=`echo $ENTRY | cut -d'|' -f4`

# Change hostname
echo $HOSTNAME > /etc/hostname

# Change Root Password
echo "root:$ROOTPASS" | chpasswd

# Add User
adduser $USERNAME --gecos"${USERNAME},,," --disabled-password
echo "$USERNAME:$USERPASS" | chpasswd
addgroup $USERNAME sudo  # Add user to sudo group

# Setup Auto Login For User
sed -i '/AutomaticLoginEnable/c\AutomaticLoginEnable = true' /etc/gdm/custom.conf
sed -i '/AutomaticLogin/c\AutomaticLogin = $USERNAME' /etc/gdm/custom.conf
sed -i '/TimedLoginEnable/c\TimedLoginEnable = true' /etc/gdm/custom.conf
sed -i '/TimedLogin/c\TimedLogin = $USERNAME' /etc/gdm/custom.conf
sed -i '/TimedLoginDelay/c\TimedLoginDelay = 10' /etc/gdm/custom.conf

# Set Time Zone
dpkg-reconfigure tzdata

echo
echo "Exiting Chroot"


