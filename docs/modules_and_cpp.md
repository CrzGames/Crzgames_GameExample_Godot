# Modules C++ Godot – Créer ses propres types et architecture C++

Ce document explique comment :

- créer un module C++ pour Godot (exemple : `summator`) ;
- comprendre **quand il faut `GDCLASS` / `GDREGISTER_*`** ;
- utiliser des **classes C++ “pures”** pour faire de la vraie POO sans contraintes ;
- créer des **vrais types visibles dans l’éditeur** (nodes et resources avec propriétés dans l’inspecteur).

---

## 0. Structure minimale d’un module C++ Godot

Un module C++ “pur” pour Godot suit toujours la même logique.  
Dans un dossier `mymodule/`, on retrouve au minimum :

```text
mymodule/
  config.py           # obligatoire, sensible case
  SCsub               # obligatoire, sensible case
  register_types.h    # obligatoire, sensible case
  register_types.cpp  # obligatoire, sensible case
  my_class.h
  my_class.cpp
  ... (vos fichiers .cpp / .h)
```

Rôle de chaque fichier :

- `config.py`  
  - Dit au système de build **si le module peut être compilé** pour une plateforme donnée (`can_build`) ;
  - Permet de **configurer l’environnement de build** (`configure`) ;
  - Peut aussi déclarer la localisation de la doc, des icônes, etc. si besoin.

- `SCsub`  
  - Fichier SCons spécifique au module ;
  - Indique **quels fichiers .cpp** doivent être compilés pour ce module ;
  - C’est ici qu’on peut éventuellement cloner l’environnement, ajouter des flags, etc.

- `register_types.h` / `register_types.cpp`  
  - Fournissent les fonctions d’initialisation du module :  
    - `initialize_mymodule_module(ModuleInitializationLevel p_level)`  
    - `uninitialize_mymodule_module(ModuleInitializationLevel p_level)`  
  - C’est **ici** que l’on appelle `GDREGISTER_*` si l’on veut exposer des types (class) au moteur (GDScript / éditeur).

- `*.h` / `*.cpp`  
  - Vos classes C++ :
    - soit **pures** (sans `GDCLASS`, non exposées, POO C++ normale) ;
    - soit **exposées** à Godot (`GDCLASS` + `GDREGISTER_*`).

Ensuite, ce dossier de module doit être **placé à un endroit visible par le build** (voir section suivante).

---

## 1. Où mettre le module ?

Vous pouvez soit :

- mettre votre module **dans le dossier `modules/` du moteur Godot**, par ex. :

```text
godot/              # code sources du moteur (repository github de godot)
  modules/
    summator/
      config.py
      SCsub
      register_types.h
      register_types.cpp
      summator.h
      summator.cpp
```

- La meilleure méthode pour séparer du code du moteur : utiliser un dossier **externe** et le passer à SCons via `custom_modules`, par ex. :

```text
<repo>/              # notre repo
  dependencies/
    godot/           # code sources du moteur (repository github de godot)
  modules/           # notre dossier modules à nous et pas directement le dossier modules du moteur Godot
    summator/
      config.py
      SCsub
      register_types.h
      register_types.cpp
      summator.h
      summator.cpp
```

Compilation :

```bash
# Exemple simple sous Windows
cd dependencies/godot
scons platform=windows target=editor custom_modules=..\..\modules
```

---

## 2. `register_types.h / register_type.cpp` : ce qui est obligatoire et ce qui ne l’est pas

Pour que le moteur reconnaisse votre module, vous devez fournir :

```cpp
// register_types.h
#ifndef SUMMATOR_REGISTER_TYPES_H
#define SUMMATOR_REGISTER_TYPES_H

#include "modules/register_module_types.h"

/* Oui, le mot du milieu de la fonction "_summator_" doit être identique au nom du dossier du module */

void initialize_summator_module(ModuleInitializationLevel p_level);
void uninitialize_summator_module(ModuleInitializationLevel p_level);

#endif // SUMMATOR_REGISTER_TYPES_H
```

```cpp
// register_types.cpp
#include "register_types.h"

void initialize_summator_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }

    // Ici, vous *pouvez* enregistrer des classes, mais ce n’est pas obligatoire.
    // Vous pouvez avoir un module sans classes exposées si vous le souhaitez.
    // Exemple : GDREGISTER_CLASS(Summator);
}

void uninitialize_summator_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
}
```

Vous **êtes obligé** de fournir ces deux fonctions pour que le module soit intégré en `nommant correctement` le `nom des deux fonctions` par rapport au `nom du dossier du module`,  
mais **vous n’êtes pas obligé** d’y appeler `GDREGISTER_CLASS, GDREGISTER_ABSTRACT_CLASS..` si vous ne voulez rien exposer à Godot.

---

## 3. Fichiers de build : `SCsub` et `config.py`

Exemple minimal :

```python
# SCsub
Import('env')

# Ajouter tous les .cpp du module à la compilation
env.add_source_files(env.modules_sources, "*.cpp")
```

```python
# config.py
def can_build(env, platform):
    return True

def configure(env):
    pass
```

---

## 4. Les 5 types de classes C++ dans Godot

| # | Type de classe | Hérite de `Object, Node..etc` ? | Visible dans l’éditeur ? | Instanciable en GDScript ? | Enregistrement ? | Macro |
|---|---------------|----------------------|--------------------------|----------------------------|-------------------|--------|
| 1 | **Classe C++ pure (non godot et non exposée)** | ❌ non | ❌ non | ❌ non | ❌ | — |
| 2 | **Classe interne Godot (non exposée)** | ✔ oui | ❌ non | ❌ non | ✔ | `GDREGISTER_INTERNAL_CLASS` |
| 3 | **Classe abstraite Godot (exposée)** | ✔ oui | ✔ oui | ❌ non | ✔ | `GDREGISTER_ABSTRACT_CLASS` |
| 4 | **Classe Godot (exposée)** | ✔ oui | ✔ oui | ✔ oui | ✔ | `GDREGISTER_CLASS` |
| 5 | **Classe runtime Godot (exposée)** | ✔ oui | ✔ oui | ✔ oui | ✔ | `GDREGISTER_RUNTIME_CLASS` |

---

### 4.1 Classe C++ pure (non Godot et non exposée)

➡️ Aucun lien avec Godot : pas d'héritage vers `Object, Node..`, pas de `GDCLASS`, pas d’enregistrement.

```cpp
// internal_accumulator.h
#pragma once

class InternalAccumulator {
    int value = 0;

public:
    void add(int v) { value += v; }
    void reset() { value = 0; }
    int get_total() const { return value; }
};
```

👉 Parfait pour logique interne : math, pathfinding, state machines…

---

### 4.2 Classe interne Godot (non exposée)

➡️ Hérite de `Object, Node..etc` mais **non visible** dans l’éditeur et non utilisable depuis GDScript.

```cpp
// network_peer_internal.h
#pragma once
#include "core/object/object.h"

class NetworkPeerInternal : public Object {
    GDCLASS(NetworkPeerInternal, Object);

    int id = -1;

protected:
    static void _bind_methods();

public:
    void set_id(int p_id) { id = p_id; }
    int get_id() const { return id; }
};
```

```cpp
// network_peer_internal.cpp
#include "network_peer_internal.h"
#include "core/object/class_db.h"

void NetworkPeerInternal::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_id", "id"), &NetworkPeerInternal::set_id);
    ClassDB::bind_method(D_METHOD("get_id"), &NetworkPeerInternal::get_id);
}
```

Enregistrement :

```cpp
GDREGISTER_INTERNAL_CLASS(NetworkPeerInternal);
```

---

### 4.3 Classe abstraite Godot (exposée)

➡️ Hérite de `Object, Node..etc`, **visible** dans l’éditeur via **Add Node** et **non instanciable** depuis GDScript.

```cpp
// unit_base.h
#pragma once

#include "scene/2d/node_2d.h"

class UnitBase : public Node2D {
    GDCLASS(UnitBase, Node2D);

protected:
    static void _bind_methods();
    int health = 100;

public:
    void set_health(int p_h) { health = p_h; }
    int get_health() const { return health; }
};
```

```cpp
// unit_base.cpp
#include "unit_base.h"
#include "core/object/class_db.h"

void UnitBase::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_health", "health"), &UnitBase::set_health);
    ClassDB::bind_method(D_METHOD("get_health"), &UnitBase::get_health);

    ADD_PROPERTY(
        PropertyInfo(Variant::INT, "health", PROPERTY_HINT_RANGE, "0,999"),
        "set_health",
        "get_health"
    );
}
```

Enregistrement :

```cpp
GDREGISTER_ABSTRACT_CLASS(UnitBase);
```

---

### 4.4 Classe Godot (exposée)

➡️ Hérite de `Object, Node..etc`, **visible** dans l’éditeur via **Add Node** et instanciable via GDScript (`MyClass.new()`).

### Exemple : Resource custom (`UnitStats`)

```cpp
// unit_stats.h
#pragma once

#include "core/io/resource.h"

class UnitStats : public Resource {
    GDCLASS(UnitStats, Resource);

    int max_health = 100;
    int attack = 10;
    float move_speed = 100.0;

protected:
    static void _bind_methods();

public:
    void set_max_health(int h) { max_health = h; }
    int get_max_health() const { return max_health; }

    void set_attack(int a) { attack = a; }
    int get_attack() const { return attack; }

    void set_move_speed(float s) { move_speed = s; }
    float get_move_speed() const { return move_speed; }
};
```

```cpp
// unit_stats.cpp
#include "unit_stats.h"
#include "core/object/class_db.h"

void UnitStats::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_max_health", "max_health"), &UnitStats::set_max_health);
    ClassDB::bind_method(D_METHOD("get_max_health"), &UnitStats::get_max_health);

    ClassDB::bind_method(D_METHOD("set_attack", "attack"), &UnitStats::set_attack);
    ClassDB::bind_method(D_METHOD("get_attack"), &UnitStats::get_attack);

    ClassDB::bind_method(D_METHOD("set_move_speed", "move_speed"), &UnitStats::set_move_speed);
    ClassDB::bind_method(D_METHOD("get_move_speed"), &UnitStats::get_move_speed);

    ADD_PROPERTY(PropertyInfo(Variant::INT, "max_health"), "set_max_health", "get_max_health");
    ADD_PROPERTY(PropertyInfo(Variant::INT, "attack"), "set_attack", "get_attack");
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "move_speed"), "set_move_speed", "get_move_speed");
}
```

Enregistrement :

```cpp
GDREGISTER_CLASS(UnitStats);
```

---

### 4.5 Classe runtime Godot (exposée)

Cas avancé, rarement utile au début.

```cpp
class DynamicRuntimeType : public Object {
    GDCLASS(DynamicRuntimeType, Object);

    int runtime_id = 0;

protected:
    static void _bind_methods();
};
```

Enregistrement :

```cpp
GDREGISTER_RUNTIME_CLASS(DynamicRuntimeType);
```

---

### 4.6 Fichier complet pour : `register_types.cpp`

```cpp
// register_types.cpp
#include "register_types.h"

#include "core/object/class_db.h"

#include "network_peer_internal.h"
#include "unit_base.h"
#include "unit_stats.h"
#include "dynamic_runtime_type.h"

void initialize_mymodule_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) return;

    GDREGISTER_INTERNAL_CLASS(NetworkPeerInternal);
    GDREGISTER_ABSTRACT_CLASS(UnitBase);
    GDREGISTER_CLASS(UnitStats);
    GDREGISTER_RUNTIME_CLASS(DynamicRuntimeType);
}

void uninitialize_mymodule_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) return;
}
```