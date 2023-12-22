#!/bin/bash

# enable error abort
set -e

MODULE_CONF=gmsl2_sensors.conf
KO_FILE=gmsl2_sensors.ko
LIB_MODULE_PATH=/lib/modules/$(uname -r)/extra

# remove kernel modules config
sudo rm -f /etc/modules-load.d/$MODULE_CONF

# remove kernel modules
sudo rm -f $LIB_MODULE_PATH/$KO_FILE
sudo depmod -a
echo "Kernel modules have been removed"

