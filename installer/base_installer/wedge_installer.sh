#!/bin/bash

# Setup apt-get
locale-gen en_US.UTF-8
apt-get update
apt-get install ubuntu-minimal software-properties-common


apt-add-repository --yes ppa:zfs-native/stable
apt-add-repository --yes ppa:zfs-native/grub
apt-get update
apt-get install --no-install-recommends linux-image-generic linux-headers-generic
apt-get install ubuntu-zfs
apt-get install grub2-common grub-pc
apt-get install zfs-initramfs
apt-get dist-upgrade

passwd root


