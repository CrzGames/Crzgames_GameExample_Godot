#include "register_types.h"
#include "summator.h"

#include "core/object/class_db.h"

void initialize_summator_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}
	GDREGISTER_CLASS(Summator);
}

void uninitialize_summator_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}
   // Nothing to do here in this example.
}
