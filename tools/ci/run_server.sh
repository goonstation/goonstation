#!/bin/bash
set -euo pipefail

DreamDaemon goonstation.dmb -once -quiet -close -trusted -verbose -invisible
touch ./no_runtimes.txt
sed -i '/^[[:space:]]*$/d' ./no_runtimes.txt
if [ -s ./no_runtimes.txt ]
then
	cat ./no_runtimes.txt
	exit 1
else
	echo "No runtimes!"
	exit 0
fi
