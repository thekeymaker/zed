#!/bin/bash

mkdir ~/.fonts

# Install cmake and python-dev - needed for ycm plugin
sudo apt-get install cmake
sudo apt-get install python-dev

git clone https://github.com/thekeymaker/my_vimrc_files.git ~/.vim

cd ~/.vim

git submodule init
git submodule update --init --recursive

cd bundle/youcompleteme

./install.sh

# Install needed fonts
cd ~/.vim/fonts/Meslo
cp *.otf ~/.fonts/

# Set font settings for dconf
dconf write /org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9/font "'Meslo LG L DZ for Powerline 12'"

