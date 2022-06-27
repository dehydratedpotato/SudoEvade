#!/bin/sh

#  sudoev.sh
#  SudoEvade (Client)
#
#  Created by BitesPotatoBacks on 5/31/22.
#  Copyright (c) 2022 BitesPotatoBacks. All rights reserved.
#

OS="macOS"
VER="v0.1.3"

RED=$(tput setaf 1)
BOLD=$(tput bold)
NF=$(tput sgr0)

DIRSTUB="/Library/Caches/com.bitespotatobacks.SudoEvade"
CMDFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.cmd.txt"

CMD=$1
CMDARGS=${@:2}

STDERR_EOF=""
STDERR_NEWSIZE=""
STDERR_OLDSIZE=$(wc -c /var/log/com.bitespotatobacks.SudoEvade.stderr.log | awk '{print $1}')

stop() {
    rm "$DIRSTUB/_${CMDPATH##*/}"
    exit
}

while getopts "v" OPT; do
    case $OPT in
        v) echo "${BOLD}SudoEvade:${NF} $OS $VER"; exit ;;
    esac
done

trap 'stop' SIGINT

if [[ ! "$CMD" ]]; then
    echo "${BOLD}SudoEvade: ${RED}Error:${NF} Please insert a command to run"
    exit
fi

if ! command -v "$CMD" &> /dev/null; then
    echo "${BOLD}SudoEvade: ${RED}Error:${NF} Command not found"
    exit
fi

CMDPATH=$(type -P "$(command -v "$CMD")")
CMDBASE=$(basename "$CMDPATH")

if [[ "./$CMDBASE" == "$CMD" ]]; then
    echo "$PWD/$CMDBASE" > $CMDFILE
else
    echo $CMD > $CMDFILE
fi

while true; do
    STDERR_NEWSIZE=$(wc -c /var/log/com.bitespotatobacks.SudoEvade.stderr.log | awk '{print $1}')
    STDERR_EOF=$(tail -n1 /var/log/com.bitespotatobacks.SudoEvade.stderr.log)

    if [[ -f "$DIRSTUB/_${CMDPATH##*/}" ]]; then
        $DIRSTUB/_${CMDPATH##*/} $CMDARGS
        stop
    fi
    
    if [[ $STDERR_NEWSIZE != $STDERR_OLDSIZE ]] && [[ $STDERR_EOF != *"\$TERM"* ]]; then
        if [[ "$(type -t $CMD)" == "builtin" ]]; then
            echo "${BOLD}SudoEvade: ${RED}Error:${NF} Unable to execute command (Possibly due to command being builtin) "
        else
            echo "${BOLD}SudoEvade: ${RED}Error:${NF} Unable to execute command (Helper encountered an issue) "
        fi
        exit
    fi
done
