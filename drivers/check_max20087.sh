#!/bin/bash -e

if [[ $EUID -ne 0 ]]; then
        echo "Please use sudo to run this script."
        exit 1
fi

# Please get pin definitions from `sudo cat /sys/kernel/debug/gpio`

# MAX9295A pins:
MAX20087_INT_0=308
MAX20087_INT_1=309
MAX20087_INT_2=292
MAX20087_INT_3=293

export_gpio()
{
    echo "Exporting GPIO..."
    echo $MAX20087_INT_0 > /sys/class/gpio/export
    echo $MAX20087_INT_1 > /sys/class/gpio/export
    echo $MAX20087_INT_2 > /sys/class/gpio/export
    echo $MAX20087_INT_3 > /sys/class/gpio/export
    
    echo in > /sys/class/gpio/gpio$MAX20087_INT_0/direction
    echo in > /sys/class/gpio/gpio$MAX20087_INT_1/direction
    echo in > /sys/class/gpio/gpio$MAX20087_INT_2/direction
    echo in > /sys/class/gpio/gpio$MAX20087_INT_3/direction
}
cleanup()
{
    echo "Cleaning up before exit..."
    echo $MAX20087_INT_0 > /sys/class/gpio/unexport
    echo $MAX20087_INT_1 > /sys/class/gpio/unexport
    echo $MAX20087_INT_2 > /sys/class/gpio/unexport
    echo $MAX20087_INT_3 > /sys/class/gpio/unexport
}
trap cleanup EXIT

read_gpio_value()
{
    echo "MAX20087:"
    stat=$(cat /sys/class/gpio/gpio$MAX20087_INT_0/value)
    echo MAX20087-0: $stat
    stat=$(cat /sys/class/gpio/gpio$MAX20087_INT_1/value)
    echo MAX20087-1: $stat
    stat=$(cat /sys/class/gpio/gpio$MAX20087_INT_2/value)
    echo MAX20087-2: $stat
    stat=$(cat /sys/class/gpio/gpio$MAX20087_INT_3/value)
    echo MAX20087-3: $stat
}

# export sysfs GPIO
export_gpio

while true
do
	# read current GPI value
	read_gpio_value

        echo "press <Enter> to read again, or <Ctrl-C> to exit."
	read pause_key
done

