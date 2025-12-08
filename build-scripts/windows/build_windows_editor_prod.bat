@echo off
setlocal

cd /d "%~dp0..\..\dependencies\godot" || (
    echo [ERROR] Impossible de trouver le dossier dependencies\godot
    exit /b 1
)

echo ---- BUILD WINDOWS EDITOR PROD ----
scons platform=windows target=editor vsproj=yes vsproj_gen_only=no profile=..\..\build-scripts\build_profile_prod.py
echo SCONS ERRORLEVEL: %ERRORLEVEL%
if errorlevel 1 (
    echo FAILED
    exit /b 1
)

echo DONE
exit /b 0
