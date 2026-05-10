#!/bin/bash
 
set -e
 
FOLDERS=(
  "$HOME/nilecloud"
)
 
for FOLDER in "${FOLDERS[@]}"; do
  echo ">>> $FOLDER"
  cd "$FOLDER"
  bash update.sh
  echo ""
done
