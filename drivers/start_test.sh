#!/bin/bash

STREAM_COUNT=900

if [[ $EUID -eq 0 ]]; then
	echo "Please don't use 'sudo' to run this script."
    exit 1
fi

echo Test frame count = $STREAM_COUNT

# gnome-terminal options:
# --geometry    COLUMNSxROWS+X+Y

echo "video0-3"
for ((i=0;i<=3;i++)); 
do
    X=0
    Y=$((260*$i))
    gnome-terminal  --geometry 50x10+$X+$Y --title=video$i -- bash -c '
        date -R
        bash -c "v4l2-ctl --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count='$STREAM_COUNT' -d /dev/video'$i'"
        ret=$?
        if [[ $ret -eq 0 ]]; then
            date -R
            echo ====
            echo PASS
            echo ====
        fi
        exec bash -i'
done
# echo "enter any key to continue..."
# read key

#echo "video4-7"
#for ((i=4;i<=7;i++)); 
#do
#    X=500
#    Y=$((260*($i-4)))
#    gnome-terminal  --geometry 50x10+$X+$Y --title=video$i -- bash -c '
#        date -R
#        bash -c "v4l2-ctl --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count='$STREAM_COUNT' -d /dev/video'$i'"
#        ret=$?
#        if [[ $ret -eq 0 ]]; then
#            date -R
#            echo ====
#            echo PASS
#            echo ====
#        fi
#        exec bash -i'
#done
# echo "enter any key to continue..."
# read key

echo "video8-11"
for ((i=8;i<=11;i++)); 
do
    X=1000
    Y=$((260*($i-8)))
    gnome-terminal  --geometry 50x10+$X+$Y --title=video$i -- bash -c '
        date -R
        bash -c "v4l2-ctl --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count='$STREAM_COUNT' -d /dev/video'$i'"
        ret=$?
        if [[ $ret -eq 0 ]]; then
            date -R
            echo ====
            echo PASS
            echo ====
        fi
        exec bash -i'
done
# echo "enter any key to continue..."
# read key

echo "video12-15"
for ((i=12;i<=15;i++)); 
do
    X=1500
    Y=$((260*($i-12)))
    gnome-terminal  --geometry 50x10+$X+$Y --title=video$i -- bash -c '
        date -R
        bash -c "v4l2-ctl --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count='$STREAM_COUNT' -d /dev/video'$i'"
        ret=$?
        if [[ $ret -eq 0 ]]; then
            date -R
            echo ====
            echo PASS
            echo ====
        fi
        exec bash -i'
done

echo "done"
