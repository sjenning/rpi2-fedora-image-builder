# Fedora Image Builder for Raspberry Pi 2

This is a script that transforms the official Fedora armhfp images into a disk image that is bootable by the Raspberry Pi 2.

## Usage

By default, mkimage.sh will create a Fedora minimal image with a 50MB boot filesystem and a 900MB root filesystem.  If you wish to change these defaults, create a ```settings.conf``` file using ```settings.conf.example``` as a template.

```bash
IMAGEURL="http://mirror.pnl.gov/fedora/linux/releases/21/Images/armhfp/Fedora-Minimal-armhfp-21-5-sda.raw.xz"
# size in MB
BOOTSIZE=50
ROOTSIZE=900
```

Then simply run the script as root (root privileges are needed to mount filesystem images as loop block devices)

```bash
sudo ./mkimage
```

The script
* Downloads the official image from IMAGEURL
* Decompresses the official image
* Strips the root filesystem image out of the official image (root.img)
* Creates a vfat boot partition image (boot.img) of size BOOTSIZE
* Clones the raspberrypi/firmware repository from Github
* Copies the boot files into the boot filesystem
* Resizes the root filesystem to ROOTSIZE
* Copies the kernel modules into the root filesystem
* Generates an /etc/fstab
* Creates a disk image file, partitions it, and copies the boot and root filesystem images into the created partitions

NOTE: This will take a considerable amount of disk space and time depending on your disk and internet speeds.  If default settings are used, the disk space requirement is 4.4GB.

To remove all temporary resources needed for building, use the ```clean.sh``` script

### fbturbo

The fbturbo driver (https://github.com/ssvb/xf86-video-fbturbo) allows for basic 2D hardware acceleration using the VideoCore GPU.  This improves performance for things like window drawing.  To have the driver included in the final image, copy these files from the ```sample-resources``` into the ```resources``` directory

```cp sample-resources/xorg.conf sample-resources/fbturbo_drv.so resources```

### config.txt

You can add your custom **config.txt** to the ```resources``` directory and it will be included in the boot filesystem of the final image

