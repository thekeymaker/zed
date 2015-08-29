#!/bin/bash

# Install cmake - needed for ycm plugin
sudo apt-get install cmake
sudo apt-get install python-dev

git clone https://github.com/thekeymaker/my_vimrc_files.git ~/.vim

cd ~/.vim

git submodule init
git submodule update --init --recursive

cd bundle/youcompleteme

./install.sh
