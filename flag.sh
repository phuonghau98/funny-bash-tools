#!/bin/bash

SHOULD_INITIALIZE=0
CACHE_DIRECTORY=""

login () {
	read -p "Enter your username: " USERNAME
	read -s -p "Enter your password:" PASSWORD
	echo -e "\n"
	if [[ "$USERNAME" == "hvphuong98@gmail.com" ]] && [[ "$PASSWORD" == "30091998" ]]
	then
		echo "Login successfully"
		exit 0
	else
		echo "Wrong username or password"
		exit 1
	fi
}

if [[ "$1" == "login" ]]; then
	login
fi

for arg in "$@"
do
	case $arg in
		-i|--initialize)
			SHOULD_INITIALIZE=1
			shift
		;;
	--cache=*|-c=*)
		CACHE_DIRECTORY="${arg#*=}"
		shift
		;;
	--cache|-c)
		CACHE_DIRECTORY="$2"
		shift
		shift
		;;
	--*)
		echo "Error: Unknown flag"
		exit 1
	esac
done

echo "SHOULD_INITIALIZE: $SHOULD_INITIALIZE"
echo "CACHE_DIRECTORY: $CACHE_DIRECTORY"

