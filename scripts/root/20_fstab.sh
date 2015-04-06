#!/bin/bash

echo "Creating fstab..."
cat << EOF | sudo tee $MNTDIR/etc/fstab > /dev/null
UUID=$UUID / ext4 defaults,noatime 0 0
/dev/mmcblk0p1 /boot vfat defaults 0 0
EOF
