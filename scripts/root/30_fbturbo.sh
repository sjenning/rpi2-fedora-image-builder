#!/bin/bash

[[ -e "$RESOURCEDIR/fbturbo_drv.so" ]] && [[ -e "$RESOURCEDIR/xorg.conf" ]] || exit 0
echo "Copying X11 fbturbo driver..."
sudo cp -f "$RESOURCEDIR/fbturbo_drv.so" "$MNTDIR/usr/lib/xorg/modules/drivers" || exit 1
sudo cp -f "$RESOURCEDIR/xorg.conf" "$MNTDIR/etc/X11" || exit 1
