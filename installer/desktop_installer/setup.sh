#!/bin/bash

function check_exit_code()
{
	RESULT=$?
	if [ "$RESULT" -ne 0 ]; then
		echo Failed for $1
	fi
}

# Uninstall software
for line in `cat uninstall`;do
	sudo apt-get purge -y $line
	check_exit_code($line)
done

# Install Updates
sudo apt-get update        # Fetches the list of available updates
sudo apt-get upgrade       # Strictly upgrades the current packages
sudo apt-get dist-upgrade  # Installs updates (new ones)

# Install ppa
for line in `cat ppa`;do
	sudo add-apt-repository -y $line
	check_exit_code($line)
done

sudo apt-get update

# Install software
for line in `cat install`;do
	sudo apt-get install -y $line
	check_exit_code($line)
done

# Install wget software
./wget.sh
