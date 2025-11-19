#!/bin/bash

set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"
while [[ -h "$SOURCE" ]]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"

  [[ "$SOURCE != /*" ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd)"

PROJECT_ROOT="$( cd -P "$( dirname "$SOURCE" )/.." && pwd )"

source "$PROJECT_ROOT/lib/utils/setup.sh"

# TODO: check if order 
source "$PROJECT_ROOT/lib/actions/mount.sh"
source "$PROJECT_ROOT/lib/actions/umount.sh"
source "$PROJECT_ROOT/lib/actions/create.sh"
source "$PROJECT_ROOT/lib/actions/prune.sh"
source "$PROJECT_ROOT/lib/actions/compact.sh"
source "$PROJECT_ROOT/lib/actions/rules.sh"
source "$PROJECT_ROOT/lib/actions/wipe.sh"
source "$PROJECT_ROOT/lib/actions/show_help.sh"
source "$PROJECT_ROOT/lib/actions/list_profiles.sh"
source "$PROJECT_ROOT/lib/actions/load_profile.sh"
source "$PROJECT_ROOT/lib/actions/show_profile_info.sh"

if [[ $# -eq 0 ]]; then
  error "No action specified"
  show_help
  exit 1
fi

PROFILE_SET=false
ACTION_TAKEN=false

while getopts ":p:cPCihlrmws" opt; do
  case $opt in
    p)
      if ! load_profile "${OPTARG}"; then
        error "Failed to load profile"
        exit 1
      fi
      PROFILE_SET=true
      ;;
    m)
      check_profile_set

      if perform_mount; then
        trap perform_umount EXIT
      else
        error "Failed to mount disk"
        exit 1
      fi
      ACTION_TAKEN=true
      ;;
    c)
      check_profile_set
      ACTION_TAKEN=true
      info "Starting backup creation"

      if perform_backup; then
        info "Backup created successfully!"
      else
        error "Backup failed!"
        exit 1
      fi
      ;;
    P)
      check_profile_set
      ACTION_TAKEN=true
      info "Starting prune"
      if perform_prune; then
        info "Prune completed successfully!"
      else
        error "Prune failed"
        exit 1
      fi
      ;;
    C)
      check_profile_set
      ACTION_TAKEN=true
      info "Starting compact"
      if perform_compact; then
        info "Compact completed successfully!"
      else
        error "Compact failed"
        exit 1
      fi
      ;;
    r)
      check_profile_set
      ACTION_TAKEN=true
      info "Setting rules"
      if perform_rules; then
        info "Rules setted successfully!"
      else
        error "Rules failed"
        exit 1
      fi
      ;;
    w)
      check_profile_set
      ACTION_TAKEN=true
      info "Wiping rules"
      if perform_wipe; then
        info "Rules wiped successfully!"
      else
        error "Wiped failed"
        exit 1
      fi
      ;;
    i)
      check_profile_set
      show_profile_info
      exit 0
      ;;
    l)
      list_profiles
      exit 0
      ;;
    h)
      show_help
      exit 0
      ;;
    *)
      echo "Error: Invalid option" >&2
      exit 1
      ;;
  esac
done

if ! $PROFILE_SET; then
  error "Profile (-p) is required!"
  exit 1
fi

if ! $ACTION_TAKEN; then
  error "No action specified."
  exit 1
fi

info "All operations finished."
