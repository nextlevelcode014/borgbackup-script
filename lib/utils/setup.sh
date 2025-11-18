#!/bin/bash

LOG_DIRECTORY="$HOME/.local/share/borg-backup/script.log"
LOG_FILE="$LOG_DIRECTORY/script.log"

if [[ ! -d "$LOG_DIRECTORY" ]]; then
  mkdir -p "$LOG_DIRECTORY"
  touch "$LOG_FILE"
fi

info() {
  local green="\033[0;32m"
  local message="[info] [$(date +%T)] - $1"
  echo -e "${green}$message\033[0m"
  echo "===============================================" >> ${LOG_FILE}
  echo -e "$message" >> "${LOG_FILE}"
}

error() {
  local red="\033[0;31m"
  local message="[error] [$(date +%T)] - $1"
  echo -e "${red}$message\033[0m"
  echo "===============================================" >> ${LOG_FILE}
  echo -e "$message" >> "${LOG_FILE}"
}

warn() {
  local yellow="\033[0;33m"
  local message="[warn] [$(date +%T)] - $1"
  echo -e "${yellow}$message\033[0m"
  echo "===============================================" >> ${LOG_FILE}
  echo -e "$message" >> "${LOG_FILE}"
}

check_profile_set() {
  if ! $PROFILE_SET; then
    error "Profile (-p) MUST be specified before performig the action"
    echo ""
    show_help
    exit 1
  fi
}

info "Valid initial configurations"

