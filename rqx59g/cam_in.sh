#!/bin/bash

set -e # enable error abort

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

set +e # disable error abort

# load driver
if [[ ! -f "$KERNEL_MODULE" ]]; then
	echo "Error! $KERNEL_MODULE not found!"
	exit 1
fi
echo "loading driver..."
sudo insmod $KERNEL_MODULE 2> /dev/null

#deser0
echo "configuring Port1 and Port2..."
sudo ./config_cam_in.sh 30 0x48 1

#deser1
echo "configuring Port3 and Port4..."
sudo ./config_cam_in.sh 31 0x48 1

echo "============================="
echo " All configurations are done!"
echo "============================="

sudo ./deskew_max9296.sh 30 0x48
sudo ./deskew_max9296.sh 31 0x48

STREAM_COUNT=0
echo "video0-3"
for ((i=0;i<=3;i++)); 
do
    X=0
    Y=$((260*$i))
    gnome-terminal  --geometry 50x10+$X+$Y --title=video$i -- bash -c '
        date -R
        bash -c "v4l2-ctl --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count='$STREAM_COUNT' -d /dev/video'$i'"
        ret=$?
        if [[ $ret -eq 0 ]]; then
            date -R
            echo ====
            echo PASS
            echo ====
        fi
        exec bash -i'
done

