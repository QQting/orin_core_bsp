#!/bin/bash

STREAM_COUNT=900

if [[ $EUID -eq 0 ]]; then
	echo "Please don't use 'sudo' to run this script."
    exit 1
fi

echo Test frame count = $STREAM_COUNT

# gnome-terminal options:
# --geometry    COLUMNSxROWS+X+Y

echo "video0-2"
for ((i=0;i<=2;i++)); 
do
    X=0
    Y=$((260*$i))
    gnome-terminal  --geometry 50x10+$X+$Y --title=video$i -- bash -c '
        date -R
        bash -c "v4l2-ctl --set-ctrl bypass_mode=0 --set-fmt-video=width=2880,height=1860 --stream-mmap --stream-count='$STREAM_COUNT' -d /dev/video'$i'"
        ret=$?
        if [[ $ret -eq 0 ]]; then
            date -R
            echo ====
            echo PASS
            echo ====
        fi
        exec bash -i'
done
sudo ./deskew.sh 2 0x4b
# echo "enter any key to continue..."
# read key

#echo "video4-6"
#for ((i=4;i<=6;i++)); 
#do
#    X=500
#    Y=$((260*($i-4)))
#    gnome-terminal  --geometry 50x10+$X+$Y --title=video$i -- bash -c '
#        date -R
#        bash -c "v4l2-ctl --set-ctrl bypass_mode=0 --set-fmt-video=width=2880,height=1860 --stream-mmap --stream-count='$STREAM_COUNT' -d /dev/video'$i'"
#        ret=$?
#        if [[ $ret -eq 0 ]]; then
#            date -R
#            echo ====
#            echo PASS
#            echo ====
#        fi
#        exec bash -i'
#done
sudo ./deskew.sh 2 0x6b
# echo "enter any key to continue..."
# read key

echo "video8-10"
for ((i=8;i<=10;i++)); 
do
    X=1000
    Y=$((260*($i-8)))
    gnome-terminal  --geometry 50x10+$X+$Y --title=video$i -- bash -c '
        date -R
        bash -c "v4l2-ctl --set-ctrl bypass_mode=0 --set-fmt-video=width=2880,height=1860 --stream-mmap --stream-count='$STREAM_COUNT' -d /dev/video'$i'"
        ret=$?
        if [[ $ret -eq 0 ]]; then
            date -R
            echo ====
            echo PASS
            echo ====
        fi
        exec bash -i'
done
sudo ./deskew.sh 7 0x4b
# echo "enter any key to continue..."
# read key

echo "video12-14"
for ((i=12;i<=14;i++)); 
do
    X=1500
    Y=$((260*($i-12)))
    gnome-terminal  --geometry 50x10+$X+$Y --title=video$i -- bash -c '
        date -R
        bash -c "v4l2-ctl --set-ctrl bypass_mode=0 --set-fmt-video=width=2880,height=1860 --stream-mmap --stream-count='$STREAM_COUNT' -d /dev/video'$i'"
        ret=$?
        if [[ $ret -eq 0 ]]; then
            date -R
            echo ====
            echo PASS
            echo ====
        fi
        exec bash -i'
done
sudo ./deskew.sh 7 0x6b

echo "done"
