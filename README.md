This repository is forked from DongSheng@AutraTech, and I've modified many scripts for AU-SPR project.

# Test SOP

This test SOP assumes the 16pcs 3M cameras are already connected to the mini-fakra connectors.

-  Download files

    ```bash
    git clone https://github.com/QQting/orin_core_bsp.git
    ```

- Configuring the cameras

    ```bash
    cd orin_core_bsp/drivers
    sudo ./config_all.sh
    ```

- Check if /dev/video0 ~ /dev/video15 exist

    ```bash
    ls /dev/video* 
    ```

- Start camera test

    ```bash
    ./start_test.sh
    ```

    The test script will start to test 900 image frames for each camera. Once the video node receives 900 frames, it will show **PASS** in its terminal. Otherwise, it will freeze or show frame dropped.
    
    Note: You can modify `STREAM_COUNT=0` in `start_test.sh` to test infinite image frames, it will not stop util you terminate the scripts.

# Automatically Load Driver

Run below command once to build camera driver and automatically load driver at bootup.

```bash
cd orin_core_bsp/drivers
sudo ./install_driver.sh
```

Otherwise, if you want to stop loading driver automatically, please run below command:

```bash
cd orin_core_bsp/drivers
sudo ./remove_driver.sh
```

# Advanced Test SOP

Below test SOP is for engineers who may test different cameras on the specific CAM port.

### Download/Build/Load Camera Driver

Open a terminal, follow below commands to download the driver source codes:

```bash
# Download
git clone https://github.com/QQting/orin_core_bsp.git
```

Enter the driver folder, run `make` to build driver:

```bash
cd orin_core_bsp/drivers ; make
```

Check if the driver module `gmsl2_sensors.ko` has been generated successfully:

```bash
ls gmsl2_sensors.ko
```

Then type below command to load driver:

```bash
sudo insmod ./gmsl2_sensors.ko
```

After driver is loaded, check if /dev/video0 ~ /dev/video15 exist

```bash
ls /dev/video* 
```

### Prepare/Apply Camera Settings

In this steps, you should connect the GMSL2 cameras to Fakra connectors, and then use `config.sh` with options to configure the cameras.

The usage of `config.sh`:

```bash
sudo ./config.sh <I2C_BUS> <DESER_ADDR> <CAM_SEL>
```

The options for `config.sh`:

- <I2C_BUS> <DESER_ADDR>:
    - 2 0x4b: CAM1
    - 2 0x6b: CAM2
    - 7 0x4b: CAM3
    - 7 0x6b: CAM4
- <CAM_SEL>:
    1. sg3-isx031-gmsl2
    2. sg8-ox08bc-gmsl2
    3. sg5-imx490-gmsl2

Below commands are examples for configuring different cameras on different CAM ports:

```bash
# example for CAM1 with 5M cameras
sudo ./config.sh 2 0x4b 2

# example for CAM2 with 8M cameras
sudo ./config.sh 2 0x6b 3

# example for CAM3 with 3M cameras
sudo ./config.sh 7 0x4b 1

# example for CAM4 with 3M cameras
sudo ./config.sh 7 0x6b 1
```

Note: The camera can be hot plugged. Once the camera is reconnected, you should run config.sh to reconfigure the camera again.

### Start Camera Streaming

After all the camera are configured, now we can start streaming.

Note: The width and height are different based on what cameras you are testing. The `/dev/videoN` is also different based on which port the camera is inserted to.

```bash
# Install v4l-utils if v4l2-ctl not found
sudo apt update; sudo apt install v4l-utils -y

# example for 3M camera on port0 (CAM1 port0)
v4l2-ctl --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count=0 -d /dev/video0

# example 8M camera on port12 (CAM3 port0)
v4l2-ctl --set-fmt-video=width=3840,height=2160 --stream-mmap --stream-count=0 -d /dev/video8

# example 5M camera on port8 (CAM4 port0)
v4l2-ctl --set-fmt-video=width=2880,height=1860 --stream-mmap --stream-count=0 -d /dev/video12
```

## FSYNC Trigger Camera

The cameras supports FSYNC mode to allow external signal to trigger camera.
To enable FSYNC mode, please use below scripts to configure cameras:

```bash
# Use config_all_sync.sh to configure 16pcs 3M cameras
sudo ./config_all_sync.sh

# Or, use config_sync.sh to configure different cameras on different CAM ports
sudo ./config_sync.sh <I2C_BUS> <DESER_REG> <CAM_SEL>
```

### de-skew

Sometimes 8M cameras are not able to automatically start capturing frames due to skew calibration is needed. 

To enable skew calibration, please keep the camera stream opened and then run the deskew script:

```bash
sudo ./deskew.sh <I2C_BUS> <DESER_REG>
```
