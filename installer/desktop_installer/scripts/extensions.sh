#!/bin/bash

function check_exit_code()
{
	RESULT=$?
	if [ "$RESULT" -ne 0 ]; then
		echo Failed for $1 >> extensions-log.txt
	fi
}

function check_if_user_is_root()
{
	if [ `id -un` == "root" ]; then
		echo "You can't be root for this setup"
		exit 2
	fi
}

check_if_user_is_root

DIRNAME=gnome-extensions-installer

git clone https://github.com/ianbrunelli/gnome-shell-extension-installer.git $DIRNAME

cd $DIRNAME

sudo cp ./gnome-shell-extension-installer /bin

cd ..

whereis gnome-shell-extension-installer

rm -rf $DIRNAME

#set -x

# Install extensions
cut -c-3 ./lists/extensions | while read -r line ; do  
	gnome-shell-extension-installer --yes $line
	#check_exit_code $line
done

# Restart Gnome Shell
#gnome-shell --replace
