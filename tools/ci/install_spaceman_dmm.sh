#!/bin/bash
set -euo pipefail

source buildByond.conf
# bodge SpaceManiac/SpacemanDMM
wget -O ~/$1 "https://github.com/ZeWaka/SpacemanDMM/releases/download/$SPACEMAN_DMM_VERSION/$1"
chmod +x ~/$1
~/$1 --version
