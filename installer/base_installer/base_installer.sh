#!/bin/bash
# base_installer.sh

# Enable debug mode
set -x

WD=`pwd`

RELEASE="vivid"
SYSNAME="zed-1"
CHROOTVAR+="${SYSNAME}|"
echo $CHROOTVAR


function check_exit_code()
{
	RESULT=$?
	if [ "$RESULT" -ne 0 ]; then
		echo "Installer failed"
		exit "$RESULT"
	fi
}

function check_if_user_is_root()
{
	if [ `id -un` != "root" ]; then
		echo "You need root privileges"
		exit 2
	fi
}

POOL_NAME=rpool

WELCOME_TEXT=`cat <<EOF
Welcome to Zed Base Installer!

In the following file browser please select the hard
drive to install the system too.
EOF
`

check_if_user_is_root

# Welcome Screen
echo -n "$WELCOME_TEXT" | zenity --title "WELCOME" --text-info --width=500 --height=400

# Get user settings
ENTRY=`zenity --forms --title="Install Info" --text="Please fill in all information below:" --add-entry="Hostname:" --add-password="Root Password:" --add-entry="Username:" --add-password="User Password:"`
CHROOTVAR+="${ENTRY}|"

# Set install hard drive
cd /dev/disk/by-id
HARDDRIVE_PATH=$(zenity --file-selection)


# Install Needed ZFS tools
apt-add-repository --yes ppa:zfs-native/stable
apt-get update
apt-get install --yes debootstrap ubuntu-zfs

check_exit_code


# Format HD
echo "Formating HD"
parted -a optimal ${HARDDRIVE_PATH} < ${WD}/partitions.txt


sync
echo
echo "Format Partitions"
sleep 2
mkswap -L swap ${HARDDRIVE_PATH}-part3
sleep 2
mkfs.ext3 ${HARDDRIVE_PATH}-part2
sleep 2
swapon ${HARDDRIVE_PATH}-part3


# Create Zpools
zpool create -d -o feature@async_destroy=enabled -o feature@empty_bpobj=enabled -o feature@lz4_compress=enabled -o ashift=12 -O compression=lz4 $POOL_NAME ${HARDDRIVE_PATH}-part4
# zpool export rpool

zfs create ${POOL_NAME}/ROOT
zfs create ${POOL_NAME}/ROOT/$SYSNAME
zfs create ${POOL_NAME}/HOME

zfs umount -a

zfs set mountpoint=/ ${POOL_NAME}/ROOT/$SYSNAME
zfs set mountpoint=/home ${POOL_NAME}/HOME
zpool set bootfs=${POOL_NAME}/ROOT/$SYSNAME $POOL_NAME
	
zpool export $POOL_NAME

zpool import -d /dev/disk/by-id -R /mnt $POOL_NAME

mkdir -p /mnt/boot
mount ${HARDDRIVE_PATH}-part2 /mnt/boot/

debootstrap $RELEASE /mnt

cp /etc/hostname /mnt/etc/
cp /etc/hosts /mnt/etc/

echo "${HARDDRIVE_PATH}-part2  /boot  auto  defaults  0  1" >> /mnt/etc/fstab
echo "${HARDDRIVE_PATH}-part3  none   swap  sw        0  0" >> /mnt/etc/fstab

mount --bind /dev  /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys  /mnt/sys

#cat /etc/modprobe.d/zfs-arc-max.conf 
#options zfs zfs_arc_max=1073741824

#Setup neede items for grub
HARDDRIVE=`basename ${HARDDRIVE_PATH}`
ln -s ${HARDDRIVE_PATH} /dev/${HARDDRIVE}-part4

#Copy`
cd $WD
cp -r ./base_chroot /mnt

# CHROOT!
echo "Chroot!"
chroot /mnt /bin/bash /base_chroot/wedge_installer.sh $CHROOTVAR
#chroot /mnt /bin/bash --login

# Remove wedge script
rm -rf /mnt/base_chroot

# Copy in this source file for later config
#mkdir -p /mnt/home/${USERNAME}/scripts
#cp -r ${PWD}/../desktop_installer /mnt/home/${USERNAME}/scripts

# Set /home to lagacy to mount through fstab. Maybe find a better way in the future
zfs set mountpoint=legacy ${POOL_NAME}/HOME
echo "${POOL_NAME}/HOME /home zfs rw,noatime 0 0" >> /mnt/etc/fstab


# Create snapshot of system
zfs snapshot ${POOL_NAME}/ROOT/${SYSNAME}@init

echo "Finished!"


