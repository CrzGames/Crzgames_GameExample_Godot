@echo off
cd /d "%~dp0..\..\dependencies\godot" || (
    echo [ERROR] Impossible de trouver le dossier dependencies\godot
    exit /b 1
)

echo ---- BUILD WINDOWS EDITOR DEV ----
scons platform=windows target=editor profile=..\..\build-scripts\build_profile_dev.py vsproj=yes
if errorlevel 1 (echo FAILED & exit /b 1)

echo DONE
