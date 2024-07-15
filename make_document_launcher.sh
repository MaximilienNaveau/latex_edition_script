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
    list_files=$(find src/ -name '*.tex')
    list_files+=" "$(find src/ -name '*.bib')
    list_files+=" "$(find src/ -name '*.cls')
    list_files+=" "$(find src/ -name '*.sty')
    list_files+=" "$(find src/ -name '*.png')
    list_files+=" "$(find src/ -name '*.jpg')
    list_files+=" "$(find src/ -name '*.jpeg')
    list_files+=" "$(find src/ -name '*.pdf')
    list_files+=" "$(find src/ -name '*.eps')
    list_files+=" "$(find src/ -name '*.svg')
    if [[ -z "${list_files// }" ]]; then
        # list empty
        # echo "no files to notify, waiting 1s..."
        sleep 1
    else
        # list not empty
        echo "the files to watch are "$list_files
        inotifywait -e modify $list_files
        if [ $# -eq 0 ]; then
            make fast
        else
            make "$@"
        fi
        sleep 0.1
    fi
done
