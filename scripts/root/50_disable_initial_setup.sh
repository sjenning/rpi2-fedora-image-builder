#!/bin/bash

[[ $DISABLE_INITIAL_SETUP -ne 0 ]] || exit 0
echo "Disabling initial-setup..."
rm "$MNTDIR/etc/systemd/system/multi-user.target.wants/initial-setup-text.service" || exit 1
