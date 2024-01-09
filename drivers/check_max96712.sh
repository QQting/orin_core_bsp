#!/bin/bash -e

if [[ $EUID -ne 0 ]]; then
        echo "Please use sudo to run this script."
        exit 1
fi


# Please get pin definitions from `sudo cat /sys/kernel/debug/gpio`

# MAX96712 pins:
SERDES_0_LOCK=300
SERDES_0_ERR=301
SERDES_1_LOCK=302
SERDES_1_ERR=303
SERDES_2_LOCK=284
SERDES_2_ERR=285
SERDES_3_LOCK=286
SERDES_3_ERR=287

export_gpio()
{
    echo "Exporting GPIO..."
    echo $SERDES_0_LOCK > /sys/class/gpio/export
    echo $SERDES_0_ERR > /sys/class/gpio/export
    echo $SERDES_1_LOCK > /sys/class/gpio/export
    echo $SERDES_1_ERR > /sys/class/gpio/export
    echo $SERDES_2_LOCK > /sys/class/gpio/export
    echo $SERDES_2_ERR > /sys/class/gpio/export
    echo $SERDES_3_LOCK > /sys/class/gpio/export
    echo $SERDES_3_ERR > /sys/class/gpio/export
    
    echo in > /sys/class/gpio/gpio$SERDES_0_LOCK/direction
    echo in > /sys/class/gpio/gpio$SERDES_0_ERR/direction
    echo in > /sys/class/gpio/gpio$SERDES_1_LOCK/direction
    echo in > /sys/class/gpio/gpio$SERDES_1_ERR/direction
    echo in > /sys/class/gpio/gpio$SERDES_2_LOCK/direction
    echo in > /sys/class/gpio/gpio$SERDES_2_ERR/direction
    echo in > /sys/class/gpio/gpio$SERDES_3_LOCK/direction
    echo in > /sys/class/gpio/gpio$SERDES_3_ERR/direction
}
cleanup()
{
    echo "Cleaning up before exit..."
    echo $SERDES_0_LOCK > /sys/class/gpio/unexport
    echo $SERDES_0_ERR > /sys/class/gpio/unexport
    echo $SERDES_1_LOCK > /sys/class/gpio/unexport
    echo $SERDES_1_ERR > /sys/class/gpio/unexport
    echo $SERDES_2_LOCK > /sys/class/gpio/unexport
    echo $SERDES_2_ERR > /sys/class/gpio/unexport
    echo $SERDES_3_LOCK > /sys/class/gpio/unexport
    echo $SERDES_3_ERR > /sys/class/gpio/unexport
}
trap cleanup EXIT

read_gpio_value()
{
    echo "MAX96172: <LOCK, ERROR> 0->Error 1->OK"
    lock=$(cat /sys/class/gpio/gpio$SERDES_0_LOCK/value)
    err=$(cat /sys/class/gpio/gpio$SERDES_0_ERR/value)
    echo MAX96712-0: $lock, $err
    lock=$(cat /sys/class/gpio/gpio$SERDES_1_LOCK/value)
    err=$(cat /sys/class/gpio/gpio$SERDES_1_ERR/value)
    echo MAX96712-1: $lock, $err
    lock=$(cat /sys/class/gpio/gpio$SERDES_2_LOCK/value)
    err=$(cat /sys/class/gpio/gpio$SERDES_2_ERR/value)
    echo MAX96712-2: $lock, $err
    lock=$(cat /sys/class/gpio/gpio$SERDES_3_LOCK/value)
    err=$(cat /sys/class/gpio/gpio$SERDES_3_ERR/value)
    echo MAX96712-3: $lock, $err
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

