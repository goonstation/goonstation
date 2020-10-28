#!/bin/bash
set -euo pipefail

DreamDaemon goonstation.dmb -once -quiet -close -trusted -verbose
cat ./no_runtimes.txt
