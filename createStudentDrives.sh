#!/usr/bin/env bash

# umount drive
umount /dev/sd*

# exit if error
set -e

# iterate through all /dev/sd* drives but not partitions
for DRIVE in /dev/sd*; do #parallel
    if [[ ! $DRIVE =~ [0-9] ]]; then
        # create partitions/filesystems
        parted --script $DRIVE -- \
            mktable msdos \
            mkpart primary fat32 2048s 2000MB \
            mkpart primary ntfs 2000MB -1s
        echo "Partitions created on "$DRIVE"."

        mkfs.vfat -n BOOT $DRIVE'1'
        mkfs.ntfs -f -L DATA $DRIVE'2'
        echo "Filesystems created on "$DRIVE"."
    fi
done

# partimage FAT32 partitions
for DRIVE in /dev/sd*; do
    if [[ ! $DRIVE =~ [0-9] ]]; then
        partimage -b restore $DRIVE'1' $(dirname $0)/boot.partimg.000 #parallel
        echo "Boot partition populated on "$DRIVE"."
    fi
done

# create mountpoints and mount data partitions
for DRIVE in /dev/sd*; do
    if [[ ! $DRIVE =~ [0-9] ]]; then
        LETTER=${DRIVE:7:1}
        mkdir -p '/mnt/sd'$LETTER'_data'
        mount $DRIVE'2' '/mnt/sd'$LETTER'_data'
        echo "Mounted "$DRIVE"2."
    fi
done

# create directory structure on drives
for DRIVE in /mnt/sd*; do
    find $(dirname $0)/images/ -type d | sed "s|^.*images/*|"$DRIVE"/|" | xargs --replace=% mkdir -p "%"
done
echo "Directories created."

# copy files onto drive
IFS=$'\n'
for FILE in $(find $(dirname $0)/images/ -type f); do
    FILE=$(echo $FILE | sed "s|^.*images/*||")
    echo Copying file: $FILE
    cat $(dirname $0)/images/$FILE | eval "tee /mnt/sd{a..$LETTER}_data/\"$FILE\"" > /dev/null
done
echo "Files copied."

# unmount drive
for MOUNTPOINT in /mnt/sd*_data; do
    umount $MOUNTPOINT #parallel
done
echo "All drives unmounted."

echo "All drives created successfully."