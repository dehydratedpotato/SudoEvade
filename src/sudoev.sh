#!/bin/sh

#  sudoev.sh
#  SudoEvade (Client)
#
#  Created by BitesPotatoBacks on 5/31/22.
#  Copyright (c) 2022 BitesPotatoBacks. All rights reserved.
#

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
RED='\033[0;31m'
NC='\033[0m'

DIRSTUB="/Library/Caches/com.bitespotatobacks.SudoEvade"
CMDFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.cmd.txt"
CMDPATH=""

SIZEEND=""
NEWSIZE=""
OLDSIZE=$(wc -c /tmp/com.bitespotatobacks.SudoEvade.stderr.log | awk '{print $1}')


function stop() {
    rm "$DIRSTUB/${CMDPATH##*/}"
    exit
}


trap 'stop' SIGINT
if [[ ! "$1" ]]; then
    echo "${BOLD}SudoEvade: ${RED}Error:${NC}${NORMAL} Please insert a command to run"
    exit
fi

if ! command -v "$1" &> /dev/null; then
    echo "${BOLD}SudoEvade: ${RED}Error:${NC}${NORMAL} Command not found"
    exit
fi


CMDPATH=$(type -P "$(command -v "$1")")
CMDBASE=$(basename "$CMDPATH")

if [[ "./$CMDBASE" == "$1" ]]; then
    echo "$PWD/$CMDBASE" > $CMDFILE
else
    echo $1 > $CMDFILE
fi


while true; do
    NEWSIZE=$(wc -c /tmp/com.bitespotatobacks.SudoEvade.stderr.log | awk '{print $1}')
    SIZEEND=$(tail -n1 /tmp/com.bitespotatobacks.SudoEvade.stderr.log)

    if [[ -f "$DIRSTUB/${CMDPATH##*/}" ]]; then
        $DIRSTUB/${1##*/} ${@:2} & wait
        stop
    fi
    
    if [[ $NEWSIZE != $OLDSIZE ]] && [[ $SIZEEND != *"\$TERM"* ]]; then
        echo "${BOLD}SudoEvade: ${RED}Error:${NC}${NORMAL} Unable to execute command (Helper encountered an issue) "
        exit
    fi
done
