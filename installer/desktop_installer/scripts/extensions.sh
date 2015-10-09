#!/bin/bash

DIRNAME=gnome-extensions-installer

function check_exit_code()
{
	RESULT=$?
	if [ "$RESULT" -ne 0 ]; then
		echo Failed for $1 >> extensions-log.txt
	fi
}


git clone https://github.com/ianbrunelli/gnome-shell-extension-installer.git $DIRNAME


cd $DIRNAME

# Install extensions
cut -c-3 ../lists/extensions | while read -r line ; do  
	./gnome-shell-extension-installer --yes $line
	#check_exit_code $line
done

cd ..

rm -rf $DIRNAME

# Restart Gnome Shell
#gnome-shell --replace
