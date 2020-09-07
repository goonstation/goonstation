#!/bin/bash
set -euo pipefail

source buildByond.conf

if [ -d "$HOME/BYOND/byond/bin" ] && grep -Fxq "${BYOND_MAJOR_VERSION}.${BYOND_MINOR_VERSION}" $HOME/BYOND/version.txt;
then
  echo "Using cached directory."
else
  echo "Setting up BYOND."
  rm -rf "$HOME/BYOND"
  mkdir -p "$HOME/BYOND"
  cd "$HOME/BYOND"
  curl "http://www.byond.com/download/build/${BYOND_MAJOR_VERSION}/${BYOND_MAJOR_VERSION}.${BYOND_MINOR_VERSION}_byond_linux.zip" -o byond.zip
  unzip byond.zip
  rm byond.zip
  cd byond
  make here
  echo "$BYOND_MAJOR_VERSION.$BYOND_MINOR_VERSION" > "$HOME/BYOND/version.txt"
  cd ~/
fi

