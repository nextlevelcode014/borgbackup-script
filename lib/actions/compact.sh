#!/bin/bash

perform_compact() {
  borg compact \
  --progress \
  --info \
  --error \
  --debug \
  "${BORG_REPO}" >> ${LOG_FILE} 2>&1

  local exit_code=$?

  if [[ $exit_code -eq 0 ]]; then
    info "Compact successfully"
  else
    info "Compact failed with code exit code: $exit_code"
    return $exit_code
  fi
}
