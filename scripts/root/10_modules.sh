#!/bin/bash

echo "Copying kernel modules..."
sudo cp -Rf $RESOURCEDIR/firmware/modules/*-v7+ "$MNTDIR/lib/modules" || exit 1
