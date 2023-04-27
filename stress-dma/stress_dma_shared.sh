#!/bin/bash

echo "7 4 1 7" > /proc/sys/kernel/printk

PCI_DEVICE_PATH="/sys/bus/pci/devices"
VTC_PCI_DEVICE="0000:00:03.0"

# OP:
# 1 - read
# 2 - write
OP=2

# SIZE: data size
SIZE=4096

# ATTR:
# 1 - default
# 2 - force_shared
ATTR=1

CYCLE_NUMBER=5
echo $SIZE > $PCI_DEVICE_PATH/$VTC_PCI_DEVICE/testcase/mem_size

for (( i=0; i<$CYCLE_NUMBER; i++ ))
do 
	for OP in 1 2
	do
		echo $OP > $PCI_DEVICE_PATH/$VTC_PCI_DEVICE/testcase/mem_op 
		echo 2 > $PCI_DEVICE_PATH/$VTC_PCI_DEVICE/testcase/mem_attr
		echo 1 > $PCI_DEVICE_PATH/$VTC_PCI_DEVICE/testcase/run
		## TODO: wait for test to finish ("Test Result" appear in dmesg)
		sleep 3
	done
done

