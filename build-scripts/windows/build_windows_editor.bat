@echo off
setlocal

cd /d "%~dp0..\..\dependencies\godot" || (
    echo [ERROR] Impossible de trouver le dossier dependencies\godot
    exit /b 1
)

echo ---- BUILD WINDOWS - MODE EDITOR - PROFILE DEV ----
scons platform=windows target=editor vsproj=yes vsproj_gen_only=no profile=..\..\build-scripts\build_profile_editor.py custom_modules=..\..\modules
echo SCONS ERRORLEVEL: %ERRORLEVEL%
if errorlevel 1 (
    echo FAILED
    exit /b 1
)

echo DONE
exit /b 0
