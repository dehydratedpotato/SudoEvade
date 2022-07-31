#!/bin/bash

#  install.sh
#  SudoEvade (Install Script)
#
#  Created by BitesPotatoBacks on 5/31/22.
#  Copyright (c) 2022 BitesPotatoBacks. All rights reserved.
#

OS=$(uname)
VER="v0.3.1"

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
PURPLE=$(tput setaf 5)

BOLD=$(tput bold)
NF=$(tput sgr0)

DIRSTUB="/Library/Caches/com.bitespotatobacks.SudoEvade"
[[ $OS == "Linux" ]] && DIRSTUB="/lib/com.bitespotatobacks.SudoEvade"
    
CMDFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.cmd.txt"
CMDARGFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.cmdarg.txt"
TTYFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.tty.txt"
HELPERFILE="$DIRSTUB/com.bitespotatobacks.SudoEvade.helper.txt"

DIR="$(dirname "${BASH_SOURCE[0]}")/src"

ROOT_GRP="root:wheel"

[[ "$OS" == "Linux" ]] && ROOT_GRP="root"

check_sudo() {
    if [ $UID -ne 0 ]; then
        echo "This script requires root privileges to install."
        echo "${BOLD}Re-run using Sudo to Install/Uninstall SudoEvade.${NF}"
        exit 1
    fi
}

install() {
    check_sudo

    echo " [1/6] Generating Directories"

    mkdir $DIRSTUB
    sudo chown $ROOT_GRP $DIRSTUB
    sudo chmod 4777 $DIRSTUB
    
    echo "" > $CMDFILE
    sudo chown $ROOT_GRP $CMDFILE
    sudo chmod 4777 $CMDFILE
    
    echo "" > $CMDARGFILE
    sudo chown $ROOT_GRP $CMDARGFILE
    sudo chmod 4777 $CMDARGFILE
    
    echo "" > $TTYFILE
    sudo chown $ROOT_GRP $TTYFILE
    sudo chmod 4777 $TTYFILE
    
    echo "" > $HELPERFILE
    sudo chown $ROOT_GRP $HELPERFILE
    sudo chmod 4777 $HELPERFILE

    echo " [2/6] Fixing Permissions"
    if [[ "$OS" == "Darwin" ]]; then
        if echo $PATH | grep -q "usr/local/bin"; then :; else
            printf "\n\nexport PATH=\"/usr/local/bin:\$PATH\"" >> ~/.zshrc
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
}

uninstall() {
    if [ ! -d $DIRSTUB ]; then
        echo "${RED}Uninstall Failed:${NF} Not previously installed ";
        exit
    fi
    
    check_sudo

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
}

usage() {
    echo "usage: install.sh -h | -V"
    echo "usage: install.sh [-i|-u|-r]"
    echo "Options: "
    echo "   -h   print help and exit"
    echo "   -V   print install version and exit"
    echo "   -i   install SudoEvade"
    echo "   -u   uninstall SudoEvade"
    echo "   -r   reinstall SudoEvade"
    exit
}

while getopts "uirhvV" OPT; do
    case $OPT in
        u) echo "${BOLD}Uninstalling SudoEvade ($OS $VER)${NF}";
           uninstall 2> /dev/null;
           exit ;;
        i) echo "${BOLD}Installing SudoEvade ($OS $VER) ${NF}";
           install 2> /dev/null;
           exit ;;
        r) echo "${BOLD}Reinstalling SudoEvade ($OS $VER)${NF}";
           uninstall 2> /dev/null; install 2> /dev/null;
           exit ;;
        v|V) echo "${BOLD}Installing:${NF} SudoEvade ($OS $VER)" ;;
        h|*) usage;;
    esac
done

[[ $# -eq 0 ]] && usage
