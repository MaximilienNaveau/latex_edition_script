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

`find . -type f -executable -name make_document_launcher.sh -print` &
`find . -type f -executable -name make_figure_launcher.sh -print` &

while true; do
    sleep 1
done
