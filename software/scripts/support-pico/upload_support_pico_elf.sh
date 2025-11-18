#!/bin/sh

if [ $# -ne 2 ]; then
    echo "Usage: upload_support_pico_elf.sh host file"
    exit 1;
fi

HOST=$1
FILE=$2

if [ ! -f $FILE ]; then
    echo "File \"$FILE\" not found"
    exit 1;
fi

# Send the file to ~/tmp on the host. Password-less login is assumed
#
scp $FILE $HOST:tmp

# Set the SWD MUX to point at the Support Pico
#
ssh $HOST "sudo pinctrl set 23 op ;\
           sudo pinctrl set 24 op ;\
           sudo pinctrl set 23 dl ;\
           sudo pinctrl set 24 dl"

ssh $HOST "cd tmp && sudo openocd -f interface/raspberrypi-swd.cfg -f target/rp2040.cfg \
           -c \"program ./$FILE verify reset exit\""

exit 0;
