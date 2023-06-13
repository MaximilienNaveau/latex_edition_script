#! /bin/bash

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
    list_files=$(find figures/ -name '*.tex')
    if [[ -z "${list_files// }" ]]; then
	# list empty
#	echo "no files to notify, waiting 1s..."
	sleep 1
    else
	# list not empty
	echo "the files to watch are "$list_files
	inotifywait -e modify $list_files
	make figures
	sleep 0.1
    fi
done
