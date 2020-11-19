#!/bin/bash
case="$1"

if [[ "$case" == 1 ]]; then
	echo "Case #1, unique cfrID requests sent"
	for i in {1..10}
	do
		echo -n "Code:"
		curl -s -H 'Content-Type:application/json' \
			-d '{"cfr_id": "53ac09aa-9363-46ef-a02d-ca6af2c185bb", "cfr_direct_url": "https://www.youtube.com/watch?v=GCRX7Go6eHM&list=RDMMGCRX7Go6eHM&start_radio=1" }' \
			-X POST http://localhost:5001/record/start | jq '.success,.error'
	done
fi


if [[ "$case" == 2 ]]; then
	echo "Case #2: 3 different requests sent, only 2 workers available"
	for i in {1..3}
	do
		echo -n "Code:"
		curl -s -H 'Content-Type:application/json' \
			-d '{"cfr_id": "53ac09aa-9363-46ef-a02d-ca6af2c185b'$i'", "cfr_direct_url": "https://www.youtube.com/watch?v=GCRX7Go6eHM&list=RDMMGCRX7Go6eHM&start_radio=1"}' \
			-X POST http://localhost:5001/record/start | jq '.success,.error'
	done
fi

if [[ "$case" == 3 ]]; then
	echo "Case #3: /record/stop with single request"
	echo -e "\tSend stop request but no worker is handling requested roomID"
	echo -ne "\tCode:"
	curl -s -H 'Content-Type:application/json' \
		-d '{"cfr_id": "53ac09aa-9363-46ef-a02d-ca6af2c185ba", "cfr_direct_url": "https://www.youtube.com/watch?v=GCRX7Go6eHM&list=RDMMGCRX7Go6eHM&start_radio=1"}' \
		-X POST http://localhost:5001/record/stop | jq '.success,.error'

	echo -e "\n\tSent start request and a worker is available"
	echo -ne "\tCode:"
	curl -s -H 'Content-Type:application/json' \
			-d '{"cfr_id": "53ac09aa-9363-46ef-a02d-ca6af2c185ba", "cfr_direct_url": "https://www.youtube.com/watch?v=GCRX7Go6eHM&list=RDMMGCRX7Go6eHM&start_radio=1"}' \
			-X POST http://localhost:5001/record/start | jq '.success,.error'
	echo -e "\tSending stop request on a recording worker"
	echo -ne "\tCode:"
	curl -s -H 'Content-Type:application/json' \
		-d '{"cfr_id": "53ac09aa-9363-46ef-a02d-ca6af2c185ba", "cfr_direct_url": "https://www.youtube.com/watch?v=GCRX7Go6eHM&list=RDMMGCRX7Go6eHM&start_radio=1"}' \
		-X POST http://localhost:5001/record/stop | jq '.success,.error'
fi

if [[ "$case" == 4 ]]; then
	echo "Case #4: Send 2 consecutive stop request"

	echo -e "\n\tSent start request and a worker is available"
	echo -ne "\tCode:"
	curl -s -H 'Content-Type:application/json' \
			-d '{"cfr_id": "53ac09aa-9363-46ef-a02d-ca6af2c185ba", "cfr_direct_url": "https://www.youtube.com/watch?v=GCRX7Go6eHM&list=RDMMGCRX7Go6eHM&start_radio=1"}' \
			-X POST http://localhost:5001/record/start | jq '.success,.error'
	echo -e "\tSending 2 consecutive stop request on a recording worker"
	sleep 3
	for i in {1..2}; do
		echo -ne "\tCode:"
		curl -s -H 'Content-Type:application/json' \
			-d '{"cfr_id": "53ac09aa-9363-46ef-a02d-ca6af2c185ba", "cfr_direct_url": "https://www.youtube.com/watch?v=GCRX7Go6eHM&list=RDMMGCRX7Go6eHM&start_radio=1"}' \
			-X POST http://localhost:5001/record/stop | jq '.success,.error'
		sleep 3
	done
fi


