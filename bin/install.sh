#!/bin/bash -ue

INSTALL_DIR="/opt/borgbackup-script"
cp -r . "$INSTALL_DIR"
# TODO: This may include more templates later
sed -i "s|ROOT_PATH|$INSTALL_DIR|g" "$INSTALL_DIR/config/templates/service"
ln -s "$INSTALL_DIR/bin/borg-wrapper" /usr/local/bin/borg-wrapper

echo "Script installed in $INSTALL_DIR"
echo "Wrapper linked to /usr/local/bin/borg-wrapper"
