#!/bin/bash

Black='\033[0;30m'
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Blue='\033[0;34m'
Magenta='\033[0;35m'
Cyan='\033[0;36m'
LightGrey='\033[0;37m'
Grey='\033[0;90m'
LightRed='\033[0;91m'
LightGreen='\033[0;92m'
LightYellow='\033[0;93m'
LightBlue='\033[0;94m'
LightMagenta='\033[0;95m'
LightCyan='\033[0;96m'
White='\033[0;97m'
NC='\033[0m' # No Color

DIRS="`/bin/ls --color=always -l $@ | grep ^d`"
FILES="`/bin/ls --color=always -l $@ | grep ^\-`"

if [ "$DIRS" ]
then
    echo -e "\n${Magenta}\t\t\t📁 Directories${NC}"
    echo -e "${Magenta}――――――――――――――――――――――――――――――――――――――――――――――――――――――――――${NC}"
    echo -e "$DIRS\


"
fi

if [ "$FILES" ]
then
    # This code splits $FILES by new line characters and checks if the each line contains NTUSER or ntuser to not print it out. (Windows stuff)
    set -f; IFS=$'\n'
    a=($FILES)
    set +f; unset IFS
    FILES_NEW=""
    for i in "${a[@]}"
    do
        if [[ ! "$i" == *NTUSER.* ]]; then
            if [[ ! "$i" == *ntuser.* ]]; then
                FILES_NEW="${FILES_NEW}$i\n"
            fi
        fi
    done
    if [ "$FILES_NEW" ]; then
        echo -e "\n${LightBlue}\t\t\t📄 Files${NC}"
        echo -e "${LightBlue}――――――――――――――――――――――――――――――――――――――――――――――――――――――――――${NC}"
        echo -e "$FILES_NEW\

"
    fi
fi