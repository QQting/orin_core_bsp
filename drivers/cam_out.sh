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


echo "configuring cameras..."
# power down all cameras to avoid seralizer(0x40) conflicts
sudo i2ctransfer -f -y 1 w2@0x28 0x01 0x00
sudo i2ctransfer -f -y 1 w2@0x29 0x01 0x00
sudo i2ctransfer -f -y 7 w2@0x28 0x01 0x00
sudo i2ctransfer -f -y 7 w2@0x29 0x01 0x00

# sudo ./config.sh <I2C_BUS> <DESER_ADDR> <CAM_SEL>
# CAM_SEL:
# 0: no camera
# 3: sg3-isx031-gmsl2
# 5: sg5-imx490-gmsl2
# 8: sg8-ox08bc-gmsl2

#deser0
echo "configuring CAM1..."
sudo i2ctransfer -f -y 1 w2@0x28 0x01 0x0F # power up cameras
sleep 0.1
sudo ./config_camout.sh 2 0x4b 3000

#deser1
echo "configuring CAM2..."
sudo i2ctransfer -f -y 1 w2@0x29 0x01 0x0F # power up cameras
sleep 0.1
sudo ./config_camout.sh 2 0x6b 3000

#deser2
echo "configuring CAM3..."
sudo i2ctransfer -f -y 7 w2@0x28 0x01 0x0F # power up cameras
sleep 0.1
sudo ./config_camout.sh 7 0x4b 3000

#deser3
echo "configuring CAM4..."
sudo i2ctransfer -f -y 7 w2@0x29 0x01 0x0F # power up cameras
sleep 0.1
sudo ./config_camout.sh 7 0x6b 3000

echo "============================="
echo " All configurations are done!"
echo "============================="

STREAM_COUNT=0
for ((i=0;i<=15;i+=4)); 
do
    X=0
    Y=$((70*$i))
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
sleep 0.1

echo "sending deskew_init signal"
sudo ./deskew.sh 2 0x4b
sudo ./deskew.sh 2 0x6b
sudo ./deskew.sh 7 0x4b
sudo ./deskew.sh 7 0x6b

echo "start cam_out testing..."

