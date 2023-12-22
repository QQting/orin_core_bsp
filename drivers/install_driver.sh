#!/bin/bash

# enable error abort
set -e

MODULE_CONF=gmsl2_sensors.conf
KO_FILE=gmsl2_sensors.ko
LIB_MODULE_PATH=/lib/modules/$(uname -r)/extra

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

# copy kernel modules config
sudo cp -a $MODULE_CONF /etc/modules-load.d/

# copy kernel modules
sudo cp -a $KO_FILE $LIB_MODULE_PATH
sudo depmod -a
echo "Kernel modules have been installed"

