#!/bin/bash

USER=`whoami`


ENTRY=`zenity --list \
  --title="Choose NFS Setup" \
  --column="Type" --column="Description" \
  Client "This computer will connect to my NFS server" \
  Server "This computer will host my NFS server" `

if [ $ENTRY == "Client" ]; then
	echo "Setup Client"
	sudo apt-get install nfs-common
	addgroup nfs --gid 1500
	usermod -a -G nfs $USER

	sudo apt-get install autofs
	sudo cp ./resources/auto.master /etc/*
	sudo cp ./resources/auto.nfs /etc/*
	sudo mkdir -p /mnt/nfs

fi

if [ $ENTRY == "Server" ]; then
	echo "Setup Server"
	sudo apt-get install nfs-kernel-server
fi


