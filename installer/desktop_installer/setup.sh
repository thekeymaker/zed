#!/bin/bash

WD=`pwd`
SCRIPTDIR=".scripts"

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

# Run all installer scrips
find ./scripts -name "*.sh" | while read script; do
	cd $WD
	$script; 
done

cd $WD

echo 
echo "Finished!"
