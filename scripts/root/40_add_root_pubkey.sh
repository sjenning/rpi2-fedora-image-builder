#!/bin/bash

[[ -e "$RESOURCEDIR/authorized_keys" ]] || exit 0
echo "Adding root pubkey..."
mkdir -p "$MNTDIR/root/.ssh" || exit 1
cp -f "$RESOURCEDIR/authorized_keys" "$MNTDIR/root/.ssh/authorized_keys" || exit 1
echo "Setting root key permissions..."
chmod 700 "$MNTDIR/root/.ssh" || exit 1
chmod 600 "$MNTDIR/root/.ssh/authorized_keys" || exit 1
