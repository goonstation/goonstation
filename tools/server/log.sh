#!/bin/bash

while read line; do
  if [[ "$line" =~ ^BUG:.* ]]; then
    printf -v date '%(%H:%M:%S)T' -1
    echo "[$date] $line"
  else
    echo $line
  fi
done
