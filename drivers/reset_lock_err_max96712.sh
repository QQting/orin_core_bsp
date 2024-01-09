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


# off/on power to reset cameras
if [[ $I2C_SWITCH -eq 2 ]]; then
	POWER_PROTECT_BUS=1
else
	POWER_PROTECT_BUS=7
fi
if [[ $DESER_ADDR -eq $((16#4b)) ]]; then
        POWER_PROTECT=0x28
else
        POWER_PROTECT=0x29
fi
echo POWER_PROTECT_BUS=$POWER_PROTECT_BUS
echo POWER_PROTECT=$POWER_PROTECT
i2ctransfer -f -y $POWER_PROTECT_BUS w2@$POWER_PROTECT 0x01 0x00 # power down
sleep 0.1
i2ctransfer -f -y $POWER_PROTECT_BUS w2@$POWER_PROTECT 0x01 0x0F # power up
sleep 0.1

# completely reset MAX96712
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x13 0x40 # RESET_ALL
sleep 0.1

i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x0B 0x00  # MIPI CSI disable
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x06 0xF0  # disable all 4 Links in GMSL2 mode

sleep 0.2
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x06 0xF1 # Enable GMSL2 for Link A only
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x18 0x0F # One-shot reset
sleep 0.1

i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x0B 0x02 # Enable MIPI CSI
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x08 0xA0 0x84 # Force all MIPI clocks running

