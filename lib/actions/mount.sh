#!/bin/bash

perform_mount() {
  local DISK_FILE="$CONF_DIR/whitelist/$PROFILE_NAME.disks"

  for uuid in $(lsblk --noheadings --list --output uuid)
  do
    if grep --quiet --fixed-strings $uuid $DISKS; then
      break
    fi
    uuid=
  done

  if [ ! $uuid ]; then
    error "No backup disk found, exiting"
    exit 0
  fi

  info "Disk $uuid is a backup disk"
  partition_path=/dev/disk/by-uuid/$uuid
  MOUNTPOINT="$MOUNT_BASE/$PROFILE_NAME"
  findmnt $MOUNTPOINT >/dev/null || mount $partition_path $MOUNTPOINT
  info "Disk $uuid mounted in $MOUNTPOINT"

}
