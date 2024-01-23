#!/bin/bash

EXPORT_PWM0=/sys/class/pwm/pwmchip0/export
EXPORT_PWM1=/sys/class/pwm/pwmchip1/export
EXPORT_PWM2=/sys/class/pwm/pwmchip2/export
EXPORT_PWM3=/sys/class/pwm/pwmchip3/export

PERIOD_PWM0=/sys/class/pwm/pwmchip0/pwm0/period
PERIOD_PWM1=/sys/class/pwm/pwmchip1/pwm0/period
PERIOD_PWM2=/sys/class/pwm/pwmchip2/pwm0/period
PERIOD_PWM3=/sys/class/pwm/pwmchip3/pwm0/period

DUTY_CYCLE_PWM0=/sys/class/pwm/pwmchip0/pwm0/duty_cycle
DUTY_CYCLE_PWM1=/sys/class/pwm/pwmchip1/pwm0/duty_cycle
DUTY_CYCLE_PWM2=/sys/class/pwm/pwmchip2/pwm0/duty_cycle
DUTY_CYCLE_PWM3=/sys/class/pwm/pwmchip3/pwm0/duty_cycle

ENABLE_PWM0=/sys/class/pwm/pwmchip0/pwm0/enable
ENABLE_PWM1=/sys/class/pwm/pwmchip1/pwm0/enable
ENABLE_PWM2=/sys/class/pwm/pwmchip2/pwm0/enable
ENABLE_PWM3=/sys/class/pwm/pwmchip3/pwm0/enable

FPS=20
if [[ $1 ]]; then
	FPS=$1
fi

# export CAM1~CAM4 PWM pins
echo 0 | sudo tee $EXPORT_PWM0 > /dev/null 2>&1
#echo 0 | sudo tee $EXPORT_PWM1 > /dev/null 2>&1
echo 0 | sudo tee $EXPORT_PWM2 > /dev/null 2>&1
echo 0 | sudo tee $EXPORT_PWM3 > /dev/null 2>&1


if [[ $FPS == 5 ]]; then
	echo 200000000 > $PERIOD_PWM0
	echo 1000000 > $DUTY_CYCLE_PWM0
	echo 1 > $ENABLE_PWM0
#        echo 200000000 > $PERIOD_PWM1
#        echo 1000000 > $DUTY_CYCLE_PWM1
#        echo 1 > $ENABLE_PWM1
        echo 200000000 > $PERIOD_PWM2
        echo 1000000 > $DUTY_CYCLE_PWM2
        echo 1 > $ENABLE_PWM2
        echo 200000000 > $PERIOD_PWM3
        echo 1000000 > $DUTY_CYCLE_PWM3
        echo 1 > $ENABLE_PWM3
elif [[ $FPS == 10 ]]; then
        echo 100000000 > $PERIOD_PWM0
        echo 1000000 > $DUTY_CYCLE_PWM0
        echo 1 > $ENABLE_PWM0
#        echo 100000000 > $PERIOD_PWM1
#        echo 1000000 > $DUTY_CYCLE_PWM1
#        echo 1 > $ENABLE_PWM1
        echo 100000000 > $PERIOD_PWM2
        echo 1000000 > $DUTY_CYCLE_PWM2
        echo 1 > $ENABLE_PWM2
        echo 100000000 > $PERIOD_PWM3
        echo 1000000 > $DUTY_CYCLE_PWM3
        echo 1 > $ENABLE_PWM3
elif [[ $FPS == 15 ]]; then
        echo 66666666 > $PERIOD_PWM0
        echo 1000000 > $DUTY_CYCLE_PWM0
        echo 1 > $ENABLE_PWM0
#        echo 66666666 > $PERIOD_PWM1
#        echo 1000000 > $DUTY_CYCLE_PWM1
#        echo 1 > $ENABLE_PWM1
        echo 66666666 > $PERIOD_PWM2
        echo 1000000 > $DUTY_CYCLE_PWM2
        echo 1 > $ENABLE_PWM2
        echo 66666666 > $PERIOD_PWM3
        echo 1000000 > $DUTY_CYCLE_PWM3
        echo 1 > $ENABLE_PWM3
elif [[ $FPS == 20 ]]; then
        echo 50000000 > $PERIOD_PWM0
        echo 1000000 > $DUTY_CYCLE_PWM0
        echo 1 > $ENABLE_PWM0
#        echo 50000000 > $PERIOD_PWM1
#        echo 1000000 > $DUTY_CYCLE_PWM1
#        echo 1 > $ENABLE_PWM1
        echo 50000000 > $PERIOD_PWM2
        echo 1000000 > $DUTY_CYCLE_PWM2
        echo 1 > $ENABLE_PWM2
        echo 50000000 > $PERIOD_PWM3
        echo 1000000 > $DUTY_CYCLE_PWM3
        echo 1 > $ENABLE_PWM3
elif [[ $FPS == 25 ]]; then
        echo 40000000 > $PERIOD_PWM0
        echo 1000000 > $DUTY_CYCLE_PWM0
        echo 1 > $ENABLE_PWM0
#        echo 40000000 > $PERIOD_PWM1
#        echo 1000000 > $DUTY_CYCLE_PWM1
#        echo 1 > $ENABLE_PWM1
        echo 40000000 > $PERIOD_PWM2
        echo 1000000 > $DUTY_CYCLE_PWM2
        echo 1 > $ENABLE_PWM2
        echo 40000000 > $PERIOD_PWM3
        echo 1000000 > $DUTY_CYCLE_PWM3
        echo 1 > $ENABLE_PWM3
elif [[ $FPS == 30 ]]; then
        echo 33333333 > $PERIOD_PWM0
        echo 1000000 > $DUTY_CYCLE_PWM0
        echo 1 > $ENABLE_PWM0
#        echo 33333333 > $PERIOD_PWM1
#        echo 1000000 > $DUTY_CYCLE_PWM1
#        echo 1 > $ENABLE_PWM1
        echo 33333333 > $PERIOD_PWM2
        echo 1000000 > $DUTY_CYCLE_PWM2
        echo 1 > $ENABLE_PWM2
        echo 33333333 > $PERIOD_PWM3
        echo 1000000 > $DUTY_CYCLE_PWM3
        echo 1 > $ENABLE_PWM3
fi

