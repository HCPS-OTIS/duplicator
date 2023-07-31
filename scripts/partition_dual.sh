#!/usr/bin/env bash
# creates two partitions for fat32/ntfs drives
# usage: $0 <fat32 size in MB> <list of block devices>

parallel -i bash -c "parted --script {} -- \
            mktable msdos \
            mkpart primary fat32 2048s "$1"MB \
            mkpart primary ntfs "$1"MB -1s" -- ${@:2}
