#!/bin/bash

PAUSE=0
if [ $1 ]; then
    PAUSE=$1
fi

echo "video0-3"
gnome-terminal --title="video0" -- v4l2-ctl --set-fmt-video=width=2880,height=1860 --stream-mmap --stream-count=0 -d /dev/video0
gnome-terminal --title="video1" -- v4l2-ctl --set-fmt-video=width=2880,height=1860 --stream-mmap --stream-count=0 -d /dev/video1
gnome-terminal --title="video2" -- v4l2-ctl --set-fmt-video=width=2880,height=1860 --stream-mmap --stream-count=0 -d /dev/video2

if [ $PAUSE -eq 1 ]; then
	echo "pause"
	read key
fi

echo "video4-7"
gnome-terminal --title="video4" -- v4l2-ctl --set-fmt-video=width=2880,height=1860 --stream-mmap --stream-count=0 -d /dev/video4
gnome-terminal --title="video5" -- v4l2-ctl --set-fmt-video=width=2880,height=1860 --stream-mmap --stream-count=0 -d /dev/video5
gnome-terminal --title="video6" -- v4l2-ctl --set-fmt-video=width=2880,height=1860 --stream-mmap --stream-count=0 -d /dev/video6

if [ $PAUSE -eq 1 ]; then
        echo "pause"
        read key
fi

echo "video8-11"
gnome-terminal --title="video8" -- v4l2-ctl --set-fmt-video=width=3840,height=2160 --stream-mmap --stream-count=0 -d /dev/video8
gnome-terminal --title="video10" -- v4l2-ctl --set-fmt-video=width=3840,height=2160 --stream-mmap --stream-count=0 -d /dev/video10

if [ $PAUSE -eq 1 ]; then
        echo "pause"
        read key
fi

echo "video12-15"
gnome-terminal --title="video12" -- v4l2-ctl --set-fmt-video=width=3840,height=2160 --stream-mmap --stream-count=0 -d /dev/video12
gnome-terminal --title="video14" -- v4l2-ctl --set-fmt-video=width=3840,height=2160 --stream-mmap --stream-count=0 -d /dev/video14
