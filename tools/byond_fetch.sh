#!/bin/bash
[[ "$#" != 3 ]] && printf "Usage: $0 <address> <port> <message>" && exit 1
sendByondMessage () {
  set -e
  [[ "?" != "${3:0:1}" ]] && msg="?$3" || msg="$3"
  size=$(printf "%.4X" $((${#msg}+6))) # 5 nul for padding, 1 nul for terminator
  exec 3<>"/dev/tcp/$1/$2" # Open socket
  printf "\0\x83\x${size:0:2}\x${size:2:2}\0\0\0\0\0$msg\0" >&3
  rsize=$(($(dd bs=1 skip=2 count=2 <&3 2>/dev/null | od -An -t uS --endian=big | tr -d ' ')-1))
  type=$(dd bs=1 count=1 <&3 2>/dev/null | od -An -t x1 | tr -d ' ')
  if [ "2a" = "$type" -a "4" = "$rsize" ]; then # Float type
    echo -n $(dd bs=1 count=4 <&3 2>/dev/null | od -An -f | tr -d ' ')
  elif [ "06" = "$type" ]; then # Text type
    echo -n $(dd bs=1 count=$(($rsize-1)) <&3 2>/dev/null | strings)
  fi
  exec 3<&- # Close socket
}
export -f sendByondMessage
timeout 5 bash -c "sendByondMessage '$1' '$2' '$3'"
