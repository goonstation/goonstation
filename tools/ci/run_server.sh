#!/bin/bash
set -euo pipefail

DreamDaemon goonstation.dmb -once -quiet -close -trusted -verbose -invisible
ls
if [ ! -s ./errors.log ]
then
	echo "Errors detected!"
	sed -i '/^[[:space:]]*$/d' ./errors.log
	cat ./errors.log
	exit 1
else
	echo "No errors detected."
	exit 0
fi
