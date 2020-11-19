#!/bin/bash
declare arr=("foo" "bar")
txt=$(echo -e "someoneelse_db 0.0.0.0:27018->27017/tcp\n
mongodb 0.0.0.0:27017->27017/tcp")
IFS=';' read -r -a arr <<< $(echo $txt | tr $'\n' ';')
for i in "${!arr[@]}"
do
    echo [$i] "${arr[$i]}"
done