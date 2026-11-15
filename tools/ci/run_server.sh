#!/bin/bash
set -euo pipefail

touch errors.log
# Timeout wrapper instead of --once because BYOND shuts the world down after 5min of no players
if ! timeout 15m DreamDaemon goonstation.dmb -close -trusted -verbose -invisible
then
	echo "DreamDaemon timed out or exited with an error."
	exit 1
fi
if [ -s "errors.log" ]
then
	echo "Errors detected!"
	sed -i '/^[[:space:]]*$/d' ./errors.log
	cat errors.log
	exit 1
else
	echo "No errors detected."
	exit 0
fi
