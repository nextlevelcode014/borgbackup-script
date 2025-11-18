#!/bin/bash

show_profile_info() {
  echo ""
  echo "═══════════════════════════════════════════"
  echo "  Profile Info: ${PROFILE_NAME}"
  echo "═══════════════════════════════════════════"
  echo ""
  echo "Description: ${DESCRIPTION:-N/A}"
  echo "Repository: ${BORG_REPO}"
  echo ""
  echo "Directories for backup (${#BACKUP_PATHS[@]}):"
  for dir in "${BACKUP_PATHS[@]}"; do
    if [[ -d "$dir" ]]; then
      printf "  ✓ %s\n" "$dir"
    else
      printf "  ✗ %s (not found)\n" "$dir"
    fi
  done
  echo ""
  echo "Exclude patterns (${#EXCLUDE_PATTERNS[@]}):"
  for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    printf "  • %s\n" "$pattern"
  done
  echo ""
  echo "══════════════════════════════════════════"
}
