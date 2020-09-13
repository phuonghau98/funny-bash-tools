#!/bin/bash

FILE=/etc/resolv.conf

if [ -f "$FILE" ]; then
	echo "$FILE exits"
fi
