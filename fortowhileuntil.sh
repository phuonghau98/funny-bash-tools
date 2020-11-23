#!/usr/bin/bash

planets=(Mecury Venus Earth Mars Jupiter Saturn)

i=0

while [[ $i < "${#planets[@]}" ]]
do
	echo ${planets[$i]}
	let "i++"
done


i=0
until (($i >= "${#planets[@]}"))
do
	echo ${planets[$i]}
	let "i++"
done

if [[ 5 -ge 3 ]]; then echo "5 greater than 3"; fi
