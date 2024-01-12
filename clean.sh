#!/usr/bin/env bash
cd ~/
rm -Rf ~/3DC_Build
git clone https://github.com/brotherchris/3DC_Build.git
cd 3DC_Build
chmod 777 3DC_NP_Build.sh
chmod 777 clean.sh
# start another shell and replacing the current
exec /bin/bash