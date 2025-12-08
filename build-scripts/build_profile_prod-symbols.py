import importlib

# Charger les options moteur
importlib.import_module("custom_godot_engine_options")

# --------------- Build PROD DEBUG ---------------
production="yes"
optimize = "speed_trace"
debug_symbols = "yes"
separate_debug_symbols = "yes"
use_static_cpp = "yes"
lto = "auto"
extra_suffix = "prod-symbols"
