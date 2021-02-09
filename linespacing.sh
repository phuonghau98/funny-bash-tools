#!/usr/bin/bash

while (( $# > 0 ))
do
	case "$1" in
		--file=*)
			P=${1#*=}
			# Check if file exists
			if ! [ -f "$P" ]; then
				echo "Error: File didn't exist"
				exit 1
			fi
			# Read file line by line
			# sed '$!G' "$P"
			lines=()
			read -r -d '' -a lines < "$P"
			for i in $(seq 0 $(echo "${#lines[@]} - 2" | bc))
			do
				echo ${lines[$i]}
				echo -e ""
			done
			echo ${lines[-1]}
			shift
			;;
		*)
			echo "Unknown option"
			;;
	esac
done

