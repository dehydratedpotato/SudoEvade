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
VER="0.2.0"

CMDPATH=""
NEWCMD=""
BKGRND=""

if [[ $OS == "Linux" ]]; then
    DIRSTUB="/lib/com.bitespotatobacks.SudoEvade"
else
    DIRSTUB="/Library/Caches/com.bitespotatobacks.SudoEvade"
fi
    
CMDFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.cmd.txt"
BKGRND_CHECK_FILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.bkgrnd.txt"

echo "$(date +"%T"): Initializing SudoEvade Helper ($OS $VER) ($$)"
echo "$(date +"%T"): Beginning Watch: $CMDFILE"

#
# Waiting for a command string and generating a root bin when string found
#
while true; do
    NEWCMD=$(cat $CMDFILE)
    BKGRND=$(cat $BKGRND_CHECK_FILE)
    
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
                    if [[ "$BKGRND" == "n" ]]; then
                        echo "$(date +"%T"): [3/3] Operation successful, adding prefix to file name and running command via client"
                    else
                        echo "$(date +"%T"): [3/3] Operation successful, adding prefix to file name and running command via self"
                    fi
                fi
            fi
            
            #
            # Some binaries misbehave when they are not renamed
            #
            mv "$DIRSTUB/${CMDPATH##*/}" "$DIRSTUB/_${CMDPATH##*/}"
            
            if [[ "$BKGRND" == "y" ]]; then
                echo "$(date +"%T"): Command output:"
                sudo "$CMDFILE"
            fi
            
            echo "$(date +"%T"): Resuming Watch: $CMDFILE"
            echo "" > $CMDFILE
            

    fi
    
    sleep 0.25
done
