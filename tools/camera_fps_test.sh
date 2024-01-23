#!/bin/bash

# Pre-configure stream count
STREAM_COUNT=1800  # 1min=1*60*30
# STREAM_COUNT=108000  # 1hr=60*60*30
# STREAM_COUNT=1080000  # 10hr=10*60*60*30
#STREAM_COUNT=1296000  # 12hr

# Pre-configure the delta tolerance, default 0.02 means 33.33-0.02 <= delta <= 33.33+0.02
DELTA_TOLERANCE=0.02

# Pre-configure 0/3/5/8 MP to each video node, default is 3MP. 0 means no camera is connected.
VIDEO_0=3
VIDEO_1=3
VIDEO_2=3
VIDEO_3=3
VIDEO_4=0
VIDEO_5=0
VIDEO_6=0
VIDEO_7=0
VIDEO_8=3
VIDEO_9=3
VIDEO_10=3
VIDEO_11=3
VIDEO_12=3
VIDEO_13=3
VIDEO_14=3
VIDEO_15=3

verbose=0
for arg in "$@"
do
    if [[ $arg == "--verbose" ]] || [[ $arg == "-v" ]]
    then
        verbose=1
    fi
done

if [[ ! $EUID -eq 0 ]]; then
        echo "Please use 'sudo' to run this script."
    exit 1
fi

# start configuring cameras for each DESER
echo "Start configuring cameras..."
if [[ $verbose == 1 ]]; then
    sudo ./new_config.sh 2 0x4b $VIDEO_0$VIDEO_1$VIDEO_2$VIDEO_3
    sudo ./new_config.sh 2 0x6b $VIDEO_4$VIDEO_5$VIDEO_6$VIDEO_7
    sudo ./new_config.sh 7 0x4b $VIDEO_8$VIDEO_9$VIDEO_10$VIDEO_11
    sudo ./new_config.sh 7 0x6b $VIDEO_12$VIDEO_13$VIDEO_14$VIDEO_15
else
    sudo ./new_config.sh 2 0x4b $VIDEO_0$VIDEO_1$VIDEO_2$VIDEO_3 > /dev/null 2>&1
    sudo ./new_config.sh 2 0x6b $VIDEO_4$VIDEO_5$VIDEO_6$VIDEO_7 > /dev/null 2>&1
    sudo ./new_config.sh 7 0x4b $VIDEO_8$VIDEO_9$VIDEO_10$VIDEO_11 > /dev/null 2>&1
    sudo ./new_config.sh 7 0x6b $VIDEO_12$VIDEO_13$VIDEO_14$VIDEO_15 > /dev/null 2>&1
fi

# deskew
sudo ./deskew.sh 2 0x4b > /dev/null 2>&1
sudo ./deskew.sh 2 0x6b > /dev/null 2>&1
sudo ./deskew.sh 7 0x4b > /dev/null 2>&1
sudo ./deskew.sh 7 0x6b > /dev/null 2>&1

# start streaming video0 - video15
mkdir -p logs
TS=$(date +"%Y%m%d%H%M%S")
LOG_DIR=logs
LOG_PREFIX="$TS"_video
# ps a | grep v4l2-ctl | grep -v grep | awk '{print $1}' | xargs -n 1 kill -TERM 2> /dev/null # kill exist processes before streaming
echo "Start streaming..."
if [[ $verbose == 1 ]]; then
    [ ! $VIDEO_0 -eq 0 ] && ./v4l2_stream.sh 0 $VIDEO_0 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"0 &
    [ ! $VIDEO_1 -eq 0 ] && ./v4l2_stream.sh 1 $VIDEO_1 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"1 &
    [ ! $VIDEO_2 -eq 0 ] && ./v4l2_stream.sh 2 $VIDEO_2 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"2 &
    [ ! $VIDEO_3 -eq 0 ] && ./v4l2_stream.sh 3 $VIDEO_3 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"3 &
    [ ! $VIDEO_4 -eq 0 ] && ./v4l2_stream.sh 4 $VIDEO_4 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"4 &
    [ ! $VIDEO_5 -eq 0 ] && ./v4l2_stream.sh 5 $VIDEO_5 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"5 &
    [ ! $VIDEO_6 -eq 0 ] && ./v4l2_stream.sh 6 $VIDEO_6 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"6 &
    [ ! $VIDEO_7 -eq 0 ] && ./v4l2_stream.sh 7 $VIDEO_7 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"7 &
    [ ! $VIDEO_8 -eq 0 ] && ./v4l2_stream.sh 8 $VIDEO_8 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"8 &
    [ ! $VIDEO_9 -eq 0 ] && ./v4l2_stream.sh 9 $VIDEO_9 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"9 &
    [ ! $VIDEO_10 -eq 0 ] && ./v4l2_stream.sh 10 $VIDEO_10 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"10 &
    [ ! $VIDEO_11 -eq 0 ] && ./v4l2_stream.sh 11 $VIDEO_11 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"11 &
    [ ! $VIDEO_12 -eq 0 ] && ./v4l2_stream.sh 12 $VIDEO_12 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"12 &
    [ ! $VIDEO_13 -eq 0 ] && ./v4l2_stream.sh 13 $VIDEO_13 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"13 &
    [ ! $VIDEO_14 -eq 0 ] && ./v4l2_stream.sh 14 $VIDEO_14 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"14 &
    [ ! $VIDEO_15 -eq 0 ] && ./v4l2_stream.sh 15 $VIDEO_15 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"15 &
else
    [ ! $VIDEO_0 -eq 0 ] && ./v4l2_stream.sh 0 $VIDEO_0 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"0 > /dev/null 2>&1 &
    [ ! $VIDEO_1 -eq 0 ] && ./v4l2_stream.sh 1 $VIDEO_1 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"1 > /dev/null 2>&1 &
    [ ! $VIDEO_2 -eq 0 ] && ./v4l2_stream.sh 2 $VIDEO_2 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"2 > /dev/null 2>&1 &
    [ ! $VIDEO_3 -eq 0 ] && ./v4l2_stream.sh 3 $VIDEO_3 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"3 > /dev/null 2>&1 &
    [ ! $VIDEO_4 -eq 0 ] && ./v4l2_stream.sh 4 $VIDEO_4 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"4 > /dev/null 2>&1 &
    [ ! $VIDEO_5 -eq 0 ] && ./v4l2_stream.sh 5 $VIDEO_5 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"5 > /dev/null 2>&1 &
    [ ! $VIDEO_6 -eq 0 ] && ./v4l2_stream.sh 6 $VIDEO_6 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"6 > /dev/null 2>&1 &
    [ ! $VIDEO_7 -eq 0 ] && ./v4l2_stream.sh 7 $VIDEO_7 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"7 > /dev/null 2>&1 &
    [ ! $VIDEO_8 -eq 0 ] && ./v4l2_stream.sh 8 $VIDEO_8 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"8 > /dev/null 2>&1 &
    [ ! $VIDEO_9 -eq 0 ] && ./v4l2_stream.sh 9 $VIDEO_9 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"9 > /dev/null 2>&1 &
    [ ! $VIDEO_10 -eq 0 ] && ./v4l2_stream.sh 10 $VIDEO_10 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"10 > /dev/null 2>&1 &
    [ ! $VIDEO_11 -eq 0 ] && ./v4l2_stream.sh 11 $VIDEO_11 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"11 > /dev/null 2>&1 &
    [ ! $VIDEO_12 -eq 0 ] && ./v4l2_stream.sh 12 $VIDEO_12 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"12 > /dev/null 2>&1 &
    [ ! $VIDEO_13 -eq 0 ] && ./v4l2_stream.sh 13 $VIDEO_13 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"13 > /dev/null 2>&1 &
    [ ! $VIDEO_14 -eq 0 ] && ./v4l2_stream.sh 14 $VIDEO_14 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"14 > /dev/null 2>&1 &
    [ ! $VIDEO_15 -eq 0 ] && ./v4l2_stream.sh 15 $VIDEO_15 $STREAM_COUNT $LOG_DIR/"$LOG_PREFIX"15 > /dev/null 2>&1 &
fi

sleep_time=$((STREAM_COUNT/30))
for (( i=1; i<=$sleep_time; i++ ))
do
    echo $i/$sleep_time seconds
    sleep 1
done

# wait if all logs done
prev_ret=0
while true
do
    ./check_cam_log_done.py $LOG_DIR $LOG_PREFIX $STREAM_COUNT
    ret=$?
    if [[ $ret == 0 ]]
    then
        # all logs are done!
        break
    else
        if [[ $ret == $prev_ret ]]
        then
            # if the seq is the same as the previous, we can assume it is finished, reduce the STREAM_COUNT
            STREAM_COUNT=$ret
        fi
        echo waiting for logs...
        sleep 10
        prev_ret=$ret
    fi
done

# analyze video0 - video15 logs
echo "Start analyzing logs..."
./analyze_cam_log.py $LOG_DIR $LOG_PREFIX $DELTA_TOLERANCE

# ps a | grep v4l2-ctl | grep -v grep | awk '{print $1}' | xargs -n 1 kill -TERM 2> /dev/null # kill remain running processes after finished
echo done
