#!/usr/bin/env bash
set -e

# Se placer dans le dossier du script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Aller dans dependencies/godot
cd "$SCRIPT_DIR/../../dependencies/godot" || {
    echo "[ERROR] Impossible de trouver le dossier dependencies/godot"
    exit 1
}

echo "---- BUILD UNIX (Linux) - MODE EDITOR ----"

scons \
    platform=linuxbsd \
    target=editor \
    profile=../../build-scripts/build_profile_editor.py \
    custom_modules=../../modules

SCONS_ERRORLEVEL=$?
echo "SCONS ERRORLEVEL: $SCONS_ERRORLEVEL"

if [ $SCONS_ERRORLEVEL -ne 0 ]; then
    echo "FAILED"
    exit 1
fi

echo "DONE"
exit 0
