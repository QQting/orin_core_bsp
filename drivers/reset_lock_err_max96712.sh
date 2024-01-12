#!/bin/bash

# [IMX490 & OX08B & ISX031]

#
# 1st max96712 -> i2c_bus=2, deser_addr=0x4b
# 2nd max96712 -> i2c_bus=2, deser_addr=0x6b
# 3rd max96712 -> i2c_bus=7, deser_addr=0x4b
# 4th max96712 -> i2c_bus=7, deser_addr=0x6b
#

# echo arg1=$1
# echo arg2=$2
# echo arg3=$3

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

camera_array=([1]=sg3-isx031-gmsl2
              [2]=sg8-ox08bc-gmsl2
              [3]=sg5-imx490-gmsl2)

if [ -z $3 ]; then
    # if arg $3 not exists:
    echo 1:${camera_array[1]}
    echo 2:${camera_array[2]}
    echo 3:${camera_array[3]}
    green_print "Press select your camera type:"
	read key
else
	key=$3
fi
green_print CAM_SEL=${camera_array[$key]}

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

if [ ${camera_array[key]} == sg3-isx031-gmsl2 ]; then
    i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x10 0x11  # MAX96717F use 3Gbps
    i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x11 0x11
    green_print "DPHY Speed 3Gbps"
else
    i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x10 0x22  # MAX9295 use 6Gbps
    i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x11 0x22
    green_print "DPHY Speed 6Gbps"
fi

# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x06 0xF1 # Enable GMSL2 for Link A only
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x06 0xFF # Enable all 4 Links in GMSL2 mode
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x18 0x0F # One-shot reset
sleep 0.1

i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x0B 0x02 # Enable MIPI CSI
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x08 0xA0 0x84 # Force all MIPI clocks running

