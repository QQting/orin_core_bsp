#!/bin/bash

KERNEL_MODULE=gmsl2_sensors.ko

# install the dependencies
echo "checking the dependencies..."
REQUIRED_PKG="v4l-utils"
PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
echo Checking for $REQUIRED_PKG: $PKG_OK
if [ "" = "$PKG_OK" ]; then
	echo "No $REQUIRED_PKG. Setting up $REQUIRED_PKG."
	sudo apt-get --yes install $REQUIRED_PKG
fi

# build driver
echo "building driver..."
make --silent 2> /dev/null

# load driver
if [[ ! -f "$KERNEL_MODULE" ]]; then
	echo "Error! $KERNEL_MODULE not found!"
	exit 1
fi
echo "loading driver..."
sudo insmod $KERNEL_MODULE 2> /dev/null


echo "configuring cameras..."
# power down all cameras to avoid seralizer(0x40) conflicts
sudo i2ctransfer -f -y 1 w2@0x28 0x01 0x00
#sudo i2ctransfer -f -y 1 w2@0x29 0x01 0x00
sudo i2ctransfer -f -y 7 w2@0x28 0x01 0x00
sudo i2ctransfer -f -y 7 w2@0x29 0x01 0x00

# sudo ./config_2.5g.sh <I2C_BUS> <DESER_ADDR> <CAM_SEL>
# CAM_SEL:
# 1: sg3-isx031-gmsl2
# 2: sg8-ox08bc-gmsl2
# 3: sg5-imx490-gmsl2

#deser0
echo "configuring CAM1..."
sudo i2ctransfer -f -y 1 w2@0x28 0x01 0x0F # power up cameras
sleep 0.1
sudo ./config_2.5g.sh 2 0x4b 3

#deser1
#echo "configuring CAM2..."
#sudo i2ctransfer -f -y 1 w2@0x29 0x01 0x0F # power up cameras
#sleep 0.1
#sudo ./config_2.5g.sh 2 0x6b 3

#deser2
echo "configuring CAM3..."
sudo i2ctransfer -f -y 7 w2@0x28 0x01 0x0F # power up cameras
sleep 0.1
sudo ./config_2.5g.sh 7 0x4b 3

#deser3
echo "configuring CAM4..."
sudo i2ctransfer -f -y 7 w2@0x29 0x01 0x0F # power up cameras
sleep 0.1
sudo ./config_2.5g.sh 7 0x6b 3


echo "============================="
echo " All configurations are done!"
echo "============================="
