@echo off
cd /d "%~dp0..\..\dependencies\godot" || (
    echo [ERROR] Impossible de trouver le dossier dependencies\godot
    exit /b 1
)

echo ---- BUILD WINDOWS TEMPLATE PROD DEBUG ----
scons platform=windows target=template_release profile=..\..\build-scripts\build_profile_prod-symbols.py
if errorlevel 1 (echo FAILED & exit /b 1)

echo DONE
