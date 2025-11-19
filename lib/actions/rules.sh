perform_rules() {
  info "Configuring rules for profile: $PROFILE_NAME"

  # ---------------------------------------------------------
  # Directory configurations
  # ---------------------------------------------------------
  local CONF_DIR="$PROJECT_ROOT/config"
  local RULES_DIR="$CONF_DIR/rules"
  local SERVICE_DIR="$CONF_DIR/systemd-services"
  local DISK_FILE="$CONF_DIR/whitelist/$PROFILE_NAME.disks"

  # ---------------------------------------------------------
  # Generating disk files (.disks)
  # ---------------------------------------------------------
  # If the file doesn't exist, create it. If it exist, check 
  # if the UUID is already there.
  if [[ ! -f "$DISK_FILE" ]]; then
    error "File doesn't exist: $DISK_FILE"
    echo "Create the $DISK_FILE file and add the disk UUIDs"
    return 1
  fi

  # ---------------------------------------------------------
  # Generating UDEV rules
  # ---------------------------------------------------------
  local RULES_FILE="$RULES_DIR/80-backup-$PROFILE_NAME.rules"
  local TEMPLATE_RULE="$PROJECT_ROOT/config/templates/rules" 

  if [[ ! -f "$TEMPLATE_RULE" ]]; then
    error "Template not found: $TEMPLATE_RULE"
    return 1
  fi

  info "Regenerating UDEV rules for all disks in $DISK_FILE..."

  : > "$RULES_FILE"

  while IFS= read -r uuid || [[ -n "$uuid" ]]; do
    [[ -z "$uuid" ]] && continue

    info "  ->  adding rule for UUID: $uuid"

    sed -e "s|DRIVE_UUID|$uuid|g" \
        -e "s|PROFILE_NAME|$PROFILE_NAME|g" \
        "$TEMPLATE_RULE" >> "$RULES_FILE"

  done < "$DISK_FILE"

  info "Rules file generated with $(wc -l < "$RULES_FILE") rules."

  # ---------------------------------------------------------
  # Generating systemd services
  # ---------------------------------------------------------
  local SERVICE_FILENAME="automatic-backup-$PROFILE_NAME@$PROFILE_NAME.service"
  local SERVICE_FILE="$SERVICE_DIR/$SERVICE_FILENAME"
  local SERVICE_TEMPLATE="$CONF_DIR/templates/service"

  if [[ ! -f "$SERVICE_TEMPLATE" ]]; then
      error "Service template not found: $SERVICE_TEMPLATE"
      return 1
  fi

  if [[ ! -f "$SERVICE_FILE" ]]; then
    info "Generating Systemd Service file..."

    sed -e "s|ROOT_PATH|$PROJECT_ROOT|g" \
        "$SERVICE_TEMPLATE" > "$SERVICE_FILE"

    info "Service generated at: $SERVICE_FILE"
  else
    info "Service file already exists. Skipping."
  fi

  local SYS_RULES_LINK="/etc/udev/rules.d/80-backup-$PROFILE_NAME.rules"
  local SYS_SERVICE_LINK="/etc/systemd/system/$SERVICE_FILENAME"

  echo ""
  echo "========================================================"
  echo "Configuration files generated successfully!"
  echo "To activate, run the following commands (as root):"
  echo "========================================================"

  if [[ ! -L "$SYS_RULES_LINK" ]]; then
    echo "ln -sf \"$RULES_FILE\" \"$SYS_RULES_LINK\""
    echo "udevadm control --reload"
  else
    echo "# Udev rule already linked."
  fi

  if [[ ! -L "$SYS_SERVICE_LINK" ]]; then
    echo "ln -sf \"$SERVICE_FILE\" \"$SYS_SERVICE_LINK\""
    echo "systemctl daemon-reload"
  else
    echo "# Systemd service already linked."
  fi
  echo "========================================================"
}
