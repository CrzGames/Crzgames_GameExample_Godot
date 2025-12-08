@echo off
setlocal

REM Détermine le chemin ABSOLU du dossier racine du repo
set ROOT_DIR=%~dp0..\..

REM Détermine le chemin ABSOLU du projet Godot
set PROJECT_DIR=%ROOT_DIR%\game-example

REM Vérifier si project.godot existe vraiment
if not exist "%PROJECT_DIR%\project.godot" (
    echo [ERROR] project.godot introuvable dans "%PROJECT_DIR%"
    pause
    exit /b 1
)

REM Chemin du binaire de l'editeur Godot custom build
set GODOT_BIN=%ROOT_DIR%\dependencies\godot\bin\godot.windows.editor.prod.x86_64.prod.exe

echo Running editor:
echo   GODOT = %GODOT_BIN%
echo   PROJECT = %PROJECT_DIR%
echo -------------------------

"%GODOT_BIN%" ^
  --path "%PROJECT_DIR%" ^
  --editor ^
  --print-fps ^
  --gpu-profile ^
  --profiling

endlocal
exit /b 0
