PWD ?= $(shell pwd)
BUILD_DIR ?= $(shell pwd)
ARCH ?= arm64
obj-m := gmsl2_sensors.o
KERNEL_SRC_DIR  ?= /lib/modules/$(shell uname -r)/build

.PHONY: all
all: clean modules

modules:
	make -C "${KERNEL_SRC_DIR}" ARCH="${ARCH}" src="${PWD}" M="${BUILD_DIR}" \
		-j4 \
		modules

clean:
	make -C "${KERNEL_SRC_DIR}" ARCH="${ARCH}" src="${PWD}" M="${BUILD_DIR}" \
		clean
