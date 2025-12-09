import os
import sys

# On part du dossier courant quand SCons exécute le profil (dependencies/godot)
PROJECT_ROOT = os.path.abspath(os.path.join(os.getcwd(), "..", ".."))
BUILD_SCRIPTS_DIR = os.path.join(PROJECT_ROOT, "build-scripts")

if BUILD_SCRIPTS_DIR not in sys.path:
    sys.path.append(BUILD_SCRIPTS_DIR)

from custom_godot_engine_options import *

# --------------- Template - Build mode DEV ---------------
dev_build = "yes"
dev_mode = "yes"
optimize = "debug"
debug_symbols = "yes"
separate_debug_symbols = "yes"
scu_build = "yes"
extra_suffix = "dev"