#!/usr/bin/env bash

PWD_SAVE=`pwd`

BLUE='\033[0;36m'
NC='\033[0m' # No Color
TIME_START=$(date +%s)
echo -e "${BLUE}Starting script at ${TIME_START}.${NC}"

# umount drives
parallel umount -- /dev/sd??*

# exit if error
set -e

# iterate through all /dev/sd* drives but not partitions
parallel -i bash -c "parted --script {} -- \
            mktable msdos \
            mkpart primary fat32 2048s 2000MB \
            mkpart primary ntfs 2000MB -1s" -- /dev/sd?
parallel mkfs.vfat -n BOOT -- /dev/sd?1
parallel mkfs.ntfs -f -L DATA -- /dev/sd?2
echo -e "${BLUE}Partitions and filesystems created in $(date -d"@$(($(date +%s)-TIME_START))" +%M:%S).${NC}"

# partimage FAT32 partitions
parallel -i partimage -B= restore {} $(dirname $0)/boot.partimg.000 -- /dev/sd?1
echo -e "${BLUE}Imaged BOOT partitions in $(date -d"@$(($(date +%s)-TIME_START))" +%M:%S).${NC}"

# create mountpoints and mount data partitions
parallel -i mkdir -p /mnt{} -- /dev/sd?2
parallel -i mount {} /mnt{} -- /dev/sd?2
echo -e "${BLUE}Mounted drives in $(date -d"@$(($(date +%s)-TIME_START))" +%M:%S).${NC}"

# create directory structure on drives
cd $(dirname $0)/images
IFS=$'\n'
for DIR in $(find * -type d) $(find .* -type d); do
    parallel -i mkdir -p {}/$DIR -- /mnt/dev/sd?2
done
echo -e "${BLUE}Directories created in $(date -d"@$(($(date +%s)-TIME_START))" +%M:%S).${NC}"

# copy files onto drive
LETTER=$(ls -1 /mnt/dev/ | tail -c 3 | head -c 1)
for FILE in $(find * -type f) $(find .* -type f); do
    echo Copying file: $FILE
    cat $FILE | eval "tee /mnt/dev/sd{a..$LETTER}2/\"$FILE\"" > /dev/null
done
echo -e "${BLUE}Files copied in $(date -d"@$(($(date +%s)-TIME_START))" +%M:%S), syncing drives...${NC}"

# unmount drive
parallel umount -- /dev/sd??*
parallel rmdir -- /mnt/dev/sd?2
echo -e "${BLUE}All drives unmounted.${NC}"

cd $PWD_SAVE

echo -e "${BLUE}All drives created successfully in $(date -d"@$(($(date +%s)-TIME_START))" +%M:%S).${NC}"