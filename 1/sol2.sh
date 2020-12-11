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
        for k in "${nums[@]}"
        do
            if [[ 2020 -eq $(( i + j + k )) ]]
            then
                echo "$i + $j + $k = 2020"
                echo "$i x $j x $k = $(( i * j * k ))"
                exit
            fi
        done
    done
done
