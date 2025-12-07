import importlib

# Charger les options moteur
importlib.import_module("custom_godot_engine_options")

# --------------- Build DEV ---------------
dev_build = "yes"
dev_mode = "yes"
optimize = "debug"
debug_symbols = "yes"
separate_debug_symbols = "yes"
extra_suffix = "dev"
