#!/usr/bin/env bash

FILE=$1

while IFS= read -r line; do
	echo -e "$line\n" >> out.txt
done < $FILE
