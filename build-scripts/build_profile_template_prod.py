import os
import sys

# On part du dossier courant quand SCons exécute le profil (dependencies/godot)
PROJECT_ROOT = os.path.abspath(os.path.join(os.getcwd(), "..", ".."))
BUILD_SCRIPTS_DIR = os.path.join(PROJECT_ROOT, "build-scripts")

if BUILD_SCRIPTS_DIR not in sys.path:
    sys.path.append(BUILD_SCRIPTS_DIR)

# Permet de récupérer les options personnalisées du moteur : custom_godot_engine_options.py
from custom_godot_engine_options import *

# --------------- Template - Build mode PROD ---------------
production="yes"
optimize = "speed"
debug_symbols = "no"
separate_debug_symbols = "no"
use_static_cpp = "yes"
lto = "full"
extra_suffix = "prod"
