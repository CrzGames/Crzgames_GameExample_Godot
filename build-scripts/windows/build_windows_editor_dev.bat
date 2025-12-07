@echo off
cd /d "%~dp0dependencies\godot"

echo ---- BUILD WINDOWS EDITOR DEV ----
scons platform=windows target=editor profile=..\..\build-scripts\build_profile_dev.py
if errorlevel 1 (echo FAILED & exit /b 1)

echo DONE
