#!/bin/bash
mkdir working
cd working

# Install Atom
wget https://atom.io/download/deb .
mv deb atom.deb
sudo dpkg -i ./atom.deb

# Install Steam
wget https://steamcdn-a.akamaihd.net/client/installer/steam.deb .
sudo dpkg -i ./steam.deb

# Delete dir
cd ..
rm -rf working
