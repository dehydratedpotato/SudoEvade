#!/bin/bash

#  install.sh
#  SudoEvade (Install Script)
#
#  Created by BitesPotatoBacks on 5/31/22.
#  Copyright (c) 2022 BitesPotatoBacks. All rights reserved.
#

OS="macOS"
VER="v0.1.2"

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
PURPLE=$(tput setaf 5)

BOLD=$(tput bold)
NF=$(tput sgr0)

DIRSTUB="/Library/Caches/com.bitespotatobacks.SudoEvade"
CMDFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.cmd.txt"

DIR="$(dirname "${BASH_SOURCE[0]}")/src/"

check_sudo()
{
    if [ $UID -ne 0 ]; then
        echo "This script requires root privileges to manage Launch Daemons."
        echo "${BOLD}Re-run using Sudo to Install/Uninstall SudoEvade.${NF}"
        exit 1
    fi
}

install()
{
    check_sudo

    echo "${BOLD}$(date +"%T")${NF}: Installing SudoEvade ($OS $VER)"
    echo "${BOLD}$(date +"%T")${NF}: ${GREEN}Installing ==>${NF} Generating Directories..."

    mkdir $DIRSTUB &
    sudo chown root:wheel $DIRSTUB &
    sudo chmod 4777 $DIRSTUB
    
    echo "" > $CMDFILE
    sudo chown root:wheel $CMDFILE
    sudo chmod 4777 $CMDFILE


    echo "${BOLD}$(date +"%T")${NF}: ${GREEN}           ==>${NF} Fixing Permissions..."
    
    if echo $PATH | grep -q "usr/local/bin"; then
        echo "${BOLD}$(date +"%T")${NF}: ${GREEN}           ==>${NF} Correct dir found in path, skipping"
    else
        echo "${BOLD}$(date +"%T")${NF}: ${GREEN}           ==>${NF} Adding dir to path..."
        export PATH=$PATH:/usr/local/bin
    fi
    
    chmod 755 $DIR/com.bitespotatobacks.SudoEvade.sh
    chmod 755 $DIR/sudoev.sh


    echo "${BOLD}$(date +"%T")${NF}: ${GREEN}           ==>${NF} Relocating Client..."
    
    cp $DIR/sudoev.sh $DIR/sudoev
    sudo mv $DIR/sudoev /usr/local/bin/sudoev


    echo "${BOLD}$(date +"%T")${NF}: ${GREEN}           ==>${NF} Creating Daemon..."

    sudo touch /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist &
    sudo chmod 4777 /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist &
    sudo cat $DIR/com.bitespotatobacks.SudoEvade.plist > /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist &


    echo "${BOLD}$(date +"%T")${NF}: ${GREEN}           ==>${NF} Creating Helper Tool..."

    sudo touch /Library/PrivilegedHelperTools/com.bitespotatobacks.SudoEvade.sh &
    sudo chmod 4777 /Library/PrivilegedHelperTools/com.bitespotatobacks.SudoEvade.sh &
    sudo cat $DIR/com.bitespotatobacks.SudoEvade.sh > /Library/PrivilegedHelperTools/com.bitespotatobacks.SudoEvade.sh &
    sudo chmod 4755 /Library/PrivilegedHelperTools/com.bitespotatobacks.SudoEvade.sh &


    echo "${BOLD}$(date +"%T")${NF}: ${GREEN}           ==>${NF} Loading Daemon..."

    sudo chmod 600 /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist
    sudo launchctl load -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist &
    sudo launchctl start -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist


    if sudo launchctl list | grep -q "com.bitespotatobacks.SudoEvade"; then
        echo "${BOLD}$(date +"%T")${NF}: Install Complete!"
    else
        echo "${BOLD}$(date +"%T")${NF}: ${RED}Install Failed${NF} ==> Daemon did not start"
    fi
    
    exit 0
}

uninstall()
{
    check_sudo
    
    echo "${BOLD}$(date +"%T")${NF}: Uninstalling SudoEvade"

    echo "${BOLD}$(date +"%T")${NF}: ${PURPLE}Uninstalling ==>${NF} Removing Directories..."
    sudo rm -r $DIRSTUB

    echo "${BOLD}$(date +"%T")${NF}: ${PURPLE}             ==>${NF} Removing Client..."
    sudo rm /usr/local/bin/sudoev

    echo "${BOLD}$(date +"%T")${NF}: ${PURPLE}             ==>${NF} Removing Daemon..."
    
    sudo launchctl stop -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist &
    sudo launchctl unload -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist
    sudo rm /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist

    echo "${BOLD}$(date +"%T")${NF}: ${PURPLE}             ==>${NF} Removing Helper Tool..."
    sudo rm /Library/PrivilegedHelperTools/com.bitespotatobacks.SudoEvade.sh


    if sudo launchctl list | grep -q "com.bitespotatobacks.SudoEvade"; then
        echo "${BOLD}$(date +"%T")${NF}: ${RED}Uninstall Failed${NF} ==> Could not remove daemon"
    else
        echo "${BOLD}$(date +"%T")${NF}: Uninstall Complete!"
    fi
    
    exit 1
}

usage()
{
    echo "${BOLD}Usage: install.sh [-i|-u] -v${NF}"
    echo "   -h  show this message"
    echo "   -i  install SudoEvade"
    echo "   -u  uninstall SudoEvade"
    echo "   -v  print install version"
    exit
}

while getopts "hiuv" OPT; do
    case $OPT in
        h) usage;;
        i) install;;
        u) uninstall;;
        v) echo "${BOLD}Installing:${NF} SudoEvade ($OS $VER)" ;;
    esac
done

if [ $# -eq 0 ]; then
    usage
fi
