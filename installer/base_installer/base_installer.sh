#!/bin/bash
# base_installer.sh

POOL_NAME="zpool"

WELCOME_TEXT=`cat <<EOF
Welcome to Zed Base Installer!

In the following file browser please select the hard
drive to install the system too.
EOF
`

echo -n "$WELCOME_TEXT" | zenity --title "WELCOME" --text-info --width=500 --height=400

cd /dev/disk/by-id

HARDDRIVE_PATH=$(zenity --file-selection)

echo $HARDDRIVE_PATH


apt-get install --yes mbr

# Install Needed ZFS tools
apt-add-repository --yes ppa:zfs-native/stable
apt-get update
apt-get install --yes debootstrap spl-dkms zfs-dkms ubuntu-zfs


# Format HD
#Prompt would be nice
echo "Formating HD"
install-mbr $HARDDRIVE_PATH
(echo n; echo p; echo 1; echo; echo +256M; echo n; echo p; echo 2; echo; echo; echo a; echo 1; echo p; echo w) | fdisk $HARDDRIVE_PATH

mke2fs -m 0 -L /boot/grub -j ${HARDDRIVE_PATH}-part1

zpool create -o ashift=9 $POOL_NAME ${HARDDRIVE_PATH}-part2

zfs create ${POOL_NAME}/ROOT
zfs create ${POOL_NAME}/ROOT/zed-1

zfs umount -a

zfs set mountpoint=/ ${POOL_NAME}/ROOT/zed-1
zfs set bootfs=${POOL_NAME}/ROOT/zed-1 $POOL_NAME

zpool export $POOL_NAME

zpool import -d /dev/disk/by-id -R /mnt $POOL_NAME

mkdir -p /mnt/boot/grub
mount ${HARDDRIVE_PATH}-part1 /mnt/boot/grub

debootstrap trusty /mnt

cp /etc/hostname /mnt/etc/
cp /etc/hosts /mnt/etc/

echo "${HARDDRIVE_PATH}-part1  /boot/grub  auto  defaults  0  1" >> /mnt/etc/fstab


mount --bind /dev  /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys  /mnt/sys

#chroot /mnt /bin/bash --login




