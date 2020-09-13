#!/usr/bin/bash

COUNTER_CHAMPS=()

RED='\033[0;31m'
WHITE='\033[1;37m'
NC='\033[0m'

get_weak_against () {
	champ_name=$1

	curl -s https://lolcounter.com/champions/$champ_name/weak | grep -oP "(?<=class='name'>).+(?=</div>)"
}

get_strong_against () {
	champ_name=$1

	curl -s https://lolcounter.com/champions/$champ_name/strong | grep -oP "(?<=class='name'>).+(?=</div>)"
}

get_goes_well_with () {
	champ_name=$1

	curl -s https://lolcounter.com/champions/$champ_name/good | grep -oP "(?<=class='name'>).+(?=</div>)"
}

get_general_tips () {
	champ_name=$1
	curl -s https://lolcounter.com/champions/$champ_name | grep -oP "(?<=class='_tip'>).+(?=\.)"
}
print_in_one_line () {
	echo "$@" 
}

print_list () {
	while IFS= read -r line; do
		echo -e "\t - $line"
	done <<< "$@"
}


print_horizontal_line () {
	printf "${WHITE}=======================================================================================${NC}\n"
}
for arg in $@
do
	case $arg in
	--counter=*|-c=*)
		counter_champ="${arg#*=}"
		strong_against=$(get_strong_against $counter_champ)
		weak_against=$(get_weak_against $counter_champ)
		tips=$(get_general_tips $counter_champ)

		print_horizontal_line
		printf "${RED}STRONG AGAINST${NC}\n"
		print_in_one_line $strong_against
		print_horizontal_line
		printf "${RED}WEAK AGAINST${NC}\n"
		print_in_one_line $weak_against
		print_horizontal_line
		printf "${RED}TIPS${NC}\n"
#		echo "$tips"
		print_list "$tips"
		shift
		;;
	*)
		echo "Error: Unknown flag $1"
		exit 1
	esac

done
