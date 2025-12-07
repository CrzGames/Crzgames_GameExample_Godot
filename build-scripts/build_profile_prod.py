import importlib

# Charger les options moteur
importlib.import_module("custom_godot_engine_options")

# --------------- Build PROD ---------------
optimize = "speed"
debug_symbols = "no"
use_static_cpp = "yes"
lto = "auto"
extra_suffix = "prod"
