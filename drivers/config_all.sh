#!/bin/bash

# power down all cameras to avoid seralizer(0x40) conflicts
sudo i2ctransfer -f -y 1 w2@0x28 0x01 0x00
sudo i2ctransfer -f -y 1 w2@0x29 0x01 0x00
sudo i2ctransfer -f -y 7 w2@0x28 0x01 0x00
sudo i2ctransfer -f -y 7 w2@0x29 0x01 0x00

# sudo ./config.sh <I2C_BUS> <DESER_ADDR> <CAM_SEL>
# CAM_SEL:
# 1: sg3-isx031-gmsl2
# 2: sg8-ox08bc-gmsl2
# 3: sg5-imx490-gmsl2

#deser0
sudo i2ctransfer -f -y 1 w2@0x28 0x01 0x0F # power up cameras
sleep 0.1
sudo ./config.sh 2 0x4b 2

#deser1
sudo i2ctransfer -f -y 1 w2@0x29 0x01 0x0F # power up cameras
sleep 0.1
sudo ./config.sh 2 0x6b 2

#deser2
sudo i2ctransfer -f -y 7 w2@0x28 0x01 0x0F # power up cameras
sleep 0.1
sudo ./config.sh 7 0x4b 3

#deser3
sudo i2ctransfer -f -y 7 w2@0x29 0x01 0x0F # power up cameras
sleep 0.1
sudo ./config.sh 7 0x6b 1

