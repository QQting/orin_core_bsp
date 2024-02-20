#!/bin/bash

#!/bin/bash

# [IMX490 & OX08B & ISX031]

#
# 1st max96712 -> i2c_bus=2, deser_addr=0x4b
# 2nd max96712 -> i2c_bus=2, deser_addr=0x6b
# 3rd max96712 -> i2c_bus=7, deser_addr=0x4b
# 4th max96712 -> i2c_bus=7, deser_addr=0x6b
#

echo arg1=$1
echo arg2=$2

I2C_SWITCH=2
if [ $1 ]; then
    I2C_SWITCH=$1
fi

DESER_ADDR=0x4b
if [ $2 ]; then
    DESER_ADDR=$2
fi

function red_print() {
    echo -e "\e[1;31m$1\e[0m"
}

function green_print() {
    echo -e "\e[1;32m$1\e[0m"
}

echo -----------------------------------
green_print "i2c_bus=$I2C_SWITCH"
green_print "de-serializer=$DESER_ADDR"
echo -----------------------------------

i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x08 0xA0 0x04 # default MIPI PHY 2x4 lanes
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x18 0x0F # One-shot reset

# start MIPI de-skew before video streaming are received
 i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x03 0x80
#  i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x04 0xB8
 i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x43 0x80
#  i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x44 0xB8
 i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x83 0x80
#  i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x84 0xB8
 i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0xC3 0x80
#  i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0xC4 0xB8
# de-skew done
 
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x08 0xA0 0x84 # Force all MIPI clocks running
