#!/bin/sh

#  install.sh
#  SudoEvade (Install Script)
#
#  Created by BitesPotatoBacks on 5/31/22.
#  Copyright (c) 2022 BitesPotatoBacks. All rights reserved.
#

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

BOLD=$(tput bold)
DLOB=$(tput sgr0)

DIRSTUB="/Library/Caches/com.bitespotatobacks.SudoEvade"
CMDFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.cmd.txt"

DIR="$(dirname "${BASH_SOURCE[0]}")/src/"

function check_sudo()
{
    if [ $UID -ne 0 ]; then
        echo "This script requires root privileges to manage Launch Daemons."
        echo "${BOLD}Re-run using Sudo to Install/Uninstall SudoEvade.${DLOB}"
        exit 1
    fi
}

function install()
{
    check_sudo

    echo "${BOLD}$(date +"%T")${DLOB}: Installing SudoEvade"


    echo "${BOLD}$(date +"%T")${DLOB}: ${GREEN}Installing ==>${NC} Generating Directories..."

    mkdir $DIRSTUB &
    sudo chown root:wheel $DIRSTUB &
    sudo chmod 4777 $DIRSTUB
    
    echo "" > $CMDFILE
    sudo chown root:wheel $CMDFILE
    sudo chmod 4777 $CMDFILE


    echo "${BOLD}$(date +"%T")${DLOB}: ${GREEN}Installing ==>${NC} Fixing Permissions..."
    
    if echo $PATH | grep -q "usr/local/bin"; then
        echo "${BOLD}$(date +"%T")${DLOB}: ${GREEN}Installing ==>${NC} Correct dir found in path, skipping"
    else
        echo "${BOLD}$(date +"%T")${DLOB}: ${GREEN}Installing ==>${NC} Adding dir to path..."
        export PATH=$PATH:/usr/local/bin
    fi
    
    chmod 755 $DIR/com.bitespotatobacks.SudoEvade.sh
    chmod 755 $DIR/sudoev.sh


    echo "${BOLD}$(date +"%T")${DLOB}: ${GREEN}Installing ==>${NC} Relocating Client..."
    
    cp $DIR/sudoev.sh $DIR/sudoev
    sudo mv $DIR/sudoev /usr/local/bin/sudoev


    echo "${BOLD}$(date +"%T")${DLOB}: ${GREEN}Installing ==>${NC} Creating Daemon..."

    sudo touch /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist &
    sudo chmod 4777 /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist &
    sudo cat $DIR/com.bitespotatobacks.SudoEvade.plist > /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist &


    echo "${BOLD}$(date +"%T")${DLOB}: ${GREEN}Installing ==>${NC} Creating Helper Tool..."

    sudo touch /Library/PrivilegedHelperTools/com.bitespotatobacks.SudoEvade.sh &
    sudo chmod 4777 /Library/PrivilegedHelperTools/com.bitespotatobacks.SudoEvade.sh &
    sudo cat $DIR/com.bitespotatobacks.SudoEvade.sh > /Library/PrivilegedHelperTools/com.bitespotatobacks.SudoEvade.sh &
    sudo chmod 4755 /Library/PrivilegedHelperTools/com.bitespotatobacks.SudoEvade.sh &


    echo "${BOLD}$(date +"%T")${DLOB}: ${GREEN}Installing ==>${NC} Loading Daemon..."

    sudo chmod 600 /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist
    sudo launchctl load -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist &
    sudo launchctl start -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist


    if sudo launchctl list | grep -q "com.bitespotatobacks.SudoEvade"; then
        echo "${BOLD}$(date +"%T")${DLOB}: Install Complete!"
            sudo launchctl list | grep "com.bitespotatobacks.SudoEvade"
    else
        echo "${BOLD}$(date +"%T")${DLOB}: ${RED}Install Failed${NC} ==> Daemon did not start"
    fi
    
    exit 0
}

function uninstall()
{
    check_sudo
    
    echo "${BOLD}$(date +"%T")${DLOB}: Uninstalling SudoEvade"

    echo "${BOLD}$(date +"%T")${DLOB}: ${GREEN}Uninstalling ==>${NC} Removing Directories..."
    sudo rm -r $DIRSTUB

    echo "${BOLD}$(date +"%T")${DLOB}: ${GREEN}Uninstalling ==>${NC} Removing Client..."
    sudo rm /usr/local/bin/sudoev

    echo "${BOLD}$(date +"%T")${DLOB}: ${GREEN}Uninstalling ==>${NC} Removing Daemon..."
    
    sudo launchctl stop -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist &
    sudo launchctl unload -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist
    sudo rm /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist

    echo "${BOLD}$(date +"%T")${DLOB}: ${GREEN}Uninstalling ==>${NC} Removing Helper Tool..."
    sudo rm /Library/PrivilegedHelperTools/com.bitespotatobacks.SudoEvade.sh


    if sudo launchctl list | grep -q "com.bitespotatobacks.SudoEvade"; then
        echo "${BOLD}$(date +"%T")${DLOB}: ${RED}Uninstall Failed${NC} ==> Could not remove daemon"
    else
        echo "${BOLD}$(date +"%T")${DLOB}: Uninstall Complete!"
    fi
    
    exit 1
}

function usage()
{
    echo "${BOLD}Usage: install.sh [-i|-u]${DLOB}"
    echo "   -h  show this message"
    echo "   -i  install SudoEvade"
    echo "   -u  uninstall SudoEvade"
    exit
}

while getopts "hiu" OPT; do
    case $OPT in
        h) usage;;
        i) install;;
        u) uninstall;;
    esac
done

if [ $# -eq 0 ]; then
    usage
fi
