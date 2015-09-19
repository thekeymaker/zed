#!/bin/bash

WD=`pwd`

function check_exit_code()
{
	RESULT=$?
	if [ "$RESULT" -ne 0 ]; then
		echo Failed for $1 >> log.txt
	fi
}


## Uninstall software
#for line in `cat ./lists/uninstall`;do
#	sudo apt-get purge -y $line
#	check_exit_code($line)
#done

# Install Updates
sudo apt-get update        # Fetches the list of available updates
sudo apt-get upgrade       # Strictly upgrades the current packages
sudo apt-get dist-upgrade  # Installs updates (new ones)

# Install ppa
for line in `cat ./lists/ppa`;do
	sudo add-apt-repository -y $line
	check_exit_code $line
done

sudo apt-get update

# Install software
for line in `cat ./lists/install`;do
	sudo apt-get install -y $line
	check_exit_code $line
done

cd $WD

# Install wget software
./wget.sh

cd $WD

# Install git 
./git.sh

cd $WD

# Install extensions
./extensions.sh

cd $WD

# Install user settings
dconf load / < ./lists/settings

cd $WD

# Install vim 
./vim.sh

cd $WD

# Install tmux
./tmux.sh

cd $WD
# Load in scripts
mkdir ~/scripts
cp ./resources/syncthing-start ~/scripts

# Add syncthing to startup
mkdir -p ~/.config/autostart
cp ./resources/syncthing-start.desktop ~/.config/autostart

cd $WD

# Install nfs
./nfs.sh

echo 
echo "Finished!"
