#!/usr/bin/env bash

set -e
set -o pipefail

read -p 'Add an USB and press ENTER'
sudo mkdir /media/usb || true
mount /dev/sdb1 /media/usb
sudo lshw -json | sudo tee /media/usb/$(date).json
umount /media/usb
echo 'Done. Generated LSHW file and copied to USB. Remove the USB.'