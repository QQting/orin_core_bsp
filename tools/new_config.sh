#!/bin/bash

# [IMX490 & OX08B & ISX031]

#
# 1st max96712 -> i2c_bus=2, deser_addr=0x4b
# 2nd max96712 -> i2c_bus=2, deser_addr=0x6b
# 3rd max96712 -> i2c_bus=7, deser_addr=0x4b
# 4th max96712 -> i2c_bus=7, deser_addr=0x6b
#

I2C_SWITCH=2
if [ $1 ]; then
    I2C_SWITCH=$1
fi

DESER_ADDR=0x4b
if [ $2 ]; then
    DESER_ADDR=$2
fi

CAM_SEL_LIST=3333
if [ $3 ]; then
    CAM_SEL_LIST=$3
fi

DPHY_RX_SPEED_AB=0x22
DPHY_RX_SPEED_CD=0x22
SER_GPIO_VALUE=(0x10 0x10 0x10 0x10)

function set_serializer()
{
    # 9295/96717
    echo "[sensors]: serializer-$1"

    if [[ $4 == 0 ]]; then
        # 0 means no camera, do nothing
        echo "skipped"
        return
    fi
    
    echo set_serializer input params: $1, $2, $3, $4

    # default serializer 7bit addr
    SER_DEFAULT=0x40

    link_select=0xF$((1 << $1))
    i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x06 $link_select # Enable only Link-$1
    sleep 0.2
    
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_DEFAULT 0x02 0xBE 0x10
    sleep 1
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_DEFAULT 0x03 0x18 0x5E # enable(=bit6) datatype 0x1E to route to video pipe Z
    
    # Set Serializer GPIO
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_DEFAULT 0x02 0xD3 $2
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_DEFAULT 0x02 0xD6 $2
    

    if [[ $3 == 0x4b ]]; then
        SER_8BIT_ADDR=0x4$((1+$1 << 1))
    elif [[ $3 == 0x6b ]]; then
        SER_8BIT_ADDR=0x6$((1+$1 << 1))
    fi
    
    echo SER_8BIT_ADDR=$SER_8BIT_ADDR
    i2ctransfer -f -y $I2C_SWITCH w3@$SER_DEFAULT 0x00 0x00 $SER_8BIT_ADDR
}

# the input parameter must be four digits
if [[ $CAM_SEL_LIST =~ ^[0-9]{4}$ ]]; then
    # cam_type=()
    for (( i=0; i<${#CAM_SEL_LIST}; i++ )); do
        digit=${CAM_SEL_LIST:$i:1}
        if [[ $digit == 0 ]]; then 
            # no camera, do nothing
            sleep 0
        elif [[ $digit == 3 ]]; then 
            # cam_type+=($digit)
            # echo "cam_type[$i] = ${cam_type[$i]}"
            # 3MP camera MAX96717F should use 3Gbps(0x01 or 0x10) as the RX Speed
            case $i in
                0)
                    DPHY_RX_SPEED_AB=$(( (DPHY_RX_SPEED_AB & 0xF0) | 0x01 ))
                    DPHY_RX_SPEED_AB=$(printf "0x%02X" $DPHY_RX_SPEED_AB)
                ;;
                1)
                    DPHY_RX_SPEED_AB=$(( (DPHY_RX_SPEED_AB & 0x0F) | 0x10 ))
                    DPHY_RX_SPEED_AB=$(printf "0x%02X" $DPHY_RX_SPEED_AB)
                ;;
                2)
                    DPHY_RX_SPEED_CD=$(( (DPHY_RX_SPEED_CD & 0xF0) | 0x01 ))
                    DPHY_RX_SPEED_CD=$(printf "0x%02X" $DPHY_RX_SPEED_CD)
                ;;
                3)
                    DPHY_RX_SPEED_CD=$(( (DPHY_RX_SPEED_CD & 0x0F) | 0x10 ))
                    DPHY_RX_SPEED_CD=$(printf "0x%02X" $DPHY_RX_SPEED_CD)
                ;;
            esac
            SER_GPIO_VALUE[$i]=0x10
        elif [[ $digit == 5 ]]; then
            # cam_type+=($digit)
            # echo "cam_type[$i] = ${cam_type[$i]}"
            SER_GPIO_VALUE[$i]=0x00
        elif [[ $digit == 8 ]]; then
            # cam_type+=($digit)
            # echo "cam_type[$i] = ${cam_type[$i]}"
            sleep 0
        else
            echo "Error! Input parameter should be four digits consist of 0, 3, 5, 8"
            exit 1
        fi
    done
else
    echo "Error! Input parameter should be four digits consist of 0, 3, 5, 8"
    exit 1
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
green_print "CAM_SEL_LIST=$CAM_SEL_LIST"
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


i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x0B 0x00  # MIPI CSI disable
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x06 0xF0  # disable all 4 Links in GMSL2 mode

sleep 0.1

# Configure DPHY RX Speed for LINK A/B/C/D
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x10 $DPHY_RX_SPEED_AB
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x11 $DPHY_RX_SPEED_CD
green_print "DPHY Speed Register Values: $DPHY_RX_SPEED_AB $DPHY_RX_SPEED_CD"
sleep 0.1

i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0xF0 0x62  # Enable Pipe 0/1 for Link A/B stream ID 2 (ST_ID=2 also means SER's Pipe Z)
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0xF1 0xEA  # Enable Pipe 2/3 for Link C/D stream ID 2
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0xF4 0x0F  # Enable 0 - 3 Pipes

# For Pipe 0, set source and destination VC/DT for 3 data types (YUV422-8bit, FS and FE)
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x0B 0x07  # Enable mapping SRC_0 -> DST_0, SRC_1 -> DST_1, SRC_2 -> DST_2
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x0D 0x1E  # SRC_0 for VC=0 & DT=YUV422-8bit
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x0E 0x1E  # DST_0 for VC=0 & DT=YUV422-8bit
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x0F 0x00  # SRC_1 for VC=0 & DT=Frame Start Code
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x10 0x00  # DST_1 for VC=0 & DT=Frame Start Code
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x11 0x01  # SRC_2 for VC=0 & DT=Frame End Code
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x12 0x01  # DST_2 for VC=0 & DT=Frame End Code
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x2D 0x15  # Map DST_0/1/2 to to MIPI PHY Controller 1 (Port A)

# For Pipe 1, set source and destination VC/DT for 3 data types (YUV422-8bit, FS and FE)
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x4B 0x07
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x4D 0x1E
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x4E 0x5E  # DST VC=1
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x4F 0x00
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x50 0x40  # DST VC=1
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x51 0x01
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x52 0x41  # DST VC=1
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x6D 0x15

# For Pipe 2, set source and destination VC/DT for 3 data types (YUV422-8bit, FS and FE)
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x8B 0x07
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x8D 0x1E
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x8E 0x9E  # DST VC=2
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x8F 0x00
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x90 0x80  # DST VC=2
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x91 0x01
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x92 0x81  # DST VC=2
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0xAD 0x15

# For Pipe 3, set source and destination VC/DT for 3 data types (YUV422-8bit, FS and FE)
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0xCB 0x07
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0xCD 0x1E
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0xCE 0xDE  # DST VC=3
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0xCF 0x00
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0xD0 0xC0  # DST VC=3
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0xD1 0x01
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0xD2 0xC1  # DST VC=3
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0xED 0x15

sleep 0.1

i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x08 0xA0 0x04  # default MIPI PHY 2x4 lanes

# # Here we use both Port A and Port B
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x08 0xA2 0xF0  # Eable MIPI PHY 0/1/2/3 (Port A and Port B)
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x08 0xA3 0xE4  # Map PHY 0/1 (Port A) to data lane 0/1/2/3
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x08 0xA4 0xE4  # Map PHY 2/3 (Port B) to data lane 0/1/2/3
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x0A 0xC0  # default 4 data lane cnt for PHY 0
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x4A 0xC0  # default 4 data lane cnt for PHY 1
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x8A 0xC0  # default 4 data lane cnt for PHY 2
# i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0xCA 0xC0  # default 4 data lane cnt for PHY 3

# Below we use Port A only
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x08 0xA2 0x30  # Eable MIPI PHY 0/1 (Port A only)
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x08 0xA3 0xE4  # Map PHY 0/1 (Port A) to data lane 0/1/2/3
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x0A 0xC0  # default 4 data lane cnt for PHY 0
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x09 0x4A 0xC0  # default 4 data lane cnt for PHY 1

    i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x15 0x37
    i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x18 0x37
    i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x1B 0x37
    i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x1E 0x37
    green_print "MIPI Speed 2.3Gbps"
    # i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x15 0x39
    # i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x18 0x39
    # i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x1B 0x39
    # i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x1E 0x39
    # green_print "MIPI Speed 2.5Gbps"

sleep 0.1

echo call set_serializer
set_serializer 0 ${SER_GPIO_VALUE[0]} $DESER_ADDR ${CAM_SEL_LIST:0:1}
set_serializer 1 ${SER_GPIO_VALUE[1]} $DESER_ADDR ${CAM_SEL_LIST:1:1}
set_serializer 2 ${SER_GPIO_VALUE[2]} $DESER_ADDR ${CAM_SEL_LIST:2:1}
set_serializer 3 ${SER_GPIO_VALUE[3]} $DESER_ADDR ${CAM_SEL_LIST:3:1}

sleep 0.2
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x06 0xFF # Enable all 4 Links in GMSL2 mode
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x00 0x18 0x0F # One-shot reset
sleep 0.1

i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x04 0x0B 0x02 # Enable MIPI CSI
i2ctransfer -f -y $I2C_SWITCH w3@$DESER_ADDR 0x08 0xA0 0x84 # Force all MIPI clocks running

sleep 0.2

echo "[96712-bit3]: GMSL2 link locked"
val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x00 0x1A r1)
echo LINK A: $val
lock=$((val & 0x08))
if [[ ! $lock -eq $((16#8)) ]]; then
	echo LINK A is NOT locked!
else
	echo LINK A locked
fi
val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x00 0x0A r1)
echo LINK B: $val
lock=$((val & 0x08))
if [[ ! $lock -eq $((16#8)) ]]; then
	echo LINK B is NOT locked!
else
	echo LINK B locked
fi
val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x00 0x0B r1)
echo LINK C: $val
lock=$((val & 0x08))
if [[ ! $lock -eq $((16#8)) ]]; then
	echo LINK C is NOT locked!
else
	echo LINK C locked
fi
val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x00 0x0C r1)
echo LINK D: $val
lock=$((val & 0x08))
if [[ ! $lock -eq $((16#8)) ]]; then
	echo LINK D is NOT locked!
else
	echo LINK D locked
fi

echo "[96712-bit6]: Video pipeline locked"
val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x01 0x08 r1)
echo Video pipe: $val
lock=$((val & 0x40))
if [[ ! $lock -eq $((16#40)) ]]; then
	echo Video pipe 0 is NOT locked!
else
	echo video pipe 0 locked
fi
val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x01 0x1A r1)
echo Video pipe: $val
lock=$((val & 0x40))
if [[ ! $lock -eq $((16#40)) ]]; then
	echo Video pipe 1 is NOT locked!
else
	echo video pipe 1 locked
fi
val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x01 0x2C r1)
echo Video pipe: $val
lock=$((val & 0x40))
if [[ ! $lock -eq $((16#40)) ]]; then
	echo Video pipe 2 is NOT locked!
else
	echo video pipe 2 locked
fi
val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x01 0x3E r1)
echo Video pipe: $val
lock=$((val & 0x40))
if [[ ! $lock -eq $((16#40)) ]]; then
	echo Video pipe 3 is NOT locked!
else
	echo video pipe 3 locked
fi

# [OX08BC]: 3840, 2160
# [IMX490]: 2880, 1860
# [ISX031]: 1920, 1536
#v4l2-ctl --set-fmt-video=width=3840,height=2160 --stream-mmap --stream-count=0 -d /dev/video$1
#v4l2-ctl --set-fmt-video=width=2880,height=1860 --stream-mmap --stream-count=0 -d /dev/video$1
#v4l2-ctl --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count=0 -d /dev/video$1
