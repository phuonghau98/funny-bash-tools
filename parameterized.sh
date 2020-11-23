#!/bin/bash

DIRNAME=/usr/bin
FILETYPE="shell script"
LOGFILE=logfile

file "$DIRNAME"/* | grep "$FILETYPE" | tee $LOGFILE | wc -l
