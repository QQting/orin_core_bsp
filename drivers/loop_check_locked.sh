#!/bin/bash

SEL_LINK_A=1
SEL_LINK_B=0
SEL_LINK_C=1
SEL_LINK_D=0

I2C_SWITCH=2
if [ $1 ]; then
    I2C_SWITCH=$1
fi

DESER_ADDR=0x4b
if [ $2 ]; then
    DESER_ADDR=$2
fi

while [[ 1 ]];
do

#echo "[96712-bit3]: GMSL2 link locked"
if [[ $SEL_LINK_A -eq 1 ]]; then
	val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x00 0x1A r1)
	lock=$((val & 0x08))
	if [[ ! $lock -eq $((16#8)) ]]; then
		echo LINK A is NOT locked!
	fi
fi
if [[ $SEL_LINK_B -eq 1 ]]; then
	val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x00 0x0A r1)
	lock=$((val & 0x08))
	if [[ ! $lock -eq $((16#8)) ]]; then
		echo LINK B is NOT locked!
	fi
fi
if [[ $SEL_LINK_C -eq 1 ]]; then
	val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x00 0x0B r1)
	lock=$((val & 0x08))
	if [[ ! $lock -eq $((16#8)) ]]; then
		echo LINK c is NOT locked!
	fi
fi
if [[ $SEL_LINK_D -eq 1 ]]; then
	val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x00 0x0C r1)
	lock=$((val & 0x08))
	if [[ ! $lock -eq $((16#8)) ]]; then
		echo LINK D is NOT locked!
	fi
fi

#echo "[96712-bit6]: Video pipeline locked"
if [[ $SEL_LINK_A -eq 1 ]]; then
	val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x01 0x08 r1)
	lock=$((val & 0x40))
	if [[ ! $lock -eq $((16#40)) ]]; then
		echo Video pipe 0 is NOT locked!
	fi
fi
if [[ $SEL_LINK_B -eq 1 ]]; then
	val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x01 0x1A r1)
	lock=$((val & 0x40))
	if [[ ! $lock -eq $((16#40)) ]]; then
		echo Video pipe 1 is NOT locked!
	fi
fi
if [[ $SEL_LINK_C -eq 1 ]]; then
	val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x01 0x2C r1)
	lock=$((val & 0x40))
	if [[ ! $lock -eq $((16#40)) ]]; then
		echo Video pipe 2 is NOT locked!
	fi
fi
if [[ $SEL_LINK_D -eq 1 ]]; then
	val=$(i2ctransfer -f -y $I2C_SWITCH w2@$DESER_ADDR 0x01 0x3E r1)
	lock=$((val & 0x40))
	if [[ ! $lock -eq $((16#40)) ]]; then
		echo Video pipe 3 is NOT locked!
	fi
fi

done
