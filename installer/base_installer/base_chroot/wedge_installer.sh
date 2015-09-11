#!/bin/bash
locale-gen en_US.UTF-8

# Enable debug mode
set -x

function check_exit_code()
{
	RESULT=$?
	if [ "$RESULT" -ne 0 ]; then
		echo Failed for $1 >> log.txt
	fi
}

SYSNAME=`echo $1 | cut -d'|' -f1`
HOSTNAME=`echo $1 | cut -d'|' -f2`
ROOTPASS=`echo $1 | cut -d'|' -f3`
USERNAME=`echo $1 | cut -d'|' -f4`
USERPASS=`echo $1 | cut -d'|' -f5`

# Install dbus for next items
apt-get install --yes dbus

# Set Location
localectl set-locale LANG="en_US.UTF-8"

# Change hostname
hostnamectl set-hostname $HOSTNAME

# Change Root Password
echo "root:$ROOTPASS" | chpasswd

# Add User
adduser $USERNAME --gecos "${USERNAME},,," --disabled-password
echo "$USERNAME:$USERPASS" | chpasswd
addgroup $USERNAME sudo  # Add user to sudo group

# Update packages
apt-get update
apt-get install --yes ubuntu-minimal software-properties-common

# Prevent grub from asking to install
export DEBIAN_FRONTEND=noninteractive

apt-add-repository --yes ppa:zfs-native/stable
apt-add-repository --yes ppa:gnome3-team/gnome3-staging
apt-add-repository --yes ppa:gnome3-team/gnome3
apt-get update
apt-get install --yes --no-install-recommends linux-image-generic linux-headers-generic
apt-get install --yes ubuntu-zfs
apt-get install --yes grub2-common grub-pc
apt-get install --yes zfs-initramfs
apt-get install --yes vim
apt-get install --yes htop
apt-get install --yes git
apt-get --yes dist-upgrade

grub-install /dev/sda

#Fix grub boot parameters
sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/c\GRUB_CMDLINE_LINUX_DEFAULT="boot=zfs rpool=rpool bootfs=rpool/ROOT/zed-1"' /etc/default/grub


update-grub

# Install Gnome3
touch /etc/init.d/modemmanager  #File needed so gnome install doesn't fail
sed -i -e 's/main/main multiverse universe/g' /etc/apt/sources.list
apt-get update

grep -v '^#' ./install_ubuntu_gnome | while read -r line ; do  
	sudo apt-get install -y -pp $line
	check_exit_code $line
done


# Create snapshot of system
zfs snapshot rpool/ROOT/${SYSNAME}@afgnome
zfs snapshot rpool/HOME@afgnome

# Setup Custom Wallpaper
cp /base_chroot/resources/cubes.jpg /usr/share/backgrounds/gnome/
cp /base_chroot/resources/dots.png /usr/share/backgrounds/gnome/
runuser -l $USERNAME -c 'dbus-launch --exit-with-session gsettings set org.gnome.desktop.background picture-uri file:///usr/share/backgrounds/gnome/cubes.jpg'
runuser -l $USERNAME -c 'dbus-launch --exit-with-session gsettings set org.gnome.desktop.screensaver picture-uri file:///usr/share/backgrounds/gnome/dots.png'


# Setup Auto Login For User
sed -i "/AutomaticLoginEnable =/c\AutomaticLoginEnable = true" /etc/gdm/custom.conf
sed -i "/AutomaticLogin =/c\AutomaticLogin = $USERNAME" /etc/gdm/custom.conf
sed -i "/TimedLoginEnable =/c\TimedLoginEnable = true" /etc/gdm/custom.conf
sed -i "/TimedLogin =/c\TimedLogin = $USERNAME" /etc/gdm/custom.conf
sed -i "/TimedLoginDelay =/c\TimedLoginDelay = 10" /etc/gdm/custom.conf

# Set Time Zone
timedatectl set-timezone "America/Chicago"

echo
echo "Exiting Chroot"


