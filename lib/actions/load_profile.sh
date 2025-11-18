#!/bin/bash

load_profile() {
  local profile_name="$1"
  local profile_file="$PROJECT_ROOT/config/profiles/$profile_name.conf"

  if [[ ! -f "${profile_file}" ]]; then
    error "Profile not found: $profile_name"
    error "File expected: $profile_file"
    return 1
  fi

  source "${profile_file}"

  if [[ -z "${BORG_REPO:-}" ]]; then
    error "Invalid profile: BORG_REPO is not defined in ${profile_name}.conf"
    return 1
  fi

  if [[ ! -d "$MOUNT_BASE" ]]; then
    error "Directory $MOUNT_BASE doesn't exist"
    exit 1
  fi

  if [[ ${#BACKUP_PATHS[@]} -eq 0 ]]; then
    error "Invalid profile: BACKUP_PATHS is empty in ${profile_name}.conf"
    return 1
  fi

  info "Profile loaded: ${profile_name}"
  info "  Repository: ${BORG_REPO}"
  info "  Description: ${DESCRIPTION:-N/A}"
  info "  Directories: ${#BACKUP_PATHS[@]} configurations"
  info "  Excludes: ${#EXCLUDE_PATTERNS[@]} patterns"

  return 0
}

