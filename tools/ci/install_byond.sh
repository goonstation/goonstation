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
  if ! curl --fail --connect-timeout 2 --max-time 10 "https://spacestation13.github.io/byond-builds/${BYOND_MAJOR_VERSION}/${BYOND_MAJOR_VERSION}.${BYOND_MINOR_VERSION}_byond_linux.zip" -o byond.zip -A "GoonstationCI/2.0"; then
      echo "Mirror download failed, falling back to byond.com"
      if ! curl --fail --connect-timeout 2 --max-time 10 "http://www.byond.com/download/build/${BYOND_MAJOR_VERSION}/${BYOND_MAJOR_VERSION}.${BYOND_MINOR_VERSION}_byond_linux.zip" -o byond.zip -A "GoonstationCI/2.0"; then
          echo "BYOND download failed too :("
          exit 1
      fi
  fi
  unzip byond.zip
  rm byond.zip
  cd byond
  make here
  echo "$BYOND_MAJOR_VERSION.$BYOND_MINOR_VERSION" > "$HOME/BYOND/version.txt"
  cd ~/
fi

