#!/bin/bash

show_help() {
  cat << EOF
Usage: $(basename "$0") -p PROFILE [options]

Mandatory option:
  -p PROFILE   Select a backup profile (producao, local, backup)

Action options:
  -c           create
  -P           prune
  -C           compact 
  -i           show profile info
  -l           list profile avaliables
  -w           Wipe config
  -h           Show this help

Examples:
  $(basename "$0") -p production -c        # Create a backup using the 'producao' profile
  $(basename "$0") -p local -cPC           # Backup, prune and compact
  $(basename "$0") -p backup -i            # Show profile info 
  $(basename "$0") -l                      # List all profiles

Note: The profile (-p) MUST be specified before performig the action
EOF
}
