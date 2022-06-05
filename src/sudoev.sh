#!/bin/sh

#  sudoev.sh
#  SudoEvade (Client)
#
#  Created by BitesPotatoBacks on 5/31/22.
#  Copyright (c) 2022 BitesPotatoBacks. All rights reserved.
#  

RED='\033[0;31m'
NC='\033[0m'

BOLD=$(tput bold)
DLOB=$(tput sgr0)

DIRSTUB="/Library/Caches/com.bitespotatobacks.SudoEvade"
CMDFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.cmd.txt"

CMDPATH=""

function stop() {
    rm "$DIRSTUB/sudoev_${CMDPATH##*/}"
    exit
}

trap 'stop' SIGINT

if [[ ! "$@" ]]; then
    echo "${BOLD}SudoEvade: ${RED}Error:${NC}${DLOB} Please insert a command to run"
    exit
fi

if ! command -v "$@" &> /dev/null; then
    echo "${BOLD}SudoEvade: ${RED}Error:${NC}${DLOB} Command not found"
    exit
fi

echo $@ > $CMDFILE
CMDPATH=$(type -P $(echo "$@" | awk '{print $1}'))

SECS=0

until [ $SECS -ge 100 ]; do
    if [[ -f "$DIRSTUB/sudoev_${CMDPATH##*/}" ]]; then
        $DIRSTUB/sudoev_${@##*/} & wait
        stop
    fi
    
    sleep 0.1
    ((SECS=SECS+1))
done

echo "${BOLD}SudoEvade: ${RED}Error:${NC}${DLOB} Helper took to long to respond"
exit
