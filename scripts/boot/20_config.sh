#!/bin/bash

[[ -e "$RESOURCEDIR/config.txt" ]] || exit 0
echo "Copying config.txt"
sudo cp -f $RESOURCEDIR/config.txt $MNTDIR/. || exit 1
