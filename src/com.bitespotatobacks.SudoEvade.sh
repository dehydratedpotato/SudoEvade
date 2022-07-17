#!/bin/bash

#  com.bitespotatobacks.SudoEvade.sh
#  SudoEvade (Helper Tool)
#
#  Created by BitesPotatoBacks on 5/31/22.
#  Copyright (c) 2022 BitesPotatoBacks. All rights reserved.
#

#
# Variables
#
OS=$(uname)
VER="0.3.0"

CMDPATH=""
NEWCMD=""
HELPERFLAG=""

if [[ $OS == "Linux" ]]; then
    DIRSTUB="/lib/com.bitespotatobacks.SudoEvade"
else
    DIRSTUB="/Library/Caches/com.bitespotatobacks.SudoEvade"
fi
    
CMDFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.cmd.txt"
CMDARGFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.cmdarg.txt"
TTYFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.tty.txt"
HELPERFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.helper.txt"

echo "$(date +"%T"): Initializing SudoEvade Helper ($OS $VER) ($$)"
echo "$(date +"%T"): Beginning Watch on \"$CMDFILE\""

#
# Waiting for a command string and generating a root bin when string found
#
while true; do
    NEWCMD=$(cat $CMDFILE)
    HELPERFLAG=$(cat $HELPERFILE)
    TTYDATA=$(cat $TTYFILE)
    
    if [[ $NEWCMD != "" ]]; then
        CMDPATH=$(type -P "$(command -v "$NEWCMD")")
        
        echo "$(date +"%T"): Input: $NEWCMD"
        echo "$(date +"%T"): [1/3] Attempting to clone \"$(basename $(command -v "$NEWCMD"))\"" &
        cp "$CMDPATH" "$DIRSTUB"
        
        if [[ $(echo "$?") != "0" ]]; then
            echo "$(date +"%T"): Operation failure"
        else
            echo "$(date +"%T"): [2/3] Attempting to modify binary permissions"
            
            # groups are different on unix so we do this...
            if [[ "$OS" == "Linux" ]]; then
                sudo chown root "$DIRSTUB/${CMDPATH##*/}"
            else
                sudo chown root:wheel "$DIRSTUB/${CMDPATH##*/}"
            fi
            
            sudo chmod 4777 "$DIRSTUB/${CMDPATH##*/}"
            
            if [[ $(echo "$?") != "0" ]]; then
                echo "$(date +"%T"): Operation failure"
            else
                if [[ "$HELPERFLAG" == "non" ]];
                then
                    echo "$(date +"%T"): [3/3] Operation successful, preparing to run command via client"
                else
                    echo "$(date +"%T"): [3/3] Operation successful, preparing to run command via helper"
                fi
            fi
        fi
        
        #
        # Some binaries misbehave when they are not renamed
        #
        mv "$DIRSTUB/${CMDPATH##*/}" "$DIRSTUB/_${CMDPATH##*/}"
        
        #
        # Running command here silently or with tty piping based on string given by client
        #
        if [[ "$HELPERFLAG" == *"background"* ]];
        then
            if [[ "$HELPERFLAG" == *"tty"* ]]; then
                sudo $NEWCMD $(cat $CMDARGFILE) > $TTYDATA 0> $TTYDATA 2> $TTYDATA
            else
                echo "$(date +"%T"): Command output:"
                sudo $NEWCMD $(cat $CMDARGFILE)
            fi
        fi
        
        echo "$(date +"%T"): Execution complete, resuming watch on \"$CMDFILE\""
        echo "" > $CMDFILE
    fi
    
    sleep 0.25
done
