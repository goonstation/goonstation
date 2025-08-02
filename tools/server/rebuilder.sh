#!/bin/bash

ROOTDIR=/pop/ss13/servers
WATCHDIRS=()

for i in "$@"; do
  WATCHDIRS+=("$ROOTDIR/$i/game/data/triggers")
done

echo "Watching directories: ${WATCHDIRS[@]}"

inotifywait -m -e create ${WATCHDIRS[@]} |
  while read file_path file_event file_name; do
    if [ "$file_name" == "rebuild" ]; then
      DC="$file_path/../../tools/server/dc"
      /bin/sh "$DC" down
      /bin/sh "$DC" up -d
    fi
  done
