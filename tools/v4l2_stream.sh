#!/bin/bash

# $1 => video index
# $2 => camera type
# $3 => stream count
# $4 => LOG_NAME

case $2 in
    3)
        v4l2-ctl --set-fmt-video=width=1920,height=1536 --stream-mmap --stream-count=$3 -d /dev/video$1 --verbose 2> $4
    ;;
    5)
        v4l2-ctl --set-fmt-video=width=2880,height=1860 --stream-mmap --stream-count=$3 -d /dev/video$1 --verbose 2> $4
    ;;
    8)
        v4l2-ctl --set-fmt-video=width=3840,height=2160 --stream-mmap --stream-count=$3 -d /dev/video$1 --verbose 2> $4
    ;;
    *)
        # else, do nothing
        sleep 0
    ;;
esac


