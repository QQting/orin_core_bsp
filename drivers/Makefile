PWD ?= $(shell pwd)
BUILD_DIR ?= $(shell pwd)
ARCH ?= arm64
obj-m := gmsl2_sensors.o
KERNEL_SRC_DIR  ?= /lib/modules/$(shell uname -r)/build
DTS_FILE ?= new-overlay

.PHONY: all
all: clean modules dtbo_2100

dtbo_2500:
	cpp -DMIPI_LANE_SPEED=2500 -nostdinc -I include -I arch  -undef -x assembler-with-cpp $(DTS_FILE).dts $(DTS_FILE).dts.preprocessed
	dtc -I dts -O dtb -o $(DTS_FILE).dtbo -p 0x1000 $(DTS_FILE).dts.preprocessed
	sudo cp $(DTS_FILE).dtbo /boot/
	sudo /opt/nvidia/jetson-io/config-by-hardware.py -n 1='New GMSL2 Camera Device Tree Overlay'

dtbo_2100:
	cpp -DMIPI_LANE_SPEED=2100 -nostdinc -I include -I arch  -undef -x assembler-with-cpp $(DTS_FILE).dts $(DTS_FILE).dts.preprocessed
	dtc -I dts -O dtb -o $(DTS_FILE).dtbo -p 0x1000 $(DTS_FILE).dts.preprocessed
	sudo cp $(DTS_FILE).dtbo /boot/
	sudo /opt/nvidia/jetson-io/config-by-hardware.py -n 1='New GMSL2 Camera Device Tree Overlay'

modules:
	make -C "${KERNEL_SRC_DIR}" ARCH="${ARCH}" src="${PWD}" M="${BUILD_DIR}" \
		-j4 \
		modules

clean:
	make -C "${KERNEL_SRC_DIR}" ARCH="${ARCH}" src="${PWD}" M="${BUILD_DIR}" \
		clean
