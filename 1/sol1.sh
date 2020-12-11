#!/bin/bash

set -eu

nums=()
while read -r a
do
    nums+=($a)
done

for i in "${nums[@]}"
do
    for j in "${nums[@]}"
    do
        if [[ 2020 -eq $(( i + j )) ]]
        then
            echo "$i + $j = 2020"
            echo "$i x $j = $(( i * j ))"
            exit
        fi
    done
done
