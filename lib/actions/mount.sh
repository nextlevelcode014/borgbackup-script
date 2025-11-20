#!/bin/bash

perform_mount() {
  local DISKS="$PROJECT_ROOT/config/whitelist/$PROFILE_NAME.disks"

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

  # TODO: cache
  if [[ ! -d "$MOUNTPOINT" ]]; then
    mkdir -p "$MOUNTPOINT"
  fi

  findmnt $MOUNTPOINT >/dev/null || mount $partition_path $MOUNTPOINT >> "$LOG_FILE" 2>&1

  local exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    info "Disk $uuid mounted in $MOUNTPOINT"
    return 0
  else
    error "Mount disk failed with code: $exit_code"
    return $exit_code
  fi
}
