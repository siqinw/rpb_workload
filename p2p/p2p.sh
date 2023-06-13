#!/bin/bash

PCI_DEVICE_PATH="/sys/bus/pci/devices"
FIRST_DEVICE=$(lspci | grep 0d52 | head -1 | awk {'print $1'})
FIRST_MMIO_ADDR=$(lspci -s "$FIRST_DEVICE" -v | grep "Memory at" | head -1 | awk {'print $3'})
SECOND_DEVICE=$(lspci | grep 0d52 | sed -n 2p | awk {'print $1'})
SECOND_MMIO_ADDR=$(lspci -s "$SECOND_DEVICE" -v | grep "Memory at" | head -1 | awk {'print $3'})
SIZE=4 ## Linux team hard-coded P2P Memory read/write size to 4 bytes 15013624226

first_to_second()
{
    echo 3 > $PCI_DEVICE_PATH/"0000:$FIRST_DEVICE"/testcase/mem_op
    echo $1 > $PCI_DEVICE_PATH/"0000:$FIRST_DEVICE"/testcase/mem_size
    echo $2 > $PCI_DEVICE_PATH/"0000:$FIRST_DEVICE"/testcase/mem_attr
    echo 0x"$SECOND_MMIO_ADDR" > $PCI_DEVICE_PATH/"0000:$FIRST_DEVICE"/testcase/mmio_addr
    echo 1 > $PCI_DEVICE_PATH/"0000:$FIRST_DEVICE"/testcase/run

    echo 4 > $PCI_DEVICE_PATH/"0000:$FIRST_DEVICE"/testcase/mem_op
    echo 1 > $PCI_DEVICE_PATH/"0000:$FIRST_DEVICE"/testcase/run
}

second_to_first()
{
    echo 3 > $PCI_DEVICE_PATH/"0000:$SECOND_DEVICE"/testcase/mem_op
    echo $1 > $PCI_DEVICE_PATH/"0000:$SECOND_DEVICE"/testcase/mem_size
    echo $2 > $PCI_DEVICE_PATH/"0000:$SECOND_DEVICE"/testcase/mem_attr
    echo 0x"$FIRST_MMIO_ADDR" > $PCI_DEVICE_PATH/"0000:$SECOND_DEVICE"/testcase/mmio_addr
    echo 1 > $PCI_DEVICE_PATH/"0000:$SECOND_DEVICE"/testcase/run

    echo 4 > $PCI_DEVICE_PATH/"0000:$SECOND_DEVICE"/testcase/mem_op
    echo 1 > $PCI_DEVICE_PATH/"0000:$SECOND_DEVICE"/testcase/run
}

homogeneous_workload()
{
    echo $1 > $PCI_DEVICE_PATH/"0000:$FIRST_DEVICE"/testcase/mem_size
    echo $2 > $PCI_DEVICE_PATH/"0000:$FIRST_DEVICE"/testcase/mem_attr
    echo 3 > $PCI_DEVICE_PATH/"0000:$FIRST_DEVICE"/testcase/mem_op # P2P Memory Read
    echo 0x"$SECOND_MMIO_ADDR" > $PCI_DEVICE_PATH/"0000:$FIRST_DEVICE"/testcase/mmio_addr
    echo 1 > $PCI_DEVICE_PATH/"0000:$FIRST_DEVICE"/testcase/run
    echo 4 > $PCI_DEVICE_PATH/"0000:$FIRST_DEVICE"/testcase/mem_op # P2P Memory Write
    echo 1 > $PCI_DEVICE_PATH/"0000:$FIRST_DEVICE"/testcase/run

    echo $1 > $PCI_DEVICE_PATH/"0000:$SECOND_DEVICE"/testcase/mem_size
    echo $2 > $PCI_DEVICE_PATH/"0000:$SECOND_DEVICE"/testcase/mem_attr
    echo 3 > $PCI_DEVICE_PATH/"0000:$SECOND_DEVICE"/testcase/mem_op
    echo 0x"$FIRST_MMIO_ADDR" > $PCI_DEVICE_PATH/"0000:$SECOND_DEVICE"/testcase/mmio_addr
    echo 1 > $PCI_DEVICE_PATH/"0000:$SECOND_DEVICE"/testcase/run
    echo 4 > $PCI_DEVICE_PATH/"0000:$SECOND_DEVICE"/testcase/mem_op
    echo 1 > $PCI_DEVICE_PATH/"0000:$SECOND_DEVICE"/testcase/run
}

case $1 in
    1)
        # two private devices
        homogeneous_workload $SIZE 1 # default
        ## homogeneous_workload $SIZE 2 # shared ## Private device unable to access shared MMIO 15013611305
        ;;
    2)
        # two shared devices
        homogeneous_workload $SIZE 2 # shared
        ;;
    3)
        # private device TO shared device [shared]
        # shared device TO private device [shared]
        auth_attr=$(dmesg | grep $FIRST_DEVICE | grep "arch_dev_authorized" |  awk {'print $9'})
        if [ $auth_attr = "3" ]; then # FIRST_DEVICE is private
            first_to_second $SIZE 2 # private->shared
            first_to_second $SIZE 2
            second_to_first $SIZE 2 # shared->private
            second_to_first $SIZE 2
        else # SECOND_DEVICE is private
            second_to_first $SIZE 2
            second_to_first $SIZE 2
            first_to_second $SIZE 2 # private->shared
            first_to_second $SIZE 2
        fi
        ;;
    4)
        # shared device TO private device [encrypted]
        auth_attr=$(dmesg | grep $FIRST_DEVICE | grep "arch_dev_authorized" |  awk {'print $9'})
        if [ $auth_attr = "3" ]; then # FIRST_DEVICE is private
            second_to_first $SIZE 1
            second_to_first $SIZE 1
        fi
        ;;
    *)
        echo "Unkown P2P MMIO transaction type"
        ;;
esac
