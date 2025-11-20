#!/bin/bash

set -euo pipefail

SOURCE="${BASH_SOURCE[0]}"

while [ -h "$SOURCE" ]; do 
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" 
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

PROJECT_ROOT="$( cd -P "$( dirname "$SOURCE" )/.." && pwd )"

source "$PROJECT_ROOT/lib/utils/setup.sh"

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
source "$PROJECT_ROOT/lib/actions/browser.sh"

PROFILE_NAME=""

if [[ -n "$1" ]] && [[ "$1" != -* ]]; then
  PROFILE_NAME=$1
  shift
fi

if [[ $# -eq 0 ]]; then
  error "No action specified"
  show_help
  exit 1
fi

DO_MOUNT=false
DO_CREATE=false
DO_PRUNE=false
DO_COMPACT=false
DO_RULES=false
DO_BROWSER=false
DO_WIPE=false

while getopts ":mcPCihlrBw" opt; do
  case $opt in
    m) DO_MOUNT=true ;;
    c) DO_CREATE=true ;;
    P) DO_PRUNE=true ;;
    C) DO_COMPACT=true ;;
    r) DO_RULES=true ;;
    m) DO_BROWSER=true ;;
    w) DO_WIPE=true ;;
    i)
      if [[ -z "$PROFILE_NAME" ]]; then
         echo "Error: You must specify a profile for info. Usage: $(basename "$0") PROFILE -i"
         exit 1
       fi
       if ! load_profile "${PROFILE_NAME}"; then
         exit 1;
       fi
       show_profile_info
       exit 0
       ;;
    l) list_profiles; exit 0 ;;
    h) show_help; exit 0 ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit 1 ;;
  esac
done

if [[ -z "$PROFILE_NAME" ]]; then
  echo "Error: Profile name missing."
  echo "Usage: $(basename "$0") <PROFILE_NAME> [OPTIONS]"
  echo "Try '$(basename "$0") -l' to list available profiles."
  exit 1
fi

if ! load_profile "${PROFILE_NAME}"; then
   echo "Failed to load profile: $PROFILE_NAME"
   exit 1
fi

if $DO_WIPE; then
  if ! perform_wipe; then
    error "Wiped failed"
    exit 1
  fi
fi

if $DO_RULES; then
  if ! perform_rules; then
    error "Rules failed"
    exit 1
  fi
fi

if $DO_MOUNT; then
  if ! perform_mount; then
    exit 1
  fi

  trap perform_umount EXIT
fi

if $DO_CREATE; then
  if ! perform_backup; then
    exit 1
  fi
fi

if $DO_PRUNE; then
  if ! perform_prune; then
    exit 1
  fi
fi

if $DO_COMPACT; then
  if ! perform_compact; then
    exit 1
  fi
fi

if $DO_BROWSER; then
  if ! perform_browser; then
    exit 1
  fi
fi

info "All operations finished."
