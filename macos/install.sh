#!/bin/bash

#  install.sh
#  SudoEvade (Install Script)
#
#  Created by BitesPotatoBacks on 5/31/22.
#  Copyright (c) 2022 BitesPotatoBacks. All rights reserved.
#

OS="macOS"
VER="v0.1.3"

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
        echo "This script requires root privileges to install."
        echo "${BOLD}Re-run using Sudo to Install/Uninstall SudoEvade.${NF}"
        exit 1
    fi
}

install()
{
    check_sudo

    echo "${GREEN}Installing SudoEvade ($OS $VER) ${NF}"
    echo "   Generating Directories..."

    mkdir $DIRSTUB &
    sudo chown root:wheel $DIRSTUB &
    sudo chmod 4777 $DIRSTUB
    
    echo "" > $CMDFILE
    sudo chown root:wheel $CMDFILE
    sudo chmod 4777 $CMDFILE


    echo "   Fixing Permissions..."
    
    if echo $PATH | grep -q "usr/local/bin"; then
        echo "   Correct dir found in path, skipping step!"
    else
        echo "   Adding dir to path..."
        export PATH=$PATH:/usr/local/bin
    fi
    
    chmod 755 $DIR/com.bitespotatobacks.SudoEvade.sh
    chmod 755 $DIR/sudoev.sh


    echo "   Relocating Client..."
    
    cp $DIR/sudoev.sh $DIR/sudoev
    sudo mv $DIR/sudoev /usr/local/bin/sudoev


    echo "   Creating Daemon..."

    sudo touch /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist &
    sudo chmod 4777 /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist &
    sudo cat $DIR/com.bitespotatobacks.SudoEvade.plist > /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist &


    echo "   Creating Helper Tool..."

    sudo touch /Library/PrivilegedHelperTools/com.bitespotatobacks.SudoEvade.sh &
    sudo chmod 4777 /Library/PrivilegedHelperTools/com.bitespotatobacks.SudoEvade.sh &
    sudo cat $DIR/com.bitespotatobacks.SudoEvade.sh > /Library/PrivilegedHelperTools/com.bitespotatobacks.SudoEvade.sh &
    sudo chmod 4755 /Library/PrivilegedHelperTools/com.bitespotatobacks.SudoEvade.sh &


    echo "   Loading Daemon..."

    sudo chmod 600 /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist
    sudo launchctl load -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist &
    sudo launchctl start -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist


    if sudo launchctl list | grep -q "com.bitespotatobacks.SudoEvade"; then
        echo "${GREEN}Install Complete!${NF}"
    else
        echo "${RED}Install Failed:${NF} Daemon did not start, please attempt reinstall"
    fi
    
    exit 0
}

uninstall()
{
    check_sudo
    
    echo "${PURPLE}Uninstalling SudoEvade ($OS $VER)${NF}"

    echo "   Removing Directories..."
    sudo rm -r $DIRSTUB

    echo "   Removing Client..."
    sudo rm /usr/local/bin/sudoev

    echo "   Removing Daemon..."
    
    sudo launchctl stop -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist &
    sudo launchctl unload -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist
    sudo rm /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist

    echo "   Removing Helper Tool..."
    sudo rm /Library/PrivilegedHelperTools/com.bitespotatobacks.SudoEvade.sh


    if sudo launchctl list | grep -q "com.bitespotatobacks.SudoEvade"; then
        echo "${RED}Uninstall Failed:${NF} Could not remove daemon"
    else
        echo "${PURPLE}Uninstall Complete!${NF}"
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
