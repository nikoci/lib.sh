#!/bin/bash
DIR_NAME="$1"
USER=""
GROUP=""
USER_PERMS=""
GROUP_PERMS=""
OTHER_PERMS=""

if [ ! -z "$DIR_NAME" ] && [ "$DIR_NAME" == "--help" ]; then
        echo -e "\e[1;33mDIRP HELP:\n\t\e[0;36mUsage:\e[0m dirp (dir name) [- OPTIONS]\n\t\e[0;36mOptions:\e[0m\n\t\t-u, -user\t\t-\tSpecifies the owning user of the directory\n\t\t-g, -group\t\t-\tSpecifies the owning group of the directory\n\t\t-U, -user-permissions\t-\tSetting permissions to owning user for the directory. Same as chmod (Example: u+rx,u-w)\n\t\t-G, -group-permissions\t-\tSetting permissions to owning group for the directory. Same as chmod (Example: g+x,g-wr)\n\t\t-O, -others-permissions\t-\tSetting permissions to others for the directory. Same as chmod (Example: o-rwx)"
        exit 0
fi

if [ ! -z "$DIR_NAME" ]; then
    #OPTIONS
    while [ ! -z "$2" ]; do
        case "$2" in
            -u|-user)
                shift
                USER="$2"
            ;;
            -g|-group)
                shift
                GROUP="$2"
            ;;
            -U|-user-permissions)
                shift
                USER_PERMS="$2"
            ;;
            -G|-group-permissions)
                shift
                GROUP_PERMS="$2"
            ;;
            -O|-others-permissions)
                shift
                OTHER_PERMS="$2"
            ;;
            *)
        esac
        shift
    done
fi


ARRAY=($USER $GROUP $USER_PERMS $GROUP_PERMS $OTHER_PERMS)
for (( c=0; c<=4; c++ ))
do
   if [ -z "${ARRAY[$c]}" ]; then
        if [ "$c" == 0 ]; then
            USER=$(whoami)
        elif [ "$c" == 1 ]; then
            GROUP=$(id -gn $(whoami))
        elif [ "$c" == 2 ]; then
            USER_PERMS="u+rwx"
        elif [ "$c" == 3 ]; then
            GROUP_PERMS="g+rx,g-w"
        elif [ "$c" == 4 ]; then
            OTHER_PERMS="g-rwx"
        fi
   fi
done

if [ ! -z "$DIR_NAME" ]; then
        MKDIR="$(mkdir $DIR_NAME 2>&1)"
        if [ "$?" != "0" ]; then
                echo -e "\e[0;31m[Error] $MKDIR\e[0m" 1>&2
                exit 1
        fi
        CHOWN="$(sudo chown -R $USER:$GROUP $DIR_NAME/ 2>&1)"
        if [ "$?" != "0" ]; then
                echo -e "\e[0;31m[Error] $CHOWN\e[0m" 1>&2
                $(sudo rm -rf $DIR_NAME >/dev/null 2>/dev/null)
                exit 1
        fi
        CHMOD="$(sudo chmod -R $USER_PERMS,$GROUP_PERMS,$OTHER_PERMS $DIR_NAME/ 2>&1)"
        if [ "$?" != "0" ]; then
                echo -e "\e[0;31m[Error] $MKDIR\e[0m" 1>&2
                $(sudo rm -rf $DIR_NAME >/dev/null 2>/dev/null)
                exit 1
        fi
else
        echo -e "\e[0;31m[Error] Invalid Syntax! use: dirp (dir name) [- OPTIONS]"
fi
