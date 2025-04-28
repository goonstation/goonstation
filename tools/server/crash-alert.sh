#!/bin/bash

source /ss13_server/.env.build

errorlog="/ss13_server/data/errors.log"
url="$DISCORD_BOT_URL/server_crash"
api_key="$DISCORD_BOT_CRASH_KEY"
# Try to get some context for this crash from the error logs
reason=$(\
	# Read errors backwards
	tac "$errorlog" \
	# Remove blank lines at the start
	| sed '/./,$!d' \
	# Read lines until a blank line is found
	| sed -n -r '0,/^\s*$/p' \
	# Remove blank lines at the end
	| sed '/^$/d' \
	# Reverse the output (back to normal)
	| tac \
	# Encode as json-able string
	| jq -Rsa .
)

echo "Sending crash alert to Discord"
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"api_key":"'"$api_key"'","server":"'"$SS13_ID"'","reason":'"$reason"'}' "$url"
