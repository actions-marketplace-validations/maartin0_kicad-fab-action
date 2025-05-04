#!/bin/sh

#
# Usage: ./gen-fab.sh <pcb> <new zip location>
# 
# Generates gerber and drill files for every layer 
#

set -e

start_dir="$(pwd)"
tmp_dir="$(date +"tmp-%Y.%m.%d-%H.%M.%S")"

cleanup() {
    cd "$start_dir"
    rm -rf "$tmp_dir"
}

die() {
    echo "$*"
    cleanup
    exit 1
}

if [ $# -ne 2 ]; then
    die "Usage: $0 <pcb> <new zip location>"
fi

pcb="$1"
ext="$(basename "$pcb" | sed 's/^.*\.\(.*\)$/\1/')"
[ "$ext" = "kicad_pcb" ] || die "File extension must be 'kicad_pcb'"
[ -f "$pcb" ] || die "PCB '$pcb' doesn't exist"

new_location="$2"
[ -z "$new_location" ] && die "Invalid (empty) location for new zip: '$new_location'"
echo "$new_location" | grep ".zip$" >/dev/null || die "The output zip name should end in .zip, not '$new_location'"

mkdir -p "$tmp_dir"
cd "$tmp_dir"

# generate gerbers and drill files
kicad-cli pcb export gerbers "../$pcb" || die
kicad-cli pcb export drill "../$pcb" || die
zip -r fab.zip ./* || die
mv fab.zip "../$new_location"

cleanup
