#!/bin/bash


if [[ $# == 0 ]]; then
	echo "Please enter video index [0-15]"
	exit
fi

if [[ 0 -le $1 && $1 -le 3 ]]; then
	sudo ./deskew.sh 2 0x4b
fi

if [[ 4 -le $1 && $1 -le 7 ]]; then
	sudo ./deskew.sh 2 0x6b
fi

if [[ 8 -le $1 && $1 -le 11 ]]; then
	sudo ./deskew.sh 7 0x4b
fi

if [[ 12 -le $1 && $1 -le 15 ]]; then
	sudo ./deskew.sh 7 0x6b
fi
