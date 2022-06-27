#!/bin/sh

#  com.bitespotatobacks.SudoEvade.sh
#  SudoEvade (Helper Tool)
#
#  Created by BitesPotatoBacks on 5/31/22.
#  Copyright (c) 2022 BitesPotatoBacks. All rights reserved.
#

DIRSTUB="/Library/Caches/com.bitespotatobacks.SudoEvade"
CMDFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.cmd.txt"
CMDPATH=""

NEWCMD=""

TIME=$(date +"%T")

echo "$TIME: Initializing SudoEvade Helper Tool ($$)"
echo "$TIME: Beginning Watch: $CMDFILE"

while true; do
    NEWCMD=$(cat $CMDFILE)
    
    if [[ $NEWCMD != "" ]]; then
        TIME=$(date +"%T")
        
        CMDPATH=$(type -P "$(command -v "$NEWCMD")")
        
        echo "$TIME: Input: $NEWCMD"
        
        echo "$TIME:   Attempting to clone \"$(basename $(command -v "$NEWCMD"))\"..." &
        cp "$CMDPATH" "$DIRSTUB"
        
        if [[ $(echo "$?") != "0" ]]; then
            echo "$TIME:   Operation failure"
        else
            echo "$TIME:   Attempting to modify binary permissions..."
            sudo chown root:wheel "$DIRSTUB/${CMDPATH##*/}"
            sudo chmod 4777 "$DIRSTUB/${CMDPATH##*/}"
            
            if [[ $(echo "$?") != "0" ]]; then
                echo "$TIME:   Operation failure"
            else
                echo "$TIME:   Operation successful, runing command via client"
            fi
        fi
        
        mv "$DIRSTUB/${CMDPATH##*/}" "$DIRSTUB/_${CMDPATH##*/}"
        echo "$TIME: Resuming Watch: $CMDFILE"
        echo "" > $CMDFILE
    fi
    
    sleep 0.25
done
