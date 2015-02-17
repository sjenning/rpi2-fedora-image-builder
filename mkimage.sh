#!/bin/bash

#set -x

IMAGEFILE="Fedora-Minimal-armhfp-21-5-sda.raw"
# size in MB
BOOTSIZE=50
ROOTSIZE=900
IMAGESIZE=$((BOOTSIZE + ROOTSIZE + 1))

COMPRESS=0

rm -f root.img boot.img $IMAGEFILE.img
if [[ $(id -u) -ne 0 ]]; then
	echo "You need to be root"
	exit 1
fi

if [[ ! -f $IMAGEFILE.xz ]]; then
	echo "Downloading image..."
	wget http://mirror.pnl.gov/fedora/linux/releases/21/Images/armhfp/$IMAGEFILE.xz || exit 1
fi
if [[ ! -f $IMAGEFILE ]]; then
	echo "Extracting image..."
	xzdec $IMAGEFILE.xz > $IMAGEFILE || exit 1
fi

ROOTOFFSET=$(partx $IMAGEFILE | tail -n 1 | awk '{print $2}')
echo "Extracting rootfs..."
dd if=$IMAGEFILE bs=512 skip=$ROOTOFFSET of=root.img &> /dev/null || exit 1

BOOTSIZE_MB="$BOOTSIZE"M
ROOTSIZE_MB="$ROOTSIZE"M
IMAGESIZE_MB="$IMAGESIZE"M

# create boot partition
echo "Creating bootfs..."
truncate -s $BOOTSIZE_MB boot.img || exit 1
mkfs.vfat boot.img > /dev/null || exit 1
[[ -d tmp ]] || mkdir tmp || exit 1
mount boot.img tmp || exit 1
if [[ -d firmware ]]; then
	echo "Updating firmware repo..."
	cd firmware || exit 1
	git pull > /dev/null || exit 1
	cd ..
else
	echo "Cloning firmware repo..."
	git clone https://github.com/raspberrypi/firmware.git --depth 1 || exit 1
fi
echo "Copying boot files..."
cp -R firmware/boot/* tmp/. || exit 1
if [[ $COMPRESS -ne 0 ]]; then
	# create large zero file for higher image compression
	echo "Zeroing remaining space..."
	dd if=/dev/zero of=tmp/zeroes &> /dev/null
	rm -f tmp/zeroes
fi
umount tmp || exit 1

# prepare root partition
echo "Preparing root partition..."
e2fsck -fp root.img >/dev/null || exit 1
resize2fs root.img $ROOTSIZE_MB &> /dev/null || exit 1
truncate -s $ROOTSIZE_MB root.img || exit 1
mount root.img tmp || exit 1
rm -Rf tmp/lib/modules/*
echo "Copying kernel modules..."
cp -R firmware/modules/*-v7+ tmp/lib/modules/. || exit 1

echo "Creating fstab..."
blkid -o export root.img > uuid
. uuid
ROOTUUID=$UUID
rm -f uuid
cat << EOF > tmp/etc/fstab
UUID=$ROOTUUID / ext4 defaults,noatime 0 0
/dev/mmcblk0p1 /boot vfat defaults 0 0
EOF

if [[ $COMPRESS -ne 0 ]]; then
	# create large zero file for higher image compression
	echo "Zeroing remaining space..."
	dd if=/dev/zero of=tmp/zeroes &> /dev/null
	rm -f tmp/zeroes
fi
umount tmp

# create image
echo "Creating image..."
truncate -s $IMAGESIZE_MB $IMAGEFILE.img || exit 1
cat << EOF | fdisk $IMAGEFILE.img &> /dev/null

n
p
1

+$BOOTSIZE_MB
t
c
n
p
2


w
EOF

BOOTOFFSET=$(partx $IMAGEFILE.img | tail -n 2 | head -n 1 | awk '{print $2}')
dd if=boot.img of=$IMAGEFILE.img obs=512 seek=$BOOTOFFSET &> /dev/null || exit 1
ROOTOFFSET=$(partx $IMAGEFILE.img | tail -n 1 | awk '{print $2}')
dd if=root.img of=$IMAGEFILE.img obs=512 seek=$ROOTOFFSET &> /dev/null || exit 1

if [[ $COMPRESS -ne 0 ]]; then
	echo "Compressing final image (might take a while)..."
	xz $IMAGEFILE.img || exit 1
fi

echo "$IMAGEFILE.img created successfully."

