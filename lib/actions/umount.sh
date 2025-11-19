#!/bin/bash

perform_umount() {
  local MOUNTPOINT="$MOUNT_BASE/$PROFILE_NAME"

  if mountpoint -q "$MOUNTPOINT"; then
    info "Sycing data to disk..."
    sync

    info "Unmounting $MOUNTPOINT"

    if umount "$MOUNTPOINT"; then
      info "Disk umounted successfully!"

      rmdir "$MOUNTPOINT"
    else
      error Failed to unmount $MOUNTPOINT. Check if any process is using it.
      return 1
    fi
  else
    info "$MOUNTPOINT is not mounted"
  fi
}
