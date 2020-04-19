#!/bin/bash

declare -A array
array=(
    [item_1]="item_11"
    [item_2]="item_21"
)

for i in "${!array[@]}"; do
    echo "$i" "${array[$i]}"
done
