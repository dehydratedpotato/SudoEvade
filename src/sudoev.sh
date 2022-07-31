#!/bin/bash

#  sudoev.sh
#  sudoev (Client)
#
#  Created by BitesPotatoBacks on 5/31/22.
#  Copyright (c) 2022 BitesPotatoBacks. All rights reserved.
#

OS=$(uname)
VER="v0.3.1"

YEL=$(tput setaf 3)
RED=$(tput setaf 1)
BOLD=$(tput bold)
NF=$(tput sgr0)

FORCE=false
ROOTLESS_ON_FAILURE=false
RUN_FROM_HELPER=false
TTY_REDIRECT=false
TIMEOUT=8

STDERR_EOF=""
STDERR_NEWSIZE=""
STDERR_OLDSIZE=$(wc -c /var/log/com.bitespotatobacks.SudoEvade.stderr.log | awk '{print $1}')

if [[ $OS == "Linux" ]]; then
    DIRSTUB="/lib/com.bitespotatobacks.SudoEvade"
else
    DIRSTUB="/Library/Caches/com.bitespotatobacks.SudoEvade"
fi
    
CMDFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.cmd.txt"
CMDARGFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.cmdarg.txt"
TTYFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.tty.txt"
HELPERFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.helper.txt"

echo "non" > $HELPERFILE

stop() {
    rm "$DIRSTUB/_${CMDPATH##*/}" 2> /dev/null
    exit
}

while getopts "frbtT:hvV" OPT; do
    case $OPT in
        f) FORCE=true ;;
           
        r) ROOTLESS_ON_FAILURE=true ;;

        T) TIMEOUT=$OPTARG ;;
           
        b) RUN_FROM_HELPER=true;
           echo "background" > $HELPERFILE ;;
           
        t) RUN_FROM_HELPER=true;
           TTY_REDIRECT=true;
           tty > $TTYFILE;
           echo "background tty" > $HELPERFILE ;;
           
        v|V) echo "${BOLD}sudoev:${NF} $OS $VER"; exit ;;
        
        h|*) echo "usage: sudoev -h | -V";
             echo "usage: sudoev -fr [-b|-t] [-T time] command [arg ...]";
             echo "Options:";
             echo "   -h         print help and exit";
             echo "   -V         print version and exit";
             echo "   -T <time>  set the timeout for unresponsive helper";
             echo "   -f         ignore all checks and attempt force run";
             echo "   -r         run rootless on helper failure";
             echo "   -b         run in background via helper";
             echo "   -t         use tty redirect over binary cloning";
             exit ;;
    esac
done

shift $(($OPTIND - 1))
CMD=$1
CMDARGS=${@:2}

[[ "$RUN_FROM_HELPER" == true ]] && echo $CMDARGS > $CMDARGFILE;

if [[ ! "$CMD" ]]; then
    echo "${BOLD}sudoev: ${RED}error:${NF} Please insert a command to run";
    exit
fi

if ! command -v "$CMD" &> /dev/null; then
    echo "${BOLD}sudoev: ${RED}error:${NF} Command not found"
    exit
fi

#
# stopping builtin commands (except for excluded commands, i.e. echo)
#
if [[ "$(type -t $CMD)" == "builtin" ]] &&
    [[ "$CMD" != *"echo"* ]] &&
    [[ "$CMD" != *"pwd"* ]] &&
    [[ "$CMD" != *"printf"* ]] &&
    [[ "$FORCE" == false ]] &&
    [[ "$ROOTLESS_ON_FAILURE" == false ]];
then
    echo "${BOLD}sudoev: ${RED}error:${NF} Builtin prohibited (Re-run without sudoev)"
    exit
fi

#
# Creating command string for helper
#
CMDPATH=$(type -P "$(command -v "$CMD")")
CMDBASE=$(basename "$CMDPATH")

[[ "./$CMDBASE" == "$CMD" ]] && echo "$PWD/$CMDBASE" > $CMDFILE || echo $CMD > $CMDFILE

trap 'stop' 2

#
# Waiting for root binary from helper and error checking
#
TIME=$(($(date +%s) + $TIMEOUT))
while true; do
    STDERR_NEWSIZE=$(wc -c /var/log/com.bitespotatobacks.SudoEvade.stderr.log | awk '{print $1}')
    STDERR_EOF=$(tail -n1 /var/log/com.bitespotatobacks.SudoEvade.stderr.log)
    
    if [[ -f "$DIRSTUB/_${CMDPATH##*/}" ]]; then
        if [[ "$RUN_FROM_HELPER" == false ]]; then
            $DIRSTUB/_${CMDPATH##*/} $CMDARGS
        else
            [[ "$TTY_REDIRECT" == false ]] && echo "${BOLD}sudoev:${NF} Executed via helper"
        fi
        
        stop
    fi
    
    if [[ $STDERR_NEWSIZE != $STDERR_OLDSIZE ]] && [[ $STDERR_EOF != *"\$TERM"* ]] && [[ "$FORCE" == false ]]; then
        if [[ "$ROOTLESS_ON_FAILURE" == true ]]; then
            echo "${BOLD}sudoev: ${YEL}warning:${NF} Helper encountered an issue, executing rootless "
            $CMD $CMDARGS
        else
            echo "${BOLD}sudoev: ${RED}error:${NF} Unable to execute command (Helper encountered an issue) "
        fi

        stop
    fi

    [[ $(date +%s) == $TIME ]] && break
done

echo "${BOLD}sudoev: ${RED}error:${NF} Unable to execute command (Helper took too long) "
