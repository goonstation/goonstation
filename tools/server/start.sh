#!/bin/bash

# Script that handles starting the game server
# Runs in the context of a docker container
# Not intended for local development

cd /ss13_server

# Global config values
source buildByond.conf

# Load any server-specific config values (wil overwrite any existing global values)
if [[ -v SS13_ID ]]; then
	SS13_ENV="tools/server/.env.$SS13_ID"
	if [ -e "$SS13_ENV" ]; then
		eval $(cat "$SS13_ENV")
	fi
fi

# Apply updates
if [ -n "$(ls -A update)" ]; then
	cd update
	for filename in *; do
		[ -e "$filename" ] || continue
		if [ -d "$filename" ] && [ -d "../$filename" ]; then
			rm -r "../$filename"
		fi
		mv "$filename" ..
	done
	cd ..
fi

# Update external libraries
# TODO: versioning
cp "/rust-g/librust_g.so" .
cp "/byond-tracy/libprof.so" .

# Pick a Byond version
BYONDDIR="/byond/$BYOND_MAJOR_VERSION.$BYOND_MINOR_VERSION"
export PATH=$BYONDDIR/bin:$PATH
export LD_LIBRARY_PATH=$BYONDDIR/bin${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}

echo "Starting server..."
SS13_PORT="${SS13_PORT:-6969}"
DreamDaemon "goonstation.dmb" $SS13_PORT -trusted -verbose >>"data/errors.log" 2>&1
