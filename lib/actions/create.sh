#!/bin/bash

perform_backup() {
  if [[ -z "${PROFILE_NAME:-}" ]]; then
    error "No profile loaded"
    return 1
  fi

  local ARCHIVE_PREFIX="${PROFILE_NAME}-$(hostname)-$(date --iso-8601)"

  if [[ ${#BACKUP_PATHS[@]} -eq 0 ]]; then
    echo "$BACKUP_PATHS"
    error "No directory configured for backup in the ${PROFILE_NAME} profile"
    return 1
  fi

  local VALID_PATHS=()
  local MISSING_PATHS=()

  for dir in "${BACKUP_PATHS[@]}"; do
    if [[ -d  "$dir" ]]; then
      VALID_PATHS+=("$dir")
    else
      MISSING_PATHS+=("$dir")
    fi
  done

  if [[ ${#MISSING_PATHS[@]} -gt 0 ]]; then
    info "Some directories were not found"
    for dir in "${MISSING_PATHS[@]}"; do
      error " $dir"
    done
  fi

  if [[ ${#VALID_PATHS[@]} -eq 0 ]]; then
    error "No directory valid to backup"
    return 1
  fi

  info "Directories for backup: (${#VALID_PATHS[@]}):"
  for dir in "${VALID_PATHS[@]}"; do
    info " $dir"
  done

  local EXCLUDE_OPTS=()

  if [[ ${#EXCLUDE_PATTERNS[@]} -gt 0 ]]; then
    for pattern in "${EXCLUDE_PATTERNS[@]}"; do
      EXCLUDE_OPTS+=("--exclude" "'$pattern'")
    done
    info "Applaying ${#EXCLUDE_PATTERNS[@]} exclude patterns"
  fi


  info "Creating archive: $ARCHIVE_PREFIX"

  borg create \
    --info \
    --stats \
    --progress \
    --compression zstd,3 \
    --one-file-system \
    "${BORG_REPO}::${ARCHIVE_PREFIX}" \
    "${EXCLUDE_OPTS}" \
    "${VALID_PATHS[@]}" >> "$LOG_FILE" 2>&1

  local exit_code=$?
  if [[ $exit_code -eq 0 ]]; then
    info "Backup created successfully!"
    return 0
  else
    erro "Backup failed with code: $exit_code"
    return $exit_code
  fi

}
