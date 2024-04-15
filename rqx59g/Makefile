PWD ?= $(shell pwd)
BUILD_DIR ?= $(shell pwd)
ARCH ?= arm64
KERNEL_SRC_DIR  ?= /lib/modules/$(shell uname -r)/build
DTS_FILE ?= sensing-camera-overlay-max9296
#DTS_FILE ?= sensing-camera-overlay-max9296_leopard-board

obj-m := gmsl2_sensors.o

.PHONY: all
all: clean modules dtbo

dtbo:
	dtc -I dts -O dtb -o $(DTS_FILE).dtbo $(DTS_FILE).dts
	sudo cp -a $(DTS_FILE).dtbo /boot/
	sudo /opt/nvidia/jetson-io/config-by-hardware.py -n 1='Sensing GMSL2 Camera Device Tree Overlay'

modules:
	make -C "${KERNEL_SRC_DIR}" ARCH="${ARCH}" src="${PWD}" M="${BUILD_DIR}" \
		-j4 \
		modules

clean:
	make -C "${KERNEL_SRC_DIR}" ARCH="${ARCH}" src="${PWD}" M="${BUILD_DIR}" \
		clean
