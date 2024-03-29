#!/bin/sh

START_TIME=$(date +%s)

config_location=$HOME"/.bash/scripts/cfg/mkrepo_config.json"
absolute_config_location=$(echo "${config_location/#\/c/\C\:}")
config_user=$(cat $config_location | python -c "import sys, json; print(json.load(sys.stdin)['user'])")
config_token=$(cat $config_location | python -c "import sys, json; print(json.load(sys.stdin)['token'])")
LOCATION=$(pwd)

REPO_NAME=""
TYPE=""
USER=""
TOKEN=""
PUBLICITY=""
ORGANIZATION=""

help() {
    echo ""
    echo -e "\e[1;33mMKREPO HELP:
  \e[0;36mOptions -\e[0m mkrepo (Repo Name) [Options]\e[0m
\t-u, -user\t  -\tSpecifies what username to use when creating the repository
\t-t, -token\t  -\tSpecifies the token to use when creating the repository
\t-p, -publicity\t  -\tRepository publicity, either private or public. Public by default
\t-o, -org\t  -\tSpecifies which organization to create the repository in. None by default
\t-r, -readme\t  -\tSpecifies what readme template to use. Normal by default

  \e[0;36mOptions -\e[0m mkrepo (Options)\e[0m
\t--help\t\t  -\tShows this message, general help for mkrepo
\t--get-user\t  -\tGets the user specified in the configuration file
\t--set-user\t  -\tSets the user in the configuration file
\t--get-token\t  -\tGets the token specified in the configuration file
\t--set-token\t  -\tSets the token in the configuration file"
    echo ""
    exit 0
}

is_valid_type() {
    if [ "$1" == "normal" ] || [ "$1" == "script" ] || [ "$1" == "website" ] ; then
        echo "true"
    else
        echo "false"
    fi
}

throw_error() {
    echo -e "  \e[0;36mError »\e[0m $1"
    echo -e "  \e[1;33mNeed help? use \e[0mmkrepo --help"
}

print_arguments() {
    echo -e "\n"
    echo -e "  \e[0;36mRepo name: $REPO_NAME\e[0m"
    echo -e "  \e[0;36mType: $TYPE\e[0m"
    echo -e "  \e[0;36mUser: $USER\e[0m"
    #echo -e "  \e[0;36mToken: $TOKEN\e[0m"
    echo -e "  \e[0;36mPublicity: $PUBLICITY\e[0m"
    echo -e "  \e[0;36mOrganization: $ORGANIZATION\e[0m"
    echo -e "\n"
    echo -e "  \e[0;36mConfig Location: $config_location\e[0m"
    echo -e "  \e[0;36mAbsolute Config Location: $absolute_config_location\e[0m"
    echo -e "  \e[0;36mConfig User: $config_user\e[0m"
    #echo -e " \e[0;36mConfig Token: $config_token\e[0m"
    echo -e "\n"
}



if [ ! -z "$1" ]; then

    if [ "$1" == "--help" ]; then
        help
        exit
    elif [ "$1" == "--get-user" ]; then
        echo "$config_user"
        exit
    elif [ "$1" == "--set-user" ]; then
        if [ -n "$2" ]; then
            if [ -n "$3" ]; then
                throw_error "No whitespaces allowed in --set-user"
            else
                python -c "import json; data={'user': '$2', 'token': '$config_token'}; file=open('$absolute_config_location', 'w'); json.dump(data, file, indent=4)"
                config_user="$2"
            fi
        else
            throw_error "mkrepo --set-user (USERNAME)"
        fi
        exit
    elif [ "$1" == "--get-token" ]; then
        echo "$config_token"
        exit
    elif [ "$1" == "--set-token" ]; then
        if [[ -n "$2" ]] ; then
            if [[ -n "$3" ]] ; then
                throw_error "No whitespaces allowed in --set-token"
            else
                python -c "import json; data={'user': '$config_user', 'token': '$2'}; file=open('$absolute_config_location', 'w'); json.dump(data, file, indent=4)"
                config_token="$2"
            fi
        else
            throw_error "mkrepo --set-token (TOKEN)"
        fi
        exit
    else
        REPO_NAME="$1"

    fi
else
    throw_error "mkrepo (NAME) [- OPTIONS]"
    exit
fi


if [ ! -z "$REPO_NAME" ]; then
    #OPTIONS
    while [ ! -z "$2" ]; do
        case "$2" in
            -r|-readme)
                shift
                TYPE="$2"
            ;;
            -u|-user)
                shift
                USER="$2"
            ;;
            -t|-token)
                shift
                TOKEN="$2"
            ;;
            -p|-publicity)
                shift
                PUBLICITY="$2"
            ;;
            -o|-org)
                shift
                ORGANIZATION="$2"
            ;;
            *)
        esac
        shift
    done
fi

# LOOPING THROUGH ALL THE ARGUMENTS AND CHECKING IF THEY ARE NULL
# IF THEY ARE, SETTING DEFAULT ARGUMENTS/USING CONFIG FILE

ARRAY=("$TYPE" "$USER" "$TOKEN" "$PUBLICITY" "$ORGANIZATION")
for (( c=0; c<=4; c++ ))
do  
   if [ -z "${ARRAY[$c]}" ]; then
        if [ "$c" == 0 ]; then
            TYPE="normal"
        elif [ "$c" == 1 ]; then
            USER="$config_user"
        elif [ "$c" == 2 ]; then
            TOKEN="$config_token"
        elif [ "$c" == 3 ]; then
            PUBLICITY="public"
        elif [ "$c" == 4 ]; then
            ORGANIZATION="$config_user"
        fi
   fi
done

#CHECK IF USER == ORGANIZATION, IF YES, NO ORGANIZATION AND GITHUB_USER=USER. ELSE GITHUB_USER=ORGANIZATION
GITHUB_USER=""
if [ "$USER" == "$ORGANIZATION" ]; then
    GITHUB_USER="$USER"
else
    GITHUB_USER="$ORGANIZATION"
fi

#Check the publicity and change it accordingly
if [ "$PUBLICITY" == "public" ]; then
    PUBLICITY="false"
elif [ "$PUBLICITY" == "private" ]; then
    PUBLICITY="true"
fi

#CREATE REPO
if [ -z "$REPO_NAME" ]; then
    read -p "Enter Github Repository Name: " REPO_NAME
fi
printf "\n"
mkdir ./$REPO_NAME
cd ./$REPO_NAME
echo -e "\e[1;32mCreating repository...\e[0m"
printf "\n"
echo -e "  \e[31mCreated local directory \e[0;36m$REPO_NAME\e[0m"

#CHECKING IF GITHUB_USER IS USER OR ORGANIZATION, AND HANDELING IT ACCORDINGLY
if [ "$GITHUB_USER" != "$USER" ]; then
    curl -s -o /dev/null -u $TOKEN:x-oauth-basic https://api.github.com/orgs/$GITHUB_USER/repos -d "{\"name\":\"$REPO_NAME\",\"private\":$PUBLICITY}"
    echo -e "  \e[31mCreated remote repository in organization \e[0;36m$GITHUB_USER@github/$REPO_NAME\e[0m"
else
    curl -s -o /dev/null -u $TOKEN:x-oauth-basic https://api.github.com/user/repos -d "{\"name\":\"$REPO_NAME\",\"private\":$PUBLICITY}"
    echo -e "  \e[31mCreated remote repository \e[0;36m$GITHUB_USER@github/$REPO_NAME\e[0m"
fi

#README.MD TEMPLATE
cp ~/.bash/github/templates/README-$TYPE.md ./README.md
sed -i "s/^# Project Name.*/# $REPO_NAME/" ./README.md


git init >/dev/null 2>/dev/null
echo -e "  \e[31mInitialized local repository \e[0;36m$REPO_NAME\e[0m"
git add README.md >/dev/null 2>/dev/null
git commit -m "first commit" >/dev/null 2>/dev/null
git branch -M main >/dev/null 2>/dev/null
git remote add origin https://github.com/$GITHUB_USER/$REPO_NAME.git >/dev/null 2>/dev/null
echo -e "  \e[31mPointed to remote \e[0;36m$LOCATION/$REPO_NAME (LOCAL) \e[1;33m» \e[0;36m$GITHUB_USER@github/$REPO_NAME (REMOTE)\e[0m"
git push -u origin main >/dev/null 2>/dev/null
printf "\n"
DURATION=$(( $(date +%s) - START_TIME ))
echo -e "\e[1;32mDone - Took $DURATION\e[1;32ms\e[0m"
printf "\n"