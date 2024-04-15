#!/bin/bash

I2C_SWITCH=30
if [ $1 ]; then
    I2C_SWITCH=$1
fi

DESER_ADDR=0x48
if [ $2 ]; then
    DESER_ADDR=$2
fi

# default serializer 7bit addr
SER_DEFAULT=0x40
# SER_DEFAULT=0x62

SER_A_8B=0x84
SER_B_8B=0xC0
SER_A_7B=0x42
SER_B_7B=0x60

SER_A_CONNECTED=0
SER_B_CONNECTED=0

# off/on power to reset cameras
POWER_PROTECT=0x28
if [[ $I2C_SWITCH -gt 31 ]]; then
        POWER_PROTECT=0x29
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
green_print "serializer=$SER_DEFAULT"
green_print "POWER_PROTECT=$POWER_PROTECT"
echo -----------------------------------

camera_array=([1]=sg3-isx031-gmsl2
              [2]=sg8-ox08bc-gmsl2
              [3]=sg5-imx490-gmsl2)

echo 1:${camera_array[1]}
echo 2:${camera_array[2]}
echo 3:${camera_array[3]}

if [ -z $3 ]; then
    # if arg $3 not exists:
    green_print "Press select your camera type:"
	read key
else
	key=$3
fi
echo key=$key


# control MAX20089: camera power regulator
i2ctransfer -f -y $I2C_SWITCH w2@$POWER_PROTECT 0x01 0x00 # power down
sleep 0.1

i2ctransfer -f -y $I2C_SWITCH w2@$POWER_PROTECT 0x01 0x0F # power up
sleep 0.1

# completely reset MAX9296
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x10 0x80 # RESET_ALL
sleep 0.1

if [ ${camera_array[key]} == sg3-isx031-gmsl2 ]; then
    i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x01 0x01 # MAX96717F use 3Gbps
else
    i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x01 0x02 # MAX9295 use 6Gbps
fi
sleep 0.1

# Enable DES Link A to configure SER-A
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x10 0x01 # Enable Link A only
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x10 0x21 # One-shot reset and Link A only
sleep 0.1

#######################
# The 1st SER: MAX9295
#######################
red_print "[9295]: serializer-a"
val=$(i2ctransfer -f -y $I2C_SWITCH w2@$SER_DEFAULT 0x00 0x00 r1)
ret=$?
if [[ $ret -eq 0 && $val -eq $((16#80)) ]]; then
    SER_A_CONNECTED=1
    echo "SER-A connected"
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_DEFAULT 0x00 0x00 $SER_A_8B
elif [[ $ret -eq 0 && $val -eq $((16#00)) ]]; then
    # there is a confliction when using Leopard board
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_DEFAULT 0x00 0x00 $SER_A_8B
    val=$(i2ctransfer -f -y $I2C_SWITCH w2@$SER_A_7B 0x00 0x00 r1)
    ret=$?
    if [[ $ret -eq 0 && $val -eq $((16#84)) ]]; then
            SER_A_CONNECTED=1
            echo "SER-A connected"
    else
            echo "SER-A NOT connected"
    fi
else
    echo "SER-A NOT connected"
fi

i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x00 0x10 0x21 # One-shot reset SER-A and set to LINK A
sleep 0.1
i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x02 0xBE 0x10 # GPIO_OUT=1
sleep 1

# Set SER-A's output ST_ID
i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x00 0x5B 0x00 # Set ST_ID=0 (stream id)

if [ ${camera_array[key]} == sg3-isx031-gmsl2 ]; then
    # Note: Here we can only select Pipe Z due to MAX96717F (sg3-isx031-gmsl2) only has Pipe Z
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x00 0x02 0x43 # enable Pipe Z
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x03 0x08 0x64 # Enable line info(=bit6) and Pipe Z -> Port B
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x03 0x11 0x40 # Start SER's Port B pipe Z
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x03 0x18 0x5E # enable(=bit6) datatype 0x1E to route to video pipe Z
else
    # Note: Here we can select any pipes
    
    # SER's X/Y/Z/U channel selection
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x00 0x02 0x13 # enable Pipe X
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x00 0x02 0x23 # enable Pipe Y
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x00 0x02 0x43 # enable Pipe Z
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x00 0x02 0x83 # enable Pipe U
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x00 0x02 0x53 # enable Pipe X/Z
    
    # clock selection
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x03 0x08 0x61 # Enable line info(=bit6) and Pipe X -> Port B
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x03 0x08 0x62 # Enable line info(=bit6) and Pipe Y -> Port B
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x03 0x08 0x64 # Enable line info(=bit6) and Pipe Z -> Port B
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x03 0x08 0x68 # Enable line info(=bit6) and Pipe U -> Port B
    
    # data selection
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x03 0x11 0x10 # Start SER's Port B pipe X
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x03 0x11 0x20 # Start SER's Port B pipe Y
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x03 0x11 0x40 # Start SER's Port B pipe Z
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x03 0x11 0x80 # Start SER's Port B pipe U
    
    # SER route datatype
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x03 0x14 0x5E # enable(=bit6) datatype 0x1E to route to video pipe X
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x03 0x16 0x5E # enable(=bit6) datatype 0x1E to route to video pipe Y
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x03 0x18 0x5E # enable(=bit6) datatype 0x1E to route to video pipe Z
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x03 0x1A 0x5E # enable(=bit6) datatype 0x1E to route to video pipe U
fi

if [ ${camera_array[key]} == sg3-isx031-gmsl2 ]; then
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x02 0xD3 0x10
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x02 0xD6 0x10
fi
if [ ${camera_array[key]} == sg5-imx490-gmsl2 ]; then
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x02 0xD3 0x00
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x02 0xD6 0x00
fi

# # Disable SER control channel to avoid i2c communication error
# i2ctransfer -f -y $I2C_SWITCH w3@$SER_A_7B 0x04 0x04 0x80 # 

# Enable DES Link B to configure SER-B
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x10 0x02 # Enable Link B only
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x10 0x22 # One-shot reset and Link B only
sleep 0.1

#######################
# The 2nd SER: MAX9295
#######################
red_print "[9295]: serializer-b"
val=$(i2ctransfer -f -y $I2C_SWITCH w2@$SER_DEFAULT 0x00 0x00 r1)
ret=$?
if [[ $ret -eq 0 && $val -eq $((16#80)) ]]; then
    SER_B_CONNECTED=1
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_DEFAULT 0x00 0x00 $SER_B_8B
    echo "SER-B connected"
elif [[ $ret -eq 0 && $val -eq $((16#00)) ]]; then
    # There is 0x40 device in i2c-1 for Leopard board which will ack 0x00
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_DEFAULT 0x00 0x00 $SER_B_8B
    val=$(i2ctransfer -f -y $I2C_SWITCH w2@$SER_B_7B 0x00 0x00 r1)
    ret=$?
    if [[ $ret -eq 0 && $val -eq $((16#C0)) ]]; then
            SER_B_CONNECTED=1
            echo "SER-B connected"
    else
            echo "SER-B NOT connected"
    fi
else
    echo "SER-B NOT connected"
fi

i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x00 0x10 0x22 # One-shot reset SER-B and set to LINK B
sleep 0.1
i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x02 0xBE 0x10 # GPIO_OUT=1
sleep 1

# Set SER-B's output ST_ID
i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x00 0x5B 0x01 # Set ST_ID=1 (stream id)

if [ ${camera_array[key]} == sg3-isx031-gmsl2 ]; then
    # Note: Here we can only select Pipe Z due to MAX96717F (sg3-isx031-gmsl2) only has Pipe Z
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x00 0x02 0x43 # enable Pipe Z
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x03 0x08 0x64 # Enable line info(=bit6) and Pipe Z -> Port B
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x03 0x11 0x40 # Start SER's Port B pipe Z
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x03 0x18 0x5E # enable(=bit6) datatype 0x1E to route to video pipe Z
else
    # Note: Here we can select any pipes

    # SER's X/Y/Z/U channel selection
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x00 0x02 0x13 # Enable SER's Pipe X
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x00 0x02 0x23 # Enable SER's Pipe Y
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x00 0x02 0x43 # Enable SER's Pipe Z
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x00 0x02 0x83 # Enable SER's Pipe U
    
    # clock selection
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x03 0x08 0x61 # Enable line info(=bit6) and Pipe X -> Port B
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x03 0x08 0x62 # Enable line info(=bit6) and Pipe Y -> Port B
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x03 0x08 0x64 # Enable line info(=bit6) and Pipe Z -> Port B
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x03 0x08 0x68 # Enable line info(=bit6) and Pipe U -> Port B
    
    # data selection
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x03 0x11 0x10 # Start SER Port B's pipe X
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x03 0x11 0x20 # Start SER Port B's pipe Y
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x03 0x11 0x40 # Start SER Port B's pipe Z
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x03 0x11 0x80 # Start SER Port B's pipe U
    
    # SER route datatype
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x03 0x14 0x5E # enable(=bit6) datatype 0x1E to route to video pipe X
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x03 0x16 0x5E # enable(=bit6) datatype 0x1E to route to video pipe Y
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x03 0x18 0x5E # enable(=bit6) datatype 0x1E to route to video pipe Z
    # i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x03 0x1A 0x5E # enable(=bit6) datatype 0x1E to route to video pipe U
fi

if [ ${camera_array[key]} == sg3-isx031-gmsl2 ]; then
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x02 0xD6 0x10
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x02 0xD3 0x10
fi
if [ ${camera_array[key]} == sg5-imx490-gmsl2 ]; then
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x02 0xD6 0x00
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x02 0xD3 0x00
fi

# # Disable SER control channel to avoid i2c communication error
# i2ctransfer -f -y $I2C_SWITCH w3@$SER_B_7B 0x04 0x04 0x80 # 

###################
# The DES: MAX9296
###################
red_print "[9296]"

if [ $SER_A_CONNECTED -eq 1 ] && [ $SER_B_CONNECTED -eq 1 ];
then
    i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x10 0x03 # Enable Link A and B (reverse splitter mode)
    i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x10 0x23 # One-shot reset; enable Link A and B
elif [ $SER_A_CONNECTED -eq 1 ] && [ $SER_B_CONNECTED -eq 0 ];
then
    i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x10 0x01 # Enable Link A only
    i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x10 0x21 # One-shot reset; enable Link A only
elif [ $SER_A_CONNECTED -eq 0 ] && [ $SER_B_CONNECTED -eq 1 ];
then
    i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x10 0x02 # Enable Link B only
    i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x10 0x22 # One-shot reset; enable Link B only
fi
sleep 0.1

i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x03 0x13 0x00 # Disable CSI out
sleep 0.1

i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x03 0x30 0x04 # CSI 2x4 mode
# Note: PHY0 and PHY1 lanes are swapped in default
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x03 0x33 0x4E # PHY0 D0->D2 D1->D3, PHY1 D0->D0 D1->D1
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x03 0x33 0xE4 # PHY0 D0->D2 D1->D3, PHY1 D0->D0 D1->D1

# For Pipe X DST VC=0
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x50 0x00 # Control ST_ID=0 from SER to DES's Pipe X
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x0B 0x07 # Enable mapping SRC_0/1/2 -> DST_0/1/2
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x0D 0x1E # SRC_0 for VC=0 & DT=YUV422-8bit
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x0E 0x1E # DST_0 for VC=0 & DT=YUV422-8bit
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x0F 0x00 # SRC_1 for VC=0 & DT=Frame Start Code
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x10 0x00 # DST_1 for VC=0 & DT=Frame Start Code
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x11 0x01 # SRC_2 for VC=0 & DT=Frame End Code
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x12 0x01 # DST_2 for VC=0 & DT=Frame End Code
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x2D 0x15 # Map DST_0/1/2 to to MIPI PHY Controller 1 (Port A)

# For Pipe Y DST VC=1
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x51 0x01 # Control ST_ID=1 from SER to DES's Pipe Y
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x4B 0x07 # Enable mapping SRC_0/1/2 -> DST_0/1/2
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x4D 0x1E # SRC_0 for VC=0 & DT=YUV422-8bit
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x4E 0x5E # DST_0 for VC=1 & DT=YUV422-8bit
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x4F 0x00 # SRC_1 for VC=0 & DT=Frame Start Code
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x50 0x40 # DST_1 for VC=1 & DT=Frame Start Code
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x51 0x01 # SRC_2 for VC=0 & DT=Frame End Code
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x52 0x41 # DST_2 for VC=1 & DT=Frame End Code
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x6D 0x15 # Map DST_0/1/2 to to MIPI PHY Controller 1 (Port A)

# For Pipe Z DST VC=0
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x52 0x02 # Control ST_ID=2 from SER to DES's Pipe Z
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x8B 0x07 # Enable mapping SRC_0/1/2 -> DST_0/1/2
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x8D 0x1E # SRC_0 for VC=0 & DT=YUV422-8bit
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x8E 0x1E # DST_0 for VC=0 & DT=YUV422-8bit
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x8F 0x00 # SRC_1 for VC=0 & DT=Frame Start Code
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x90 0x00 # DST_1 for VC=0 & DT=Frame Start Code
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x91 0x01 # SRC_2 for VC=0 & DT=Frame End Code
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x92 0x01 # DST_2 for VC=0 & DT=Frame End Code
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0xAD 0x15 # Map DST_0/1/2 to to MIPI PHY Controller 1 (Port A)

# For Pipe U DST VC=1
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x53 0x03 # Control ST_ID=3 from SER to DES's Pipe U
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0xCB 0x07 # Enable mapping SRC_0/1/2 -> DST_0/1/2
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0xCD 0x1E # SRC_0 for VC=0 & DT=YUV422-8bit
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0xCE 0x5E # DST_0 for VC=1 & DT=YUV422-8bit
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0xCF 0x00 # SRC_1 for VC=0 & DT=Frame Start Code
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0xD0 0x40 # DST_1 for VC=1 & DT=Frame Start Code
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0xD1 0x01 # SRC_2 for VC=0 & DT=Frame End Code
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0xD2 0x41 # DST_2 for VC=1 & DT=Frame End Code
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0xED 0x15 # Map DST_0/1/2 to to MIPI PHY Controller 1 (Port A)

# DES's Port A settings
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x03 0x20 0x2F # DPHY 1.5 Gbps
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x4A 0xC0 # 4 lanes for Port A
# Leopard 2-lane settings:
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x03 0x20 0x39 # DPHY 2.5 Gbps
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x4A 0x40 # 2 lanes for Port A

# Don't care DES's Port B because it is not conencted to MIPI
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x03 0x34 0xE4 # PHY2 D0->D0 D1->D1, PHY3 D0->D2 D1->D3
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x03 0x23 0x2F # DPHY 1.5 Gbps
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x8A 0xC0 # 4 lanes for Port B
# end Port B

i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x03 0x13 0x02 # Enable CSI out
sleep 0.1

echo "[9296-bit3]: GMSL2 link locked"
val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x00 0x13 r1)
lock=$((val & 0x08))
if [[ ! $lock -eq $((16#8)) ]]; then
	echo MAX9296 GMSL LINK is NOT locked!
else
	echo MAX9296 GMSL LINK locked
fi

echo "[9296-bit6]: Video pipeline locked"
val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x01 0x08 r1)
lock=$((val & 0x40))
if [[ ! $lock -eq $((16#40)) ]]; then
	echo Video pipe x is NOT locked!
else
	echo video pipe x locked
fi
val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x01 0x1A r1)
lock=$((val & 0x40))
if [[ ! $lock -eq $((16#40)) ]]; then
	echo Video pipe y is NOT locked!
else
	echo video pipe y locked
fi
val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x01 0x2C r1)
lock=$((val & 0x40))
if [[ ! $lock -eq $((16#40)) ]]; then
	echo Video pipe z is NOT locked!
else
	echo video pipe z locked
fi
val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x01 0x3E r1)
lock=$((val & 0x40))
if [[ ! $lock -eq $((16#40)) ]]; then
	echo Video pipe u is NOT locked!
else
	echo video pipe u locked
fi

# [OX08BC]: 3840, 2160
# [IMX490]: 2880, 1860
# [ISX031]: 1920, 1536
#v4l2-ctl --set-fmt-video=width=3840,height=2160 --stream-mmap --stream-count=0 -d /dev/video$1
#v4l2-ctl --set-fmt-video=width=2880,height=1860 --stream-mmap --stream-count=0 -d /dev/video$1
#v4l2-ctl --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count=0 -d /dev/video$1

