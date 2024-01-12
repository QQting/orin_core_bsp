#!/bin/bash

# sudo ./reset_lock_err_max96712.sh <I2C_BUS> <DESER_ADDR> <CAM_SEL>
# CAM_SEL:
# 1: sg3-isx031-gmsl2
# 2: sg8-ox08bc-gmsl2
# 3: sg5-imx490-gmsl2
sudo ./reset_lock_err_max96712.sh 2 0x4b 1
sudo ./reset_lock_err_max96712.sh 2 0x6b 1
sudo ./reset_lock_err_max96712.sh 7 0x4b 1
sudo ./reset_lock_err_max96712.sh 7 0x6b 1
