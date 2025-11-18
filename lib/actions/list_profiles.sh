#!/bin/bash

list_profiles() {
  if [[ ! -d "${PROFILES_DIR}" ]]; then
    echo "Perfils directory not found: $PROFILES_DIR"
    return 1
  fi

  echo "Avaliable profiles"
  echo "=================="

  local found=false
  for profile_file in "${PROFILES_DIR}"/*.conf; do
    [[ ! -f "$profile_file" ]] && continue
    found=true

    local profile_name=$(basename "$profile_file" .conf)

    (
      source "$profile_file"
      printf "  [%-15s] %s\n" "$profile_name" "${DESCRIPTION:-No description}"
      printf "  %-17s → %s\n\n" "" "${BORG_REPO}"
    )
  done

  if ! $found; then
    echo "  Nenhum perfil encontrado."
    echo ""
    echo "Create profiles in: ${PROFILES_DIR}/"
  fi
}
