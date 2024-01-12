#!/usr/bin/env bash
cd ~/
sudo rm -Rf ~/3DC_Build
git clone https://github.com/brotherchris/3DC_Build.git
cd 3DC_Build
chmod 777 3DC_NP_Build.sh
chmod 777 clean.sh
$SHELL