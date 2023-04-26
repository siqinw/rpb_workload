#!/bin/bash
CYCLE_NUMBER=5

for (( i=0; i<$CYCLE_NUMBER; i++ ))
do 
	for OP in 1 2
	do
		for ATTR in 1 2
		do
			echo "OP: $OP  ATTR: $ATTR"		
		done
	done
done