#!/bin/bash

#  sudoev.sh
#  sudoev (Client)
#
#  Created by BitesPotatoBacks on 5/31/22.
#  Copyright (c) 2022 BitesPotatoBacks. All rights reserved.
#

# CHANGELOG
#   Swapping to single universal shell script
#   Builitin comand prevention (excluding echo and pwd)
#   added arg to force a run and ignore checks
#   added arg to allow script to continue after helper failure
#   added arg to run in background/from helper
#   hopeful fix for install script randomly missing plist chmod
#   cleaned up install and helper outs

#
# Setting up on-exit cleanup
#
stop() {
    rm "$DIRSTUB/_${CMDPATH##*/}" 2> /dev/null
    exit
}

trap 'stop' 2

#
# Variables
#
OS=$(uname)
VER="v0.2.0"

YEL=$(tput setaf 3)
RED=$(tput setaf 1)
BOLD=$(tput bold)
NF=$(tput sgr0)

FORCE=false
ROOTLESS_ON_FAILURE=false
RUN_FROM_HELPER=false

CMD=$1
CMDARGS=${@:2}

STDERR_EOF=""
STDERR_NEWSIZE=""
STDERR_OLDSIZE=$(wc -c /var/log/com.bitespotatobacks.SudoEvade.stderr.log | awk '{print $1}')

if [[ $OS == "Linux" ]]; then
    DIRSTUB="/lib/com.bitespotatobacks.SudoEvade"
else
    DIRSTUB="/Library/Caches/com.bitespotatobacks.SudoEvade"
fi
    
CMDFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.cmd.txt"
BKGRND_CHECK_FILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.bkgrnd.txt"

echo n > $BKGRND_CHECK_FILE

#
# Checking Args
#
while getopts "hVfrb" OPT; do
    case $OPT in
        h) echo "usage: sudoev -h | -V";
           echo "usage: sudoev [-f|r|b]";
           echo "Options:";
           echo "   -h    print help and exit";
           echo "   -V    print version and exit";
           echo "   -f    ignore all checks and attempt force run";
           echo "   -r    run rootless on helper failure";
           echo "   -b    run in background via helper";
           exit ;;
        V) echo "${BOLD}sudoev:${NF} $OS $VER"; exit ;;
        f) FORCE=true; CMD=$2; CMDARGS=${@:3}; ;;
        r) ROOTLESS_ON_FAILURE=true; CMD=$2; CMDARGS=${@:3}; ;;
        b) RUN_FROM_HELPER=true; echo y > $BKGRND_CHECK_FILE; CMD=$2; CMDARGS=${@:3} ;;
    esac
done

if [[ ! "$CMD" ]]; then
    echo "${BOLD}sudoev: ${RED}error:${NF} Please insert a command to run"
    exit
fi

#
## temporary dirty fix for chowing group and kill issues
#if [[ $OS == "Darwin" ]]; then
#    if [[ $(type -P $CMD) == "/usr/sbin/chown" ]] ||
#        [[ $(type $CMD) == "kill is a shell builtin" ]]; then
#        echo y > $BKGRND_CHECK_FILE;
#    fi
#fi

# could most definitley slim this later
if [[ "$(type -t $CMD)" == "builtin" ]] &&
    [[ "$CMD" != *"echo"* ]] &&
    [[ "$CMD" != *"pwd"* ]] &&
#        [[ "$CMD" != *"kill"* ]] &&
    [[ "$FORCE" == false ]] &&
    [[ "$ROOTLESS_ON_FAILURE" == false ]];
then
    echo "${BOLD}sudoev: ${RED}error:${NF} Builtin prohibited (Re-run without sudoev)"
    exit
fi

if ! command -v "$CMD" &> /dev/null; then
    echo "${BOLD}sudoev: ${RED}error:${NF} Command not found"
    exit
fi

#
# Creating command string for helper
#
CMDPATH=$(type -P "$(command -v "$CMD")")
CMDBASE=$(basename "$CMDPATH")

if [[ "./$CMDBASE" == "$CMD" ]]; then
    echo "$PWD/$CMDBASE" > $CMDFILE
else
    echo $CMD > $CMDFILE
fi

#
# Waiting for root binary from helper and error checking
#
while true; do
    STDERR_NEWSIZE=$(wc -c /var/log/com.bitespotatobacks.SudoEvade.stderr.log | awk '{print $1}')
    STDERR_EOF=$(tail -n1 /var/log/com.bitespotatobacks.SudoEvade.stderr.log)
    
    if [[ -f "$DIRSTUB/_${CMDPATH##*/}" ]]; then
        if [[ "$RUN_FROM_HELPER" == false ]]; then
            $DIRSTUB/_${CMDPATH##*/} $CMDARGS
        else
            echo "${BOLD}sudoev:${NF} Executed via helper"
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

        exit
    fi
done
