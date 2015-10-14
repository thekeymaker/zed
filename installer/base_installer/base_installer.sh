#!/bin/bash
# base_installer.sh

RELEASE="vivid"  # Version of Ubuntu to use
POOL_NAME=rpool  # Pool name

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

WD=`pwd`

WELCOME_TEXT=`cat <<EOF
Welcome to Zed Base Installer!

The following prompt will ask you to give some imformation
about the machine name and users of this computer.  The user
that is created will also be given sudo permissions. 

After that you will be asked which hard drive the installer 
should install too.  

Thanks againg for trying this install!
EOF
`

check_if_user_is_root

# Welcome Screen
echo -n "$WELCOME_TEXT" | zenity --title "WELCOME" --text-info --width=500 --height=400

# Get user settings
ENTRY=`zenity --forms --title="Install Info" --text="Please fill in all information below:" --add-entry="Hostname:" --add-password="Root Password:" --add-entry="Username:" --add-password="User Password:"`

if [ -z $ENTRY]; then
   echo "Failed to get user data"
   exit
fi

# Saves vars in the format ( var1 | var2 | ... ) to be passed into chroot environment
CHROOTVAR+="${ENTRY}|"

# Set install hard drive
cd /dev/disk/by-id
HARDDRIVE_PATH=$(zenity --file-selection)

if [ -z $HARDDRIVE_PATH]; then
   echo "Failed to get hard drive"
   exit
fi


# Install Needed ZFS tools
apt-add-repository --yes ppa:zfs-native/stable
check_exit_code
apt-get update
apt-get install --yes debootstrap ubuntu-zfs
check_exit_code


# Partition hard drive with boot/swap/zfs 
echo
echo "Formating HD"
parted -a optimal ${HARDDRIVE_PATH} < ${WD}/partitions.txt
sync

# Enable Swap
echo
echo "Enable Swap"
sleep 2
mkswap -L swap ${HARDDRIVE_PATH}-part2
sleep 2
swapon ${HARDDRIVE_PATH}-part2


# Create Zpools
zpool create -d -o feature@async_destroy=enabled -o feature@empty_bpobj=enabled -o feature@lz4_compress=enabled -o ashift=12 -O compression=lz4 $POOL_NAME ${HARDDRIVE_PATH}-part3

zfs create ${POOL_NAME}/ROOT
zfs create ${POOL_NAME}/BOOT
zfs create ${POOL_NAME}/HOME

zfs umount -a

# Set mount points for new datasets
zfs set mountpoint=/     ${POOL_NAME}/ROOT
zfs set mountpoint=/boot ${POOL_NAME}/BOOT
zfs set mountpoint=/home ${POOL_NAME}/HOME
	
zpool export $POOL_NAME

# Import pool under /mnt
zpool import -d /dev/disk/by-id -R /mnt $POOL_NAME

# Load minimal Ubuntu file structure
debootstrap $RELEASE /mnt

cp /etc/hostname /mnt/etc/
cp /etc/hosts /mnt/etc/

# Enable swap in fstab
echo "${HARDDRIVE_PATH}-part2  none   swap  sw        0  0" >> /mnt/etc/fstab

# Mount needed system directories
mount --bind /dev  /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys  /mnt/sys

# Could be used to limit memory usage of zarc.  Not tested
#cat /etc/modprobe.d/zfs-arc-max.conf 
#options zfs zfs_arc_max=1073741824

# Create link to hard drive so grub can find it and doesn't error out
HARDDRIVE=`basename ${HARDDRIVE_PATH}`
ln -s ${HARDDRIVE_PATH}-part3 /dev/${HARDDRIVE}-part3

# Copy over install files form base_chroot directory 
cd $WD
cp -r ./base_chroot /mnt

# CHROOT!
echo
echo "Chroot!"
chroot /mnt /bin/bash /base_chroot/wedge_installer.sh $CHROOTVAR
#chroot /mnt /bin/bash --login # Here for testing

# Remove wedge script
rm -rf /mnt/base_chroot

# Create snapshot of system 
zfs snapshot ${POOL_NAME}/ROOT@bInit
zfs snapshot ${POOL_NAME}/BOOT@bInit
zfs snapshot ${POOL_NAME}/HOME@bInit

echo
echo "Finished!"


