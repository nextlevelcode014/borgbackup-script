#!/bin/bash

perform_wipe() {
  RULES_LINK="/etc/udev/rules.d/80-backup-$PROFILE_NAME.rules"
  SERVICE_LINK="/etc/systemd/system/automatic-backup-$PROFILE_NAME@.service"

  if [[ -L "$RULES_LINK" ]]; then
    rm -v "$RULES_LINK"
  fi

  if [[ -L "$SERVICE_LINK" ]]; then
    rm -v "$SERVICE_LINK"
  fi

  return 0
}
