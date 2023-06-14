#!/bin/bash

P2P_TYPE=$1
CYCLE_NUMBER=$2

for (( i=0; i<$CYCLE_NUMBER; i++ ))
do 
	./p2p.sh $P2P_TYPE
done