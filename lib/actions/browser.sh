#!/bin/bash

perform_browser() {
  local MOUNT_DIR="/home/nextlevelcode/Backup/BorgMount-$PROFILE_NAME"

  local USER_ID="${SUDO_UID:-$(id -u)}"
  local USER_GID="${SUDO_GID:-$(id -g)}"

  if [[ ! -d "$MOUNT_DIR" ]]; then
    mkdir -p "$MOUNT_DIR"
    chown $USER_ID:$USER_GID "$MOUNT_DIR"
    chmod 700 "$MOUNT_DIR"
  fi

  info "Mounting Borg Archive for browsing..."
  info "Location: $MOUNT_DIR"

  borg mount \
    -o uid="$USER_ID",gid="$USER_GID",allow_other \
    "$BORG_REPO" "$MOUNT_DIR" >> "${LOG_FILE}" 2>&1

  if [[ $? -eq 0 ]]; then
    echo ""
    echo "✅ Backup mounted successfully!"
    echo "📂 Location: $MOUNT_DIR"
    echo "-------------------------------------------------------"
    echo "   PRESS [ENTER] TO UNMOUNT AND EXIT"
    echo "-------------------------------------------------------"

    read -r

    info "User requested unmount."
  else
    error "Mount failed. Check log for details."
    return 1
  fi

  info "Unmounting..."
  if borg umount "$MOUNT_DIR"; then
    info "Unmounted successfully."
    rmdir "$MOUNT_DIR"
  else
    error "Could not unmount. Trying forced unmount..."
    umount -l "$MOUNT_DIR" && rmdir "$MOUNT_DIR"
  fi
}
