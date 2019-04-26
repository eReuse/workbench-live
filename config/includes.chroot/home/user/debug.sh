#!/usr/bin/env bash

set -e
set -o pipefail
DATE = $(date)

read -p 'Add an USB and press ENTER'
sudo mkdir /media/usb || true
mount /dev/sdb1 /media/usb
sudo bash /opt/workbench/tests/fixtures.sh
sudo mkdir -p /media/usb/${DATE}
sudo cp device.* /media/usb/${DATE}
umount /media/usb
echo 'Done. Generated LSHW file and copied to USB. Remove the USB.'
