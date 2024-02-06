#!/bin/bash

MODULE_CONF=gmsl2_sensors.conf
KO_FILE=gmsl2_sensors.ko
LIB_MODULE_PATH=/lib/modules/$(uname -r)/extra

if [[ `id -u` -ne 0 ]]; then
        echo ""
        echo "Please run as root(sudo command needed)"
        echo ""
        exit 1
fi

# install the camera driver header
echo "installing the camera driver headers..."
sudo ./AU-SPR_cam_header.sh

# install the dependencies
echo "checking the dependencies..."
sudo apt update
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

# copy kernel modules config
sudo cp -a $MODULE_CONF /etc/modules-load.d/

# copy kernel modules
sudo cp -a $KO_FILE $LIB_MODULE_PATH
sudo depmod -a
echo "Kernel modules have been installed"

echo "loading camera driver now..."
sudo insmod $LIB_MODULE_PATH/$KO_FILE

echo "done"
