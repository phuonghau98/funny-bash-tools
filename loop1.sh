#!/usr/bin/bash

for planet in "Mecury 36" "Venus 67" "Earth 93" "Mars 142" "jupiter 483"
do
	set -- $planet

	echo "$1                          $2,000,000 miles from the sun"
done

exit 0
