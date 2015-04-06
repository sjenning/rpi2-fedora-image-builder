#!/bin/bash

cd "$RESOURCEDIR"
if [[ -d firmware ]]; then
	echo "Updating firmware repo..."
	cd firmware || exit 1
	git pull > /dev/null || exit 1
else
	echo "Cloning firmware repo..."
	git clone https://github.com/raspberrypi/firmware.git --depth 1 || exit 1
fi
echo "Copying boot files..."
sudo cp -Rf $RESOURCEDIR/firmware/boot/* $MNTDIR/. || exit 1
