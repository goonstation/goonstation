#!/bin/bash
set -euo pipefail

DreamDaemon goonstation.dmb -once -quiet -close -trusted -verbose
if [ -s ./no_runtimes.txt ]
then
	cat ./no_runtimes.txt
	exit 1
else
	echo "No runtimes!"
	exit 0
fi
