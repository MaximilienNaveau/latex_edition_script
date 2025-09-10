#!/bin/bash

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT
function ctrl_c() {
    `find . -type f -executable -name killall_launcher.sh -print`
    exit 1
}

if ! command -v inotifywait &> /dev/null
then
    echo "inotifywait could not be found."
    echo "Please run: sudo apt-get install inotify-tools"
    exit
fi


while true ;
do
    echo "##############################################################################################################"
    echo "########################################### Start Compilation ################################################"
    echo "##############################################################################################################"
    
    list_files=()

    # list of extensions to watch
    extensions=("tex" "bib" "cls" "sty" "png" "jpg" "jpeg" "pdf" "eps" "svg")
    
    for ext in "${extensions[@]}"; do
        while IFS= read -r -d '' file; do
            list_files+=("$file")
        done < <(find src/ -name "*.$ext" -print0)
    done

    if [[ ${#list_files[@]} -eq 0 ]]; then
        # list empty
        echo "no files to watch, waiting 1s..."
        sleep 1
    else
        # list not empty
        echo "the files to watch are: "
        printf "%s\n" "${list_files[@]}"

        inotifywait -e modify "${list_files[@]}"

        if [ $# -eq 0 ]; then
            make fast
        else
            make "$@"
        fi

        sleep 0.1
    fi
done
