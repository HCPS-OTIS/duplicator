#!/usr/bin/env bash
# umounts partitions
# usage: $0 <list of partitions>

parallel umount -- ${@:1}