#!/bin/bash

cd /ss13_server

if [ -f "data/restarting" ]; then
  if [ "$(find data/restarting -mmin +5)" ]; then
    # Server has been restarting for over 5 minutes, assume something went wrong
    echo -n "restart_stuck"
    exit 1
  else
    # Server is currently restarting, just treat it as healthy while we wait
    echo -n "restarting"
    exit 0
  fi
else
  bash tools/byond_fetch.sh localhost $SS13_PORT "?ping" || exit 1
fi
