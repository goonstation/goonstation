#!/bin/bash
set -euo pipefail

source buildByond.conf

source ~/.nvm/nvm.sh
nvm install $NODE_VERSION
nvm use $NODE_VERSION
