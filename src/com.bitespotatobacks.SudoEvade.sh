#!/bin/sh

#  com.bitespotatobacks.SudoEvade.sh
#  SudoEvade (Helper Tool)
#
#  Created by BitesPotatoBacks on 5/31/22.
#  Copyright (c) 2022 BitesPotatoBacks. All rights reserved.
#

# Issues:
# - Shell scripts are broken
# - some builtin bash scripts complain (such as read)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

BOLD=$(tput bold)
DLOB=$(tput sgr0)

DIRSTUB="/Library/Caches/com.bitespotatobacks.SudoEvade"
CMDFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.cmd.txt"

NEWCMD=""
OLDCMD=$(cat $CMDFILE)
TIME=$(date +"%T")

CMDPATH=""

function stop() {
    TIME=$(date +"%T")
    echo "${BOLD}$TIME${DLOB}: ${RED}Qutting${NC}"
    exit
}

trap 'stop' SIGINT
echo "${BOLD}$TIME${DLOB}: Starting SudoEvade ($$)"

while true; do
    TIME=$(date +"%T")
    NEWCMD=$(cat $CMDFILE)
    
    echo ~
    echo "${BOLD}$TIME${DLOB}: ${BLUE}Watching ==>${NC} $CMDFILE"
    
    
    if [[ $NEWCMD != "" ]]; then
        CMDPATH=$(type -P $(echo "$NEWCMD" | awk '{print $1}'))
        
        echo "${BOLD}$TIME${DLOB}: ${GREEN}Recieved ==>${NC} $NEWCMD (via client)"
        
        cp $CMDPATH $DIRSTUB &
        echo "${BOLD}$TIME${DLOB}: ${YELLOW}Performing ==>${NC} Cloning binary to $DIRSTUB"

        sudo chown root:wheel "$DIRSTUB/${CMDPATH##*/}"
        echo "${BOLD}$TIME${DLOB}: ${YELLOW}Performing ==>${NC} Modifiying cloned binary privileges (chown root:wheel)"

        sudo chmod 4777 "$DIRSTUB/${CMDPATH##*/}"
        echo "${BOLD}$TIME${DLOB}: ${YELLOW}Performing ==>${NC} Modifiying cloned binary privileges (chmod 4777)"
         
        mv "$DIRSTUB/${CMDPATH##*/}" "$DIRSTUB/sudoev_${CMDPATH##*/}"
        echo "${BOLD}$TIME${DLOB}: ${PURPLE}Executing ==>${NC} [sudo] $NEWCMD (via client)"

        echo "" > $CMDFILE
    fi
    sleep 0.45
done
