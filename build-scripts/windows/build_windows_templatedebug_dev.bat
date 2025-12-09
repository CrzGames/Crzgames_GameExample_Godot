@echo off
cd /d "%~dp0..\..\dependencies\godot" || (
    echo [ERROR] Impossible de trouver le dossier dependencies\godot
    exit /b 1
)

echo ---- BUILD WINDOWS TEMPLATE DEBUG ----
scons platform=windows target=template_debug profile=..\..\build-scripts\build_profile_template_dev.py custom_modules=..\..\modules
if errorlevel 1 (echo FAILED & exit /b 1)

echo DONE
