#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/dependencies/godot"

echo "---- BUILD MACOS TEMPLATE PROD ----"
scons platform=macos target=template_release profile=../../build-scripts/build_profile_prod.py

echo "DONE"
