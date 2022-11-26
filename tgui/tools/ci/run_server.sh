#!/bin/bash
set -euo pipefail

touch errors.log
DreamDaemon goonstation.dmb -once -quiet -close -trusted -verbose -invisible
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
