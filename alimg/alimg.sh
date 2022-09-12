#!/bin/bash
storage_file="C:/Scripts/alimg-storage.sh"
list_items=()

throw_error() {
    echo -e "  \e[0;36mError »\e[0m $1"
    echo -e "  \e[1;33mNeed help? use \e[0malimg --help"
}

#add to list
add_item(){
    local name="$1"
    local value="$2"
    get_list
    local duplicates=0
    for i in "${list_items[@]}"; do
        if [[ $i == *"alias \"::$name\"="* ]]; then 
            while true; do
                echo -e "$name Already exists, do you want to overwrite it? [y/n]"
                read -rn 1 -p "" INPUT
                if [ "$INPUT" == "y" ] || [ "$INPUT" == "Y" ]; then
                    remove_item "$name"
                    add_item "$name" "$value"
                    exit 0
                elif [ "$INPUT" == "n" ] || [ "$INPUT" == "N" ]; then
                    echo ""
                    exit 0
                else
                    echo -e "\n"
                    throw_error "Either y or n, for YES or NO"
                    echo ""
                fi
            done
        fi
    done

    if [ "$duplicates" -lt 1 ]; then
        echo -e '\n' >> $storage_file
        printf "alias \"::%s\"=\"%s\"\n" "$name" "$value" >> $storage_file
        printf "Successfully added item: %s with value %s\n" "$name" "$value"
        sed -i '/^\s*$/d' $storage_file
        source "$HOME/.bashrc"
        exit 0
    fi
}

get_list(){
    list_items=()
    sed -i '/^\s*$/d' "$storage_file"
    while IFS= read -r line; do
        if [[ ! $line == "#!/bin/"* ]]; then
            list_items+=("$line")
        else
            STORAGE_HEADER=$line
        fi
    done < "$storage_file"
}

show_list(){
    #get_list() and echo each item from the array
    get_list $storage_file
    for i in "${list_items[@]}"; do
        echo "$i"
    done
}


#remove from list
remove_item(){
    local name="alias \"::$1\"="
    get_list
    local new_array=()
    echo "$STORAGE_HEADER" > $storage_file
    for i in "${list_items[@]}"; do
        if [[ ! $i == $name* ]] ; then
            new_array+=("$i")
            echo "$i" >> $storage_file
        fi
    done
    list_items=(new_array)
}

if [ -z "$1" ]; then
    throw_error "Wrong usage"
    exit 0
fi

#OPTIONS
while [ -n "$1" ]; do
    case "$1" in
        --help)
            shift
            echo "Help for alimg"
            exit 0
        ;;
        --add)
            shift
            add_item "$1" "$2"
            exit 0
        ;;
        --rm)
            shift
            remove_item "$1"
            exit 0
        ;;
        --list)
            shift
            show_list
            exit 0
        ;;
        *)
    esac
    shift
done

#list to env variables
#update env variables
