#!/bin/bash

# Install Syncthing
sudo add-apt-repository -y ppa:ytvwld/syncthing
sudo update 
sudo apt-get install -y syncthing

# Load in scripts
mkdir ~/scripts
cp ./resources/syncthing-start ~/scripts

# Add syncthing to startup
mkdir -p ~/.config/autostart
cp ./resources/syncthing-start.desktop ~/.config/autostart
