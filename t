#!/usr/bin/bash

function send_request {
		local path=$1
		local cfr_id=$2
		local cfr_direct_url='https://time.is/'

		response=$(curl -s -H 'Content-Type:application/json' \
			-w 'total_time:%{time_total}' \
			-d '{"cfr_id": "'$cfr_id'", "cfr_direct_url": "'$cfr_direct_url'"}' \
			-X POST http://localhost:5001/$path)
					local taken=$( echo "${response##*total_time:} * 1000" | tr ',' '.' | bc)
					echo -e "\tTaken: $taken ms"
					echo -e "\tResponse: ${response%total_time*}"
}


while (( "$#" ))
do
	case "$1" in
		--command=*)
			commands=()
			IFS=',' read -r -a commands <<< "${1#*=}"
			for c in ${commands[@]}
			do
				echo ""
				case $c in
					start)
						echo 'Sending start record command'
						send_request 'record/start' 'roomID1'
						;;
					stop)
						echo 'Sending stop record command'
						send_request 'record/stop' 'roomID1'
						;;
					pause)
						echo 'Sending pause record command'
						send_request 'record/pause' 'roomID1'
						;;
					resume)
						echo 'Sending resume record command'
						send_request 'record/resume' 'roomID1'
						;;
					sleep*)
						sleep_duration="${c#sleep}"
						[ -z "$sleep_duration" ] && sleep_duration=1
						echo "Sleep for $sleep_duration second(s)"
						sleep $sleep_duration
						;;
					*)
						echo 'Unknown command' $c
				esac
			done
			shift
			;;
		*)
			echo "Unknown command: $1"
			exit 1
	esac
done
