#!/bin/bash

#  install.sh
#  SudoEvade (Install Script)
#
#  Created by BitesPotatoBacks on 6/15/22.
#  Copyright (c) 2022 BitesPotatoBacks. All rights reserved.
#

OS="Linux"
VER="v0.1.3"

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
PURPLE=$(tput setaf 5)

BOLD=$(tput bold)
NF=$(tput sgr0)

DIRSTUB="/lib/com.bitespotatobacks.SudoEvade"
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

    echo "${GREEN}Installing SudoEvade ($OS $VER)${NF}"
    echo "   Generating Directories..."

    mkdir $DIRSTUB &
    sudo chown root $DIRSTUB &
    sudo chmod 4777 $DIRSTUB
    
    echo "" > $CMDFILE
    sudo chown root $CMDFILE
    sudo chmod 4777 $CMDFILE


    echo "   Fixing Permissions..."
    
    chmod 755 $DIR/com.bitespotatobacks.SudoEvade.sh
    chmod 755 $DIR/sudoev.sh


    echo "   Relocating Client..."
    
    cp $DIR/sudoev.sh $DIR/sudoev
    sudo mv $DIR/sudoev /usr/bin/sudoev


    echo "   Creating Daemon..."

    sudo touch /etc/systemd/system/com.bitespotatobacks.SudoEvade.service &
    sudo chmod 664 /etc/systemd/system/com.bitespotatobacks.SudoEvade.service &
    sudo cat $DIR/com.bitespotatobacks.SudoEvade.service > /etc/systemd/system/com.bitespotatobacks.SudoEvade.service &


    echo "   Creating Helper Tool..."

    sudo touch /usr/bin/com.bitespotatobacks.SudoEvade.sh &
    sudo chmod 4777 /usr/bin/com.bitespotatobacks.SudoEvade.sh &
    sudo cat $DIR/com.bitespotatobacks.SudoEvade.sh > /usr/bin/com.bitespotatobacks.SudoEvade.sh &
    sudo chmod 4755 /usr/bin/com.bitespotatobacks.SudoEvade.sh &


    echo "   Loading Daemon..."

    sudo systemctl daemon-reload &
    sudo systemctl start com.bitespotatobacks.SudoEvade
    sudo systemctl enable com.bitespotatobacks.SudoEvade


    if systemctl | grep -q "com.bitespotatobacks.SudoEvade"; then
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
    sudo rm /usr/bin/sudoev

    echo "   Removing Daemon..."
    
    sudo systemctl stop com.bitespotatobacks.SudoEvade &
    sudo rm /etc/systemd/system/com.bitespotatobacks.SudoEvade.service &
    sudo systemctl daemon-reload

    echo "   Removing Helper Tool..."
    sudo rm /usr/bin/com.bitespotatobacks.SudoEvade.sh


    if systemctl | grep -q "com.bitespotatobacks.SudoEvade"; then
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
