#!/bin/bash

source "$PROJECT_ROOT/lib/utils/cooldown.sh"

perform_compact() {
  if ! check_cooldown; then
    return 0
  fi

  info "Starting compact"

  borg compact \
    --progress \
    --info \
    --error \
    --debug \
    "${BORG_REPO}" >> ${LOG_FILE} 2>&1

  local exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    info "Compact successfully"

    update_last_run_timestamp
  else
    info "Compact failed with code exit code: $exit_code"
    return $exit_code
  fi
}
