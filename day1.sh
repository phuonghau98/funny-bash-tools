#!/bin/bash

spaced () {
	echo ==============
	echo $1
	echo ==============
}

printmenu () {
	spaced Menu
	echo "1. Hello world"
	echo "2. Foo"
	echo "3. Bar"
	echo "4. exit"
	echo "Please confirm your choice: "
}

while true
do
	printmenu
	read selected
	if [[ "$selected" == "4" ]];then
		echo "Bye bye!"
		exit 0
	fi
	clear
	printmenu
	case "$selected" in
		1)
			echo "Hello world is a very first program that person enrolled in programming write"
			;;
		2)
			echo "What is foo"
			;;
		3)
			echo "Bar is another type"
			;;
		*)
			echo "Unknown option"
			;;
	esac
done

