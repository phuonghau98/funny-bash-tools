#!/usr/bin/bash

files=()

#Add all paths to list

read -r -d '' -a files < <(find $(pwd)  -maxdepth 1 -type f)

for file in ${files[@]}
do
	echo "Backed up ${file##*/}"
	cp "$file" "$file"_backup
done
