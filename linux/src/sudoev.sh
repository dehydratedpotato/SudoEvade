#!/bin/bash

#  sudoev.sh
#  SudoEvade (Client)
#
#  Created by BitesPotatoBacks on 6/15/22.
#  Copyright (c) 2022 BitesPotatoBacks. All rights reserved.
#

RED=$(tput setaf 1)
BOLD=$(tput bold)
NF=$(tput sgr0)

DIRSTUB="/lib/com.bitespotatobacks.SudoEvade"
CMDFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.cmd.txt"

STDERR_EOF=""
STDERR_NEWSIZE=""
STDERR_OLDSIZE=$(wc -c /var/log/com.bitespotatobacks.SudoEvade.stderr.log | awk '{print $1}')


stop() {
    rm "$DIRSTUB/_${CMDPATH##*/}"
    exit
}

trap 'stop' 2

if [[ ! "$1" ]]; then
    echo "${BOLD}SudoEvade: ${RED}Error:${NF}${NORMAL} Please insert a command to run"
    exit
fi

if ! command -v "$1" &> /dev/null; then
    echo "${BOLD}SudoEvade: ${RED}Error:${NF}${NORMAL} Command not found"
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
    STDERR_NEWSIZE=$(wc -c /var/log/com.bitespotatobacks.SudoEvade.stderr.log | awk '{print $1}')

    if [[ -f "$DIRSTUB/_${CMDPATH##*/}" ]]; then
        $DIRSTUB/_${1##*/} ${@:2}
        stop
    fi
    
    if [[ $STDERR_NEWSIZE != $STDERR_OLDSIZE ]]; then
        if [[ "$(type -t $1)" == "builtin" ]]; then
            echo "${BOLD}SudoEvade: ${RED}Error:${NF}${NORMAL} Unable to execute command (Possibly due to command being builtin) "
        else
            echo "${BOLD}SudoEvade: ${RED}Error:${NF}${NORMAL} Unable to execute command (Helper encountered an issue) "
        fi
        exit
    fi
done
