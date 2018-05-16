#!/bin/bash

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT
function ctrl_c() {
    ./scripts/killall_launcher.sh
    exit 1
}

while true ;
do
    list_files=$(find src/ -name '*.tex')
    list_files+=" "$(find src/ -name '*.bib')
    if [[ -z "${list_files// }" ]]; then
	# list empty
#	echo "no files to notify, waiting 1s..."
	sleep 1
    else
	# list not empty
	echo "the files to watch are "$list_files
	inotifywait -e modify $list_files
	make fast
	sleep 0.1
    fi
done
