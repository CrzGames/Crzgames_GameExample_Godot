@echo off
setlocal

REM Détermine le chemin ABSOLU du dossier racine du repo
set ROOT_DIR=%~dp0..\..

REM Détermine le chemin ABSOLU du projet Godot
set PROJECT_DIR=%ROOT_DIR%\game-example-projectgodot

REM Vérifier si project.godot existe vraiment
if not exist "%PROJECT_DIR%\project.godot" (
    echo [ERROR] project.godot introuvable dans "%PROJECT_DIR%"
    pause
    exit /b 1
)

REM Chemin du binaire de l'éditeur Godot custom build
set GODOT_BIN=%ROOT_DIR%\dependencies\godot\bin\godot.windows.editor.dev.x86_64.dev.exe

if not exist "%GODOT_BIN%" (
    echo [ERROR] Binaire Godot introuvable : "%GODOT_BIN%"
    pause
    exit /b 1
)

REM Dossier de sortie du build
set BUILD_DIR=%PROJECT_DIR%\build
if not exist "%BUILD_DIR%" (
    mkdir "%BUILD_DIR%"
)

REM Nom du fichier de sortie (l'exe exporté)
set OUTPUT_EXE=%BUILD_DIR%\GameExample_Windows_Prod.exe

echo Exporting project:
echo   GODOT  = %GODOT_BIN%
echo   PROJECT= %PROJECT_DIR%
echo   OUTPUT = %OUTPUT_EXE%
echo ------------------------------

"%GODOT_BIN%" ^
  --headless ^
  --path "%PROJECT_DIR%" ^
  --export-release "Windows Desktop" ^
  "%OUTPUT_EXE%"

if errorlevel 1 (
    echo [ERROR] Export FAILED
    pause
    exit /b 1
)

echo Export OK !
endlocal
exit /b 0
