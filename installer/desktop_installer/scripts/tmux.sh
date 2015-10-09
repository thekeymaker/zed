#!/bin/bash

# Install tmux
sudo apt-get install -y tmux
git clone https://github.com/thekeymaker/my_tmux_conf.git ./tmux_conf
cp ./tmux_conf/tmux.conf ~/.tmux_conf
rm -rf ./tmux_conf




