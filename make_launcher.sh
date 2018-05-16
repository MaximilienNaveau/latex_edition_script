#! /bin/bash

# trap ctrl-c and call ctrl_c()
trap ctrl_c INT
function ctrl_c() {
    ./scripts/killall_launcher.sh
    exit 1
}

./scripts/make_document_launcher.sh &
./scripts/make_figure_launcher.sh &
