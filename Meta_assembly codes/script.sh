#!/bin/sh

input_1=$1
input_2=$2
output=$3

while read -r -a line ;
  do 
    num="${line[3]}"
    if (( $num > 1000)); 
    then 
       node="${line[0]}"
       echo "${line[0]} ${line[2]} ${line[3]} ${line[10]} ${line[11]}" > "$output"
       break
    fi ; 
done < "$input_1"

Pattern=""
Pattern+="$node"
Pattern+="\s"
echo $Pattern


grep -A1 $Pattern "$input_2" >> "$output"


