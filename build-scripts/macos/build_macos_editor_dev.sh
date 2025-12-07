#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/dependencies/godot"

echo "---- BUILD MACOS EDITOR DEV ----"
scons platform=macos target=editor profile=../../build-scripts/build_profile_dev.py

echo "DONE"
