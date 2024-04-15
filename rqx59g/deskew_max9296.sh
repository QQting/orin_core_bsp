#!/bin/bash

I2C_SWITCH=30
if [ $1 ]; then
    I2C_SWITCH=$1
fi

#sudo i2ctransfer -f -y $I2C_SWITCH w3@0x48 0x03 0x13 0x40 # disable mipi csi out
sudo i2ctransfer -f -y $I2C_SWITCH w3@0x48 0x03 0x30 0x04 # CSI 2x4 mode

# deskew_init
sudo i2ctransfer -f -y $I2C_SWITCH w3@0x48 0x04 0x43 0x80
sudo i2ctransfer -f -y $I2C_SWITCH w3@0x48 0x04 0x83 0x80

# deskew_periodic
# sudo i2ctransfer -f -y $I2C_SWITCH w3@0x48 0x04 0x44 0xB8
# sudo i2ctransfer -f -y $I2C_SWITCH w3@0x48 0x04 0x84 0xB8

#sudo i2ctransfer -f -y $I2C_SWITCH w3@0x48 0x00 0x10 0x21 # One-shot reset and Link A
#sudo i2ctransfer -f -y $I2C_SWITCH w3@0x48 0x00 0x10 0x22 # One-shot reset and Link B
sudo i2ctransfer -f -y $I2C_SWITCH w3@0x48 0x00 0x10 0x23 # One-shot reset and Link A & B

#sudo i2ctransfer -f -y $I2C_SWITCH w3@0x48 0x03 0x13 0x42 # enable mipi csi out
sudo i2ctransfer -f -y $I2C_SWITCH w3@0x48 0x03 0x30 0x84 # Force CSI output clock under CSI 2x4 mode
