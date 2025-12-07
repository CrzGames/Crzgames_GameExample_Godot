#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/dependencies/godot"

echo "---- BUILD LINUX TEMPLATE PROD DEBUG ----"
scons platform=linuxbsd target=template_release profile=../../build-scripts/build_profile_prod-symbols.py

echo "DONE"
