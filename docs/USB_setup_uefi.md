<!-- START doctoc.sh generated TOC please keep comment here to allow auto update -->
<!-- DO NOT EDIT THIS SECTION, INSTEAD RE-RUN doctoc.sh TO UPDATE -->
**Table of Contents**

- [Workbench for USB](#workbench-for-usb)
  - [0. Prerequisites](#0-prerequisites)
  - [1. Preparing the WB USB flash drive](#1-preparing-the-wb-usb-flash-drive)
    - [1.1. Steps](#11-steps)
  - [2. Building the WB USB flash drive](#2-building-the-wb-usb-flash-drive)
    - [2.1. Steps](#21-steps)
  - [3. Test the Workbench USB on a PC client](#3-test-the-workbench-usb-on-a-pc-client)

<!-- END doctoc.sh generated TOC please keep comment here to allow auto update -->

# Workbench for USB

This guide helps you to setup USB configuration for workbench, it is expected to be installed on USB flash drive.

## 0. Prerequisites

Note: Before we start we need to make sure that we have:

- a USB flash drive of at least 4 GB.
- a WB ISO file.
- (opt) a private DH account with your Workbench settings file (settings.ini).

## 1. Preparing the WB USB flash drive

We will now proceed with all the preparations to get a working USB WB with UEFI boot.

We are going to use following files:
- WB ISO file [from this link](https://nextcloud.pangea.org/index.php/s/ozDRFCAR2AeCDGw)
- [build script](https://raw.githubusercontent.com/eReuse/workbench-live/d5941bdae1f6316be7e659521e0b5001f54b23ce/scripts/buildWBUSB-UEFI.sh)
- settings.ini file, e.i. [settings example hello user](https://nextcloud.pangea.org/index.php/s/ksnD5yPnnKsnxax)

### 1.1. Steps

1. We need to have a directory with the following files to build the USB:

```
working-dir/
├── buildWBUSB-UEFI.sh
├── settings.ini
└── WBUSBv1-UEFI.iso
```

2. Review content of `working-dir/settings.ini` file.


## 2. Building the WB USB flash drive

### 2.1. Steps

1. Execute build script, where sdX is your usb device name:

```
sudo bash ./buildWBUSB-UEFI.sh  WBUSBv1-UEFI.iso  /dev/sdX
```

2. Answer yes to confirmations 
   
3. Wait for the script to finish successfully.

## 3. Test the Workbench USB on a PC client

Load a PC client from USB, after loading the entire system it should end with 'Workbench has finished properly' on PC client screen. Also a URL must also appear, in this link you can view the information collected by the Workbench from the client PC.


