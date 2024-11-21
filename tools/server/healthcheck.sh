#!/bin/bash

cd /ss13_server

if [ -f "data/restarting" ]; then
  exit 0
else
  bash tools/byond_fetch.sh localhost $SS13_PORT "?ping" || exit 1
fi
