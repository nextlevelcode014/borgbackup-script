#!/bin/bash

source "$PROJECT_ROOT/lib/utils/cooldown.sh"

perform_prune() {
  if ! check_cooldown; then
    return 1
  fi

  info "Starting prune"


  borg prune                            \
    --info                              \
    --debug                             \
    --error                             \
    --list                              \
    --glob-archives '{hostname}-*'      \
    --keep-daily    7                   \
    --keep-weekly   4                   \
    --keep-monthly  6                   \
    "${BORG_REPO}" >> "${LOG_FILE}" 2>&1

  local exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    info "Prune successfully"
    update_last_run_timestamp
  else
    info "Prune failed with code exit code: $exit_code"
    return $exit_code
  fi
}
