#!/bin/bash
# base_installer.sh

WD=`pwd`

RELEASE="vivid"

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

echo -n "$WELCOME_TEXT" | zenity --title "WELCOME" --text-info --width=500 --height=400

cd /dev/disk/by-id

HARDDRIVE_PATH=$(zenity --file-selection)

echo $HARDDRIVE_PATH



# Install Needed ZFS tools
apt-add-repository --yes ppa:zfs-native/stable
apt-get update
apt-get install --yes debootstrap ubuntu-zfs

check_exit_code


# Format HD
#Prompt would be nice
# Add swap/boot/ and root
echo "Formating HD"
parted -a optimal ${HARDDRIVE_PATH} < ${WD}/partitions.txt

sync
echo
echo "time format"
sleep 2
#mkswap -L swap ${HARDDRIVE_PATH}-part1
sleep 2
mkfs.ext3 ${HARDDRIVE_PATH}-part2
sleep 2

echo
echo

#Label disks

zpool create -d -o feature@async_destroy=enabled -o feature@empty_bpobj=enabled -o feature@lz4_compress=enabled -o ashift=12 -O compression=lz4 $POOL_NAME ${HARDDRIVE_PATH}-part3
# zpool export rpool

zfs create ${POOL_NAME}/ROOT
zfs create ${POOL_NAME}/ROOT/zed-1

zfs umount -a

zfs set mountpoint=/ ${POOL_NAME}/ROOT/zed-1
zpool set bootfs=${POOL_NAME}/ROOT/zed-1 $POOL_NAME
	
zpool export $POOL_NAME

zpool import -d /dev/disk/by-id -R /mnt $POOL_NAME

mkdir -p /mnt/boot
mount ${HARDDRIVE_PATH}-part2 /mnt/boot/

debootstrap $RELEASE /mnt

cp /etc/hostname /mnt/etc/
cp /etc/hosts /mnt/etc/

echo "${HARDDRIVE_PATH}-part2  /boot  auto  defaults  0  1" >> /mnt/etc/fstab

mount --bind /dev  /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys  /mnt/sys

#cat /etc/modprobe.d/zfs-arc-max.conf 
#options zfs zfs_arc_max=1073741824

#Setup neede items for grub
HARDDRIVE=`basename ${HARDDRIVE_PATH}`
ln -s ${HARDDRIVE_PATH} /dev/${HARDDRIVE}-part3

#Copy`
cd $WD
cp ./wedge_installer.sh /mnt

echo "Chroot!"
chroot /mnt /bin/bash ./wedge_installer.sh
#chroot /mnt /bin/bash --login

# Remove wedge script
rm -f /mnt/wedge_installer.sh

echo "Finished!"




