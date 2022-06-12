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
OLDCMD=$(cat $CMDFILE)

TIME=$(date +"%T")


function stop() {
    TIME=$(date +"%T")
    echo "$TIME: Qutting..."
    exit
}


trap 'stop' SIGINT
echo "$TIME: Initializing SudoEvade Helper Tool ($$)"
echo "$TIME: Beginning Watch ==> $CMDFILE"


while true; do
    TIME=$(date +"%T")
    NEWCMD=$(cat $CMDFILE)
    
    if [[ $NEWCMD != "" ]]; then
        CMDPATH=$(type -P "$(command -v "$NEWCMD")")
        
        echo "$TIME: Input ==> $NEWCMD"
        cp "$CMDPATH" "$DIRSTUB"

        echo "$TIME: Performing Task ==> Cloning binary to $DIRSTUB"

        sudo chown root:wheel "$DIRSTUB/${CMDPATH##*/}" &
        sudo chmod 4777 "$DIRSTUB/${CMDPATH##*/}"
        
        echo "$TIME: Performing Task ==> Modifiying cloned binary privileges"
        echo "$TIME: Output ==> [sudo] $NEWCMD"

        echo "" > $CMDFILE
        echo "$TIME: Resuming Watch ==> $CMDFILE"
    fi
    sleep 0.3
done
