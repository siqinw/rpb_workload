#!/bin/bash

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

echo $OP > $PCI_DEVICE_PATH/$VTC_PCI_DEVICE/testcase/mem_op
echo $SIZE > $PCI_DEVICE_PATH/$VTC_PCI_DEVICE/testcase/mem_size
echo $ATTR > $PCI_DEVICE_PATH/$VTC_PCI_DEVICE/testcase/mem_attr
echo 1 > $PCI_DEVICE_PATH/$VTC_PCI_DEVICE/testcase/run


