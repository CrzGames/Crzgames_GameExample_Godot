#!/usr/bin/env bash
set -euo pipefail

# Détermine le chemin ABSOLU du dossier racine du repo
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Détermine le chemin ABSOLU du projet Godot
PROJECT_DIR="$ROOT_DIR/game-example-projectgodot"

# Vérifier si project.godot existe vraiment
if [[ ! -f "$PROJECT_DIR/project.godot" ]]; then
    echo "[ERROR] project.godot introuvable dans \"$PROJECT_DIR\""
    read -r -p "Press Enter to exit..."
    exit 1
fi

# Chemin du binaire de l'éditeur Godot custom build
GODOT_BIN="$ROOT_DIR/dependencies/godot/bin/godot_macos_editor_dev_dev.app/Contents/MacOS/Godot"

echo "Running editor:"
echo "  GODOT   = $GODOT_BIN"
echo "  PROJECT = $PROJECT_DIR"
echo "-------------------------"

"$GODOT_BIN" \
  --path "$PROJECT_DIR" \
  --editor \
  --verbose \
  --debug \
  --gpu-validation \
  --gpu-abort

exit 0
