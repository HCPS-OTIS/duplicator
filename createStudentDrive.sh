#!/usr/bin/env bash

# umount drive
sudo umount /dev/sda*

# exit if error
set -e

# create partitions/filesystems
parted --script /dev/sda -- \
    mktable msdos \
    mkpart primary fat32 2048s 2000MB \
    mkpart primary ntfs 2000MB -1s
echo Partitions created.

mkfs.vfat -n BOOT /dev/sda1
mkfs.ntfs -f -L IMAGES /dev/sda2
echo Filesystems created.

# create mountpoints and mount partitions
mkdir -p /mnt/drive_boot
mkdir -p /mnt/drive_images
mount /dev/sda1 /mnt/drive_boot
mount /dev/sda2 /mnt/drive_images
echo Partitions mounted.

# copy files onto drive
rsync -r --info=progress2 --no-i-r "$(dirname $0)/boot/" "/mnt/drive_boot/"
rsync -r --info=progress2 --no-i-r "$(dirname $0)/images/" "/mnt/drive_images/"
echo Files copied.

# unmount drive
umount /mnt/drive_boot
umount /mnt/drive_images
echo Drive unmounted.

echo Drive created successfully!