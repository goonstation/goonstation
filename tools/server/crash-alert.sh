#!/bin/bash

source /ss13_server/.env.build

errorlog="/ss13_server/data/errors.log"
url="$DISCORD_BOT_URL/server_crash"
api_key="$DISCORD_BOT_CRASH_KEY"
reason=$(tac "$errorlog" | sed -r '0,/BUG: Crashing/ d; /^\s*$/ { q }' | sed '/^$/d' | tac | jq -Rsa .)

echo "Sending crash alert to Discord"
curl -s -X POST -H "Content-Type: application/json" \
  -d '{"api_key":"'"$api_key"'","server":"'"$SS13_ID"'","reason":'"$reason"'}' "$url"
