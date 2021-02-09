#!/bin/bash

FILES="/usr/sbin/accept
/usr/sbin/pwck
/usr/sbin/chroot
/usr/bin/fakefile
/sbin/badblocks
/sbin/ypbind"

for FILE in $FILES
do
	if ! [ -f $FILE ]            # Check if file exists
	then
		echo "$FILE did not exist";
		continue 				 # On to next
	fi

	ls -l $FILE | awk '{ print $10"                    file size: "$5 }' # Print 2 fields
	whatis `basename $FILE`

done
