#!/bin/bash
set -e
set -o pipefail

# 1 - SET UP THE ENVIRONMENT

## Global vars
## Change ISO_FILE with your WB ISO name
SCRIPT_DIR="$( cd "$(dirname "$0")" ; pwd -P )" # from https://stackoverflow.com/a/4774063
TMP_DIR=${SCRIPT_DIR}'/new-iso-files'
ISO_FILE='UsodyRate-Original.iso'
ISO_PATH=${SCRIPT_DIR}'/'${ISO_FILE}

## Preparing dirs and files
mkdir -p ${TMP_DIR} 

## Installing dependecies
sudo apt-get install squashfs-tools xorriso -y


# 2 - EXTRACT ISO IMAGE AND SQUASHFS FILE

## Extract all files from the ISO with:
xorriso -osirrox on -indev ${ISO_FILE} -extract / ${TMP_DIR}

## Open and extract squashfs file
sudo unsquashfs ${TMP_DIR}/live/filesystem.squashfs


# 3 - MODIFY AND SAVE ISO DATA

## Modify workbench user data of live ISO
sudo nano ./squashfs-root/home/user/.profile

## Save change on compress file squashfs
sudo mksquashfs squashfs-root/ ${TMP_DIR}/live/filesystem.squashfs -b 1048576 -comp xz -Xdict-size 100% -noappend


# 4 - BUILD MODIFIED ISO IMAGE

## Rebuild ISO with data changes
xorriso -as mkisofs -o ${SCRIPT_DIR}'/custom-'${ISO_FILE} \
        -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
        -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot \
        -boot-load-size 4 -boot-info-table ${TMP_DIR}


# 5 - CLEAN TMP DATA

## Idempotent
sudo rm -rf squashfs-root
sudo rm -rf ${TMP_DIR}


# 6 - TEST NEW CUSTOM ISO

## Testing cutom ISO with QEMU
sudo apt install qemu -y
qemu-system-x86_64 -cdrom ${SCRIPT_DIR}'/custom-'${ISO_FILE} &

echo "Script Finished!!" 
