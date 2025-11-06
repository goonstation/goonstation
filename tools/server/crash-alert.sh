#!/bin/bash

source /ss13_server/.env.build

errorlog="/ss13_server/data/errors.log"
url="$DISCORD_BOT_URL/server_crash"
api_key="$DISCORD_BOT_CRASH_KEY"
# Try to get some context for this crash from the error logs
# In order:
# - Read errors backwards
# - Remove blank lines at the start
# - Read lines until a blank line is found
# - Remove blank lines at the end
# - Reverse the output (back to normal)
# - Encode as json-able string
reason=$(\
	tac "$errorlog" \
	| sed '/./,$!d' \
	| sed -n -r '0,/^\s*$/p' \
	| sed '/^$/d' \
	| tac \
	| jq -Rsa .
)

echo "Sending crash alert to Discord"
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"api_key":"'"$api_key"'","server":"'"$SS13_ID"'","reason":'"$reason"'}' "$url"
