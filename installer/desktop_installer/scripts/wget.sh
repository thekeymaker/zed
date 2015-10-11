#!/bin/bash
mkdir working
cd working

# Install Chrome
sudo apt-get install libxss1 libappindicator1 libindicator7
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb .
sudo dpkg -i google-chrome*.deb

# Install Atom
#wget https://atom.io/download/deb .
#mv deb atom.deb
#sudo dpkg -i ./atom.deb

# Install Remarkable
wget https://remarkableapp.github.io/files/remarkable_1.62_all.deb .
mv remarkable* remarkable.deb
sudo dpkg -i ./remarkable.deb


# Install Steam
wget https://steamcdn-a.akamaihd.net/client/installer/steam.deb .
sudo dpkg -i ./steam.deb

# Delete dir
cd ..
rm -rf working
