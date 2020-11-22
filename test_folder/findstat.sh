#!/usr/bin/bash

TARGETDIR=$(pwd)

while [[ "$#" != 0 ]]
do
	case "$1" in
		--folder=*)
			path="${1#*=}"
			TARGETDIR="$path"
			shift
			;;
		*)
			echo "Unknown command"
			exit 1
			;;
	esac
done

find "$TARGETDIR" -maxdepth 1 -type f -printf '%f\000' | {
	while read -d $'\000' line
	do
		echo $line
	done
}
