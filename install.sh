#!/bin/bash

#  install.sh
#  SudoEvade (Install Script)
#
#  Created by BitesPotatoBacks on 5/31/22.
#  Copyright (c) 2022 BitesPotatoBacks. All rights reserved.
#

OS=$(uname)
VER="v0.2.0"

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
PURPLE=$(tput setaf 5)

BOLD=$(tput bold)
NF=$(tput sgr0)

if [[ $OS == "Linux" ]]; then
    DIRSTUB="/lib/com.bitespotatobacks.SudoEvade"
else
    DIRSTUB="/Library/Caches/com.bitespotatobacks.SudoEvade"
fi
    
CMDFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.cmd.txt"
BKGRND_CHECK_FILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.bkgrnd.txt"

DIR="$(dirname "${BASH_SOURCE[0]}")/src"

if [[ "$OS" == "Linux" ]]; then
ROOT_GRP="root"
else
ROOT_GRP="root:wheel"
fi

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

    echo "${BOLD}Installing SudoEvade ($OS $VER) ${NF}"
    echo " [1/6] Generating Directories"

    mkdir $DIRSTUB &
    sudo chown $ROOT_GRP $DIRSTUB &
    sudo chmod 4777 $DIRSTUB
    
    echo "" > $CMDFILE
    sudo chown $ROOT_GRP $CMDFILE
    sudo chmod 4777 $CMDFILE
    
    echo "" > $BKGRND_CHECK_FILE
    sudo chown $ROOT_GRP $BKGRND_CHECK_FILE
    sudo chmod 4777 $BKGRND_CHECK_FILE

    echo " [2/6] Fixing Permissions"
    
    if [[ "$OS" == "Darwin" ]]; then
        if echo $PATH | grep -q "usr/local/bin"; then
            :
        else
            export PATH=$PATH:/usr/local/bin
        fi
    fi
    
    chmod 755 $DIR/com.bitespotatobacks.SudoEvade.sh
    chmod 755 $DIR/sudoev.sh


    echo " [3/6] Relocating Client"
    
    cp $DIR/sudoev.sh $DIR/sudoev
    
    if [[ "$OS" == "Linux" ]]; then
        sudo mv $DIR/sudoev /usr/bin/sudoev
    else
        sudo mv $DIR/sudoev /usr/local/bin/sudoev
    fi


    echo " [4/6] Creating Daemon"
    if [[ "$OS" == "Linux" ]]; then
            sudo touch /etc/systemd/system/com.bitespotatobacks.SudoEvade.service &
        sudo chmod 664 /etc/systemd/system/com.bitespotatobacks.SudoEvade.service &
        sudo cat $DIR/com.bitespotatobacks.SudoEvade.service > /etc/systemd/system/com.bitespotatobacks.SudoEvade.service &
    else
        sudo touch /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist &
        sudo chmod 4777 /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist &
        sudo cat $DIR/com.bitespotatobacks.SudoEvade.plist > /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist &
    fi


    echo " [5/6] Creating Helper Tool"
    if [[ "$OS" == "Linux" ]]; then
                sudo touch /usr/bin/com.bitespotatobacks.SudoEvade.sh &
        sudo chmod 4777 /usr/bin/com.bitespotatobacks.SudoEvade.sh &
        sudo cat $DIR/com.bitespotatobacks.SudoEvade.sh > /usr/bin/com.bitespotatobacks.SudoEvade.sh &
        sudo chmod 4755 /usr/bin/com.bitespotatobacks.SudoEvade.sh &
    else
        sudo touch /Library/PrivilegedHelperTools/com.bitespotatobacks.SudoEvade.sh &
        sudo chmod 4777 /Library/PrivilegedHelperTools/com.bitespotatobacks.SudoEvade.sh &
        sudo cat $DIR/com.bitespotatobacks.SudoEvade.sh > /Library/PrivilegedHelperTools/com.bitespotatobacks.SudoEvade.sh &
        sudo chmod 4755 /Library/PrivilegedHelperTools/com.bitespotatobacks.SudoEvade.sh &
    fi


    echo " [6/6] Loading Daemon"

    if [[ "$OS" == "Linux" ]]; then
        sudo systemctl daemon-reload &
        sudo systemctl start com.bitespotatobacks.SudoEvade
        sudo systemctl enable com.bitespotatobacks.SudoEvade
        
        if systemctl | grep -q "com.bitespotatobacks.SudoEvade"; then
            echo "${GREEN}Install Complete!${NF}"
        else
            echo "${RED}Install Failed:${NF} Daemon did not start, please attempt reinstall"
        fi
    else
    
    # hoping this fixes the issue with install script not giving plist right permissons
        while [[ $(ls -l /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist | awk '{print $1}') != "-rw-------" ]]; do
            sudo chmod 600 /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist
        done
        
        sudo launchctl load -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist &
        sudo launchctl start -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist
        
        
        if sudo launchctl list | grep -q "com.bitespotatobacks.SudoEvade"; then
            echo "${GREEN}Install Complete!${NF}"
        else
            echo "${RED}Install Failed:${NF} Daemon did not start, please attempt reinstall"
        fi
    fi
    
    exit 0
}

uninstall()
{
    check_sudo
    
    echo "${BOLD}Uninstalling SudoEvade ($OS $VER)${NF}"

    echo " [1/4] Removing Directories"
    sudo rm -r $DIRSTUB

    echo " [2/4] Removing Client"
    if [[ "$OS" == "Linux" ]]; then
        sudo rm /usr/bin/sudoev
    else
        sudo rm /usr/local/bin/sudoev
    fi

    echo " [3/4] Removing Daemon"
    
    if [[ "$OS" == "Linux" ]]; then
        sudo systemctl stop com.bitespotatobacks.SudoEvade &
        sudo rm /etc/systemd/system/com.bitespotatobacks.SudoEvade.service &
        sudo systemctl daemon-reload
    else
        sudo launchctl stop -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist &
        sudo launchctl unload -w /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist
        sudo rm /Library/LaunchDaemons/com.bitespotatobacks.SudoEvade.plist
    fi

    echo " [4/4] Removing Helper Tool"
    if [[ "$OS" == "Linux" ]]; then
        sudo rm /usr/bin/com.bitespotatobacks.SudoEvade.sh
        
        if systemctl | grep -q "com.bitespotatobacks.SudoEvade"; then
            echo "${RED}Uninstall Failed:${NF} Could not remove daemon"
        else
            echo "${PURPLE}Uninstall Complete!${NF}"
        fi
    else
        sudo rm /Library/PrivilegedHelperTools/com.bitespotatobacks.SudoEvade.sh
        
        if sudo launchctl list | grep -q "com.bitespotatobacks.SudoEvade"; then
            echo "${RED}Uninstall Failed:${NF} Could not remove daemon"
        else
            echo "${PURPLE}Uninstall Complete!${NF}"
        fi
    fi
    
    exit 0
}


while getopts "hiuV" OPT; do
    case $OPT in
        h)  echo "usage: install.sh [-i|-u] -V"
            echo "Options: "
            echo "   -h   print help and exit"
            echo "   -V   print install version and exit"
            echo "   -i   install SudoEvade"
            echo "   -u   uninstall SudoEvade"
            exit;;
        i) install;;
        u) uninstall;;
        V) echo "${BOLD}Installing:${NF} SudoEvade ($OS $VER)" ;;
    esac
done

if [ $# -eq 0 ]; then
    usage
fi