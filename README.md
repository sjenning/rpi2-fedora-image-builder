# Fedora Image Builder for Raspberry Pi 2

This is a script that transforms the official Fedora armhfp images into a disk image that is bootable by the Raspberry Pi 2.

## Usage

Adjust the following variables to suit your case

```bash
IMAGEFILE="Fedora-Minimal-armhfp-21-5-sda.raw"
# size in MB
BOOTSIZE=50
ROOTSIZE=900
```

Then simply run the script as root

```bash
sudo ./mkimage
```

The script
* Downloads the official IMAGEFILE image from a Fedora mirror
* Decompresses the official image
* Strips the root filesystem image out of the official image (root.img)
* Creates a vfat boot partition image (boot.img) of size BOOTSIZE
* Clones the raspberrypi/firmware repository from Github
* Copies the boot files into the boot filesystem
* Resizes the root filesystem to ROOTSIZE
* Copies the kernel modules into the root filesystem
* Generates an /etc/fstab
* Creates a disk image file, partitions it, and copies the boot and root filesystem images into the created partitions

NOTE: This will take a considerable amount of disk space and time depending on your disk and internet speeds.  If the variables are unchanged, the disk space requirement is 4.4GB.

