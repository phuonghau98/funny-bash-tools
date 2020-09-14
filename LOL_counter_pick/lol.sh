#!/usr/bin/bash

COUNTER_CHAMPS=()

RED='\033[0;31m'
WHITE='\033[1;37m'
NC='\033[0m'

COUNTER_SP="COUNTER"
WEAK_AGAINST_SP="WEAK_AGAINST"
STRONG_AGAINST_SP="STRONG_AGAINST"
COUNTER_TIPS_SP="COUNTER_TIPS"

get_weak_against () {
	champ_name=$1
	if [[ -f ".cache/$champ_name" ]] && [[ ! -z $(get_cache $champ_name $WEAK_AGAINST_SP) ]]; then
		echo "There is cache"
		get_cache $champ_name $WEAK_AGAINST_SP	
	else
		data=$(curl -s https://lolcounter.com/champions/$champ_name/weak | grep -oP "(?<=class='name'>).+(?=</div>)")
		echo $data
		create_cache $champ_name "$data" $WEAK_AGAINST_SP
	fi
}

get_strong_against () {
	champ_name=$1

	if [[ -f ".cache/$champ_name" ]] && [[ ! -z $(get_cache $champ_name $STRONG_AGAINST_SP) ]]; then
		echo "get from cache..."
		get_cache $champ_name $STRONG_AGAINST_SP	
	else
		data=$(curl -s https://lolcounter.com/champions/$champ_name/strong | grep -oP "(?<=class='name'>).+(?=</div>)")
		echo $data
		create_cache $champ_name "$data" $STRONG_AGAINST_SP
	fi
}

get_goes_well_with () {
	champ_name=$1

	curl -s https://lolcounter.com/champions/$champ_name/good | grep -oP "(?<=class='name'>).+(?=</div>)"
}

get_general_tips () {
	champ_name=$1
	if [[ -f ".cache/$champ_name" ]] && [[ ! -z $(get_cache $champ_name $COUNTER_TIPS_SP) ]]; then
		get_cache $champ_name $COUNTER_TIPS_SP	
	else
		data=$(curl -s https://lolcounter.com/champions/$champ_name | grep -oP "(?<=class='_tip'>).+(?=\.)")
		echo "$data"
		create_cache $champ_name "$data" $COUNTER_TIPS_SP
	fi
}

print_in_one_line () {
	echo "$@" 
}

print_list () {
	while IFS= read -r line; do
		echo -e "\t - $line"
	done <<< "$@"
}

create_cache () {
	champ_name=$1
	data=$2
	section=$3
	if [[ ! -d ".cache" ]]; then
		mkdir ".cache"
	fi

	echo -e "$section\n$data\nEND_$section" >> ".cache/$champ_name"
}

get_cache () {
	champ_name=$1
	section=$2
        cat ".cache/$champ_name" | awk "/$section/,/END_$section/" |sed '1d;$d'
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
