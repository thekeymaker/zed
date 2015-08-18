#!/bin/bash

# Setup apt-get
locale-gen en_US.UTF-8
apt-get update
apt-get install --yes ubuntu-minimal software-properties-common

apt-add-repository --yes ppa:zfs-native/stable
apt-get update
apt-get install --yes --no-install-recommends linux-image-generic linux-headers-generic
apt-get install --yes ubuntu-zfs
apt-get install --yes grub2-common grub-pc
apt-get install --yes zfs-initramfs
apt-get --yes dist-upgrade

#Fix grub boot parameters
sed -i 'GRUB_CMDLINE_LINUX_DEFAULT/c\GRUB_CMDLINE_LINUX_DEFAULT="boot=zfs rpool=rpool bootfs=rpool/ROOT/zed-1"' /etc/default/grub

grub-install /dev/sda
update-grub


passwd root


