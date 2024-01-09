#!/bin/bash

if [[ $1 -eq 0 ]]; then
    # power on all th cameras
    sudo i2ctransfer -f -y 1 w2@0x28 0x01 0x10
    sudo i2ctransfer -f -y 1 w2@0x29 0x01 0x10
    sudo i2ctransfer -f -y 7 w2@0x28 0x01 0x10
    sudo i2ctransfer -f -y 7 w2@0x29 0x01 0x10
elif [[ $1 -eq 1 ]]; then
    # power off all the cameras
    sudo i2ctransfer -f -y 1 w2@0x28 0x01 0x1F
    sudo i2ctransfer -f -y 1 w2@0x29 0x01 0x1F
    sudo i2ctransfer -f -y 7 w2@0x28 0x01 0x1F
    sudo i2ctransfer -f -y 7 w2@0x29 0x01 0x1F
fi

