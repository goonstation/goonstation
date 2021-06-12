#!/bin/bash
set -euo pipefail

DreamDaemon goonstation.dmb -once -quiet -close -trusted -verbose -invisible
if [ ! -f ./no_runtimes.txt ]
then
	echo "Runtimes detected!"
	cat ./errors.log
	exit 1
else
	echo "No runtimes detected."
	exit 0
fi
