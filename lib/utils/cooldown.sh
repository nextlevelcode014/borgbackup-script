#!/bin/bash

get_last_run_file() {
  local CACHE_DIR="$PROJECT_ROOT/var/cache"
  if [[ ! -d "$CACHE_DIR" ]]; then
    mkdir -p "$CACHE_DIR"
  fi
  echo "$CACHE_DIR/last_run_${PROFILE_NAME}"
}

check_cooldown() {
  local cooldown_setting="${BACKUP_COOLDOWN:-0}"

  [[ "$cooldown_setting" == "0" ]] && return 0

  local last_run_file=$(get_last_run_file)

  if [[ -f "$last_run_file" ]]; then
    local last_time=$(cat "$last_run_file")
    local current_time=$(date +%s)

    local cooldown_seconds=0
    case "$cooldown_setting" in
      *m) cooldown_seconds=$(( ${cooldown_setting%m} * 60 )) ;;
      *h) cooldown_seconds=$(( ${cooldown_setting%h} * 3600 )) ;;
      *d) cooldown_seconds=$(( ${cooldown_setting%d} * 86400 )) ;;
      *)  cooldown_seconds=$cooldown_setting ;;
    esac

    local diff=$(( current_time - last_time ))

    if (( diff < cooldown_seconds )); then
      local remaining=$(( cooldown_seconds - diff ))
      local remaining_min=$(( remaining / 60 ))

      info "⏳ COOLDOWN ACTIVED: Backup ignored."
      info "   Last run: $(date -d @$last_time)"
      info "   Wait +${remaining_min}m for a new automatic backup."
      return 1
    fi
  fi

  return 0
}

update_last_run_timestamp() {
  local last_run_file=$(get_last_run_file)
  date +%s > "$last_run_file"
}
