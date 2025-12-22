cd dependencies/godot || {
    echo "[ERROR] Impossible de trouver le dossier dependencies/godot"
    exit 1
}
scons -c vulkan=no
rm -rf bin/*