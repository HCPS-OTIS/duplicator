#!/usr/bin/env bash
# creates ntfs filesystems
# usage: $0 <list of partitions>

parallel mkfs.ntfs -f -L DATA -- ${@:1}
