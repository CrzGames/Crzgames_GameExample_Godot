#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/dependencies/godot"

echo "---- BUILD LINUX EDITOR DEV ----"
scons platform=linuxbsd target=editor profile=../../build-scripts/build_profile_dev.py

echo "DONE"
