<!-- START doctoc.sh generated TOC please keep comment here to allow auto update -->
<!-- DO NOT EDIT THIS SECTION, INSTEAD RE-RUN doctoc.sh TO UPDATE -->
**Table of Contents**

- [Workbench for PXE](#workbench-for-pxe)
  - [0. Expected topology and requirements](#0-expected-topology-and-requirements)
  - [1. The TFTP service](#1-the-tftp-service)
    - [1.1. Preparing the TFTP directory](#11-preparing-the-tftp-directory)
      - [Steps](#steps)
    - [1.2. Installing dnsmasq, the TFTP service](#12-installing-dnsmasq-the-tftp-service)
      - [Steps](#steps-1)
    - [1.3. Fix DNS resolution for dnsmasq host](#13-fix-dns-resolution-for-dnsmasq-host)
  - [2. The NFS service](#2-the-nfs-service)
    - [2.1. Preparing the NFS directory](#21-preparing-the-nfs-directory)
      - [Steps](#steps-2)
    - [2.2. Installing the NFS service](#22-installing-the-nfs-service)
      - [Steps](#steps-3)
  - [3. Test the PXE service on a PC client](#3-test-the-pxe-service-on-a-pc-client)

<!-- END doctoc.sh generated TOC please keep comment here to allow auto update -->

# Workbench for PXE

This guide helps you to setup PXE configuration for workbench, it is expected to be installed on Debian 10, in case of using another system, adapt accordinly.

## 0. Expected topology and requirements

Note: This guide uses as an example network and hosts on 192.168.1.0/24, change accordingly to your setup:

- a Router does the function of DHCP server, let's say 192.168.1.1
- a Client connects through DHCP mecanism, it takes an IP from the range 192.168.1.0/24
  - client is expected to have internet connection to send the report to a remote server
- a Server does TFTP server (PXE boot mechanism) and NFS server (serves the image) with static IP or DHCP static lease, in this example, IP 192.168.1.99
  

## 1. The TFTP service

### 1.1. Preparing the TFTP directory

A TFTP server is going to serve files in path `/tftpboot`, we are going to use the files from the tftpboot directory [from this link](https://nextcloud.pangea.org/index.php/s/SMeZXp6p37cm8SE)

The tftp folder contains mainly two files extracted from the [debian installer netboot](http://ftp.debian.org/debian/dists/stretch/main/installer-amd64/current/images/netboot/netboot.tar.gz). The [pxelinux.0](http://ftp.debian.org/debian/dists/stretch/main/installer-amd64/current/images/netboot/debian-installer/amd64/pxelinux.0) file and the [ldlinux.c32](http://ftp.debian.org/debian/dists/stretch/main/installer-amd64/current/images/netboot/debian-installer/amd64/boot-screens/ldlinux.c32) file are essential for PXE booting, along with the *default* file that we are going to create inside the pxelinux.cfg folder.

#### Steps

1. Unzip [WB_PXE_v1.zip](https://nextcloud.pangea.org/index.php/s/SMeZXp6p37cm8SE) file and copy contents of tftpboot folder into  `/tftpboot` directory:

```
sudo cp -r /path/to/WB_PXE.zip/tftpboot /
```

2. Create a new file `/tftpboot/pxelinux.cfg/default` and should looks like this (remember to change 192.168.1.99 with your host ip for TFTP/NFS server):

```
default wb

label wb
        KERNEL vmlinuz
        INITRD initrd.img
        APPEND ip=dhcp netboot=nfs nfsroot=192.168.1.99:/wbpxe/images/ boot=live text forcepae
```

3. Before starting the next section, check that we have a file structure as follows in `/tftpboot` folder:

```
/tftpboot/
├── initrd.img
├── ldlinux.c32
├── pxelinux.0
├── pxelinux.cfg
│   └── default
└── vmlinuz
```

### 1.2. Installing dnsmasq, the TFTP service

[Dnsmasq](https://en.wikipedia.org/wiki/Dnsmasq) software was selected because it supports proxy DHCP mechanism. That allows adding the TFTP feature without touching how the network works

#### Steps

1. Install dnsmasq on TFTP/NFS host:

```
sudo apt install dnsmasq -y
```

2. Save the current dnsmasq config if you want or override it:

```
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
```

3. Create or modify file `/etc/dnsmasq.conf` to look like this (remember to change 192.168.1.0 with your network needs):

```
# Disables the DNS Service
port=0
# Logs DHCP traffic, enable this for debugging purposes
#log-dhcp
# The network range that we want to listen to DHCP requests on. The proxy
#   options ensures we only send DHCP options and not the main IP address and
#   mask. This is used so we can interoperate with and existing DHCP Server on
#   the network
dhcp-range=192.168.1.0,proxy
# Set the DHCP Option for the boot filename used as the network bootstrap file
dhcp-boot=pxelinux.0
# Here we set the 2nd DHCP Option we deliver to DHCP
#   clients and specify this is for our bios based systems, x86PC, a boot message
#   and the name of the bootstrap file omitting the .0 from the end of the name.
pxe-service=x86PC,'Network Boot',pxelinux
# We need the TFTP server to deliver files after the bootstrap files has been
#   delivered by PXELinux using Proxy DHCP.
enable-tftp
# We set the path to the root directory that will be used by the TFTP Server
tftp-root=/tftpboot
```

4. Restart the service to apply the new configuration:

```
sudo systemctl restart dnsmasq.service
```

5. To check that the dnsmasq service has started correctly, run:
   
```
sudo systemctl status dnsmasq.service
```

### 1.3. Fix DNS resolution for dnsmasq host

When DNSMASQ was installed the resolv.conf will point to the localhost for DNS name resolution. This will be fine if we leave the DNS Server running but we want to disable it, as we have set with the *port=0* setting in the dnsmasq.conf.

To ensure that when using PXELinux with Proxy DHCP we do not need DNS we must reconfigure DNSMASQ to ignore the local interface. This is set in the file */etc/default/dnsmasq*. And we need to add a line to this file:

```
IGNORE_RESOLVCONF=yes
```

## 2. The NFS service

### 2.1. Preparing the NFS directory

We are going to create some folders to be mounted and shared with the client PC using NFS.

#### Steps

1. Create folders as necessary:
```
sudo mkdir -p /wbpxe/images/live
```

2. Unzip [WB_PXE_v1.zip](https://nextcloud.pangea.org/index.php/s/SMeZXp6p37cm8SE) file and copy contents of wbpxe folder into  `/wbpxe` directory:

```
sudo cp -r /path/to/WB_PXE.zip/wbpxe /
```

3. Before starting the next section, check that we have a file structure as follows in `/wbpxe` folder:

```
/wbpxe/
└── images
    └── live
        └── filesystem.squashfs
```

### 2.2. Installing the NFS service

#### Steps

1. Install NFS server on TFTP/NFS host:

```
sudo apt install nfs-kernel-server -y
```

2. Modify file `/etc/exports` to look like (remember to change network accordingly to your setup):

```
/wbpxe/images/ 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
```

3. Reload NFS service to load new configuration:

```
exportfs -arv
```

4. To check that the nfs-server service has started correctly, run:
   
```
sudo systemctl status nfs-server.service
```

## 3. Test the PXE service on a PC client

Load a PC client with PXE boot mode, after loading the entire system it should end with 'Workbench has finished properly' on PC client screen. Also a URL must also appear, in this link you can view the information collected by the Workbench from the client PC.

### 3.1 Execute a different WB image

In case you want to run a different Workbench image, you will need to change the `filesystem.squashfs` file inside the path `/wbpxe/images/live/` and rerun PC client with PXE boot mode.