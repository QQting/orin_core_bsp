#!/bin/bash

echo "video0-3"
gnome-terminal --  v4l2-ctl  --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count=0 -d /dev/video0

gnome-terminal --  v4l2-ctl  --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count=0 -d /dev/video1

gnome-terminal --  v4l2-ctl  --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count=0 -d /dev/video2

gnome-terminal --  v4l2-ctl  --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count=0 -d /dev/video3

echo "pause"
read key

echo "video4-7"
gnome-terminal --  v4l2-ctl  --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count=0 -d /dev/video4

gnome-terminal --  v4l2-ctl  --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count=0 -d /dev/video5

gnome-terminal --  v4l2-ctl  --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count=0 -d /dev/video6

gnome-terminal --  v4l2-ctl  --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count=0 -d /dev/video7

echo "pause"
read key

echo "video8-11"
gnome-terminal --  v4l2-ctl  --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count=0 -d /dev/video8

gnome-terminal --  v4l2-ctl  --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count=0 -d /dev/video9

gnome-terminal --  v4l2-ctl  --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count=0 -d /dev/video10

gnome-terminal --  v4l2-ctl  --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count=0 -d /dev/video11

echo "pause"
read key

echo "video12-15"
gnome-terminal --  v4l2-ctl  --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count=0 -d /dev/video12

gnome-terminal --  v4l2-ctl  --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count=0 -d /dev/video13

gnome-terminal --  v4l2-ctl  --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count=0 -d /dev/video14

gnome-terminal --  v4l2-ctl  --set-ctrl bypass_mode=0 --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count=0 -d /dev/video15
