#!/bin/bash

if [[ ${EUID} -ne 0 ]]; then
  echo "this script must be executed with elevated privileges"
  exit 1
fi

iso=$1
dev=$2
## from https://stackoverflow.com/a/4774063
scriptdir="$( cd "$(dirname "$0")" ; pwd -P )"

if [[ -z "${iso}" || ! -f ${iso} || ! -s ${iso} ]]; then
  echo "parameter 1 must be source ISO image"
  exit 1
fi

if [[ -z "${dev}" || ! -b ${dev} ]]; then
  echo "param 2 must be target block device"
  exit 1
fi

if [[ "${dev}" =~ ^.*[0-9]$ ]]; then
  echo "target block device should be device, not a partition (must not end with digit)"
  exit 1
fi

echo "unmounting old partitions"
umount ${dev}*

lsblk ${dev}
echo "this will destroy data on ${dev}. abort now if unsure!"
read

echo "creating partitions"
parted ${dev} --script mktable gpt
parted ${dev} --script mkpart EFI fat16 1MiB 10MiB
parted ${dev} --script mkpart live fat16 10MiB 3GiB
parted ${dev} --script mkpart persistence ext4 3GiB 100%
parted ${dev} --script set 1 msftdata on
parted ${dev} --script set 2 legacy_boot on
parted ${dev} --script set 2 msftdata on

echo "syncing and probing new paritions"
sync
partprobe

echo "creating file systems"
mkfs.vfat -n EFI ${dev}1
mkfs.vfat -n LIVE ${dev}2
mkfs.ext4 -F -L persistence ${dev}3

echo "creating temporary mount locations"
tmp=$(mktemp --tmpdir --directory debianlive.XXXXX)
tmpefi=${tmp}/efi
tmplive=${tmp}/live
tmppersistence=${tmp}/persistence
tmpiso=${tmp}/iso
tmpall="${tmpefi} ${tmplive} ${tmppersistence} ${tmpiso}"

echo "mounting resources"
mkdir ${tmpall}
mount ${dev}1 ${tmpefi}
mount ${dev}2 ${tmplive}
mount ${dev}3 ${tmppersistence}
mount -oro ${iso} ${tmpiso}

echo "copying iso image filesystem contents"
cp -ar ${tmpiso}/* ${tmplive}
sync

echo "creating persistence.conf"
echo "/ union" > ${tmppersistence}/persistence.conf

echo "installing grub"
grub-install --no-uefi-secure-boot --removable --target=x86_64-efi --boot-directory=${tmplive}/boot/ --efi-directory=${tmpefi} ${dev}

echo "installing syslinux"
dd bs=440 count=1 conv=notrunc if=/usr/lib/syslinux/mbr/gptmbr.bin of=${dev}
syslinux --install ${dev}2

echo "fixing isolinux folder/files"
mv ${tmplive}/isolinux ${tmplive}/syslinux
mv ${tmplive}/syslinux/isolinux.bin ${tmplive}/syslinux/syslinux.bin
mv ${tmplive}/syslinux/isolinux.cfg ${tmplive}/syslinux/syslinux.cfg

echo "fixing grub splash screen"
sed --in-place 's#isolinux/splash#syslinux/splash#' ${tmplive}/boot/grub/grub.cfg

echo "configuring persistence kernel parameter"
sed --in-place '0,/boot=live/{s/\(boot=live .*\)$/\1 persistence/}' ${tmplive}/boot/grub/grub.cfg ${tmplive}/syslinux/menu.cfg

## Configuration of Workbench settings on persistence partition
echo "configuring workbench settings on persistence partition"
sudo mkdir -pv ${tmppersistence}'/rw/home/user/wb/'
sudo cp ${scriptdir}'/settings.ini' ${tmppersistence}'/rw/home/user/wb/'

echo "cleaning up"
umount ${tmpall}
rmdir ${tmpall} ${tmp}

echo "sync'ing so that cached writes to USB stick are written"
sync

echo "WB USB stick is ready"