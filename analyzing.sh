#!/usr/bin/bash
MAX=1000
for ((nr=1; nr<$MAX; nr++))
do
	let "t1 = nr % 5"
	echo $t1
done
