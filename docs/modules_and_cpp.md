# 📘 Godot 4.x - Modules C++ / Créer ses propres types et architecture C++

Ce document explique comment :

- créer un module C++ pour Godot ;
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

### 4.6 Fichier complet final pour : `register_types.cpp`

C'est dans ce fichier qu'il faut faire l'enregistrement des classes en fonction du type de classe Godot.

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

---

## 5. _bind_methods() : les 5 choses que tu peux exposer à Godot

Documentation officiel pour plus de détaille : https://docs.godotengine.org/fr/4.5/engine_details/architecture/object_class.html

**_bind_methods()** est la fonction centrale qui construit le pont C++ → Godot.

### 5.1 Ce qu’on peut y déclarer
| Élément | Code utilisé | Permet |
|---------|--------|--------|
| Méthodes | ClassDB::bind_method() | Appeler une méthode C++ d'une classe depuis GDScript |
| Propriétés | ADD_PROPERTY() | Voir/éditer un champ dans l’inspecteur de l'editeur Godot |
| Signaux | ADD_SIGNAL() | Définir des signaux que la classe peut émettre vers GDScript |
| Enums | BIND_ENUM_CONSTANT() + VARIANT_ENUM_CAST() | Exposer des enums utilisables depuis GDScript |
| Constante | BIND_CONSTANT() | Exposer des constantes utilisables depuis GDScript |

### 5.2 Exemple complet : classe Unit côté C++

#### 5.2.1 Header : unit.h
```cpp
// unit.h
#pragma once

#include "scene/2d/node_2d.h"

class Unit : public Node2D {
    GDCLASS(Unit, Node2D);

public:
    enum UnitType {
        UNIT_INFANTRY = 0,
        UNIT_TANK     = 1,
        UNIT_AIRCRAFT = 2,
    };

private:
    float speed = 100.0f;
    int health = 100;
    UnitType type = UNIT_INFANTRY;
    static const int MAX_UNITS = 32;

protected:
    static void _bind_methods();

public:
    // Méthodes exposées
    void set_speed(float p_speed);
    float get_speed() const;

    void set_health(int p_health);
    int get_health() const;

    void set_type(UnitType p_type);
    UnitType get_type() const;

    // Exemple de logique qui émet un signal
    void take_damage(int p_amount);
};
```

#### 5.2.2 Implémentation : unit.cpp
```cpp
// unit.cpp
#include "unit.h"
#include "core/object/class_db.h"

// Enum : Obligatoire en + de -> BIND_ENUM_CONSTANT dans _bind_methods
VARIANT_ENUM_CAST(Unit::UnitType);

void Unit::_bind_methods() {
    // 1) MÉTHODES : bind_method → appelables depuis GDScript
    ClassDB::bind_method(D_METHOD("set_speed", "speed"), &Unit::set_speed);
    ClassDB::bind_method(D_METHOD("get_speed"), &Unit::get_speed);

    ClassDB::bind_method(D_METHOD("set_health", "health"), &Unit::set_health);
    ClassDB::bind_method(D_METHOD("get_health"), &Unit::get_health);

    ClassDB::bind_method(D_METHOD("set_type", "type"), &Unit::set_type);
    ClassDB::bind_method(D_METHOD("get_type"), &Unit::get_type);

    ClassDB::bind_method(D_METHOD("take_damage", "amount"), &Unit::take_damage);

    // 2) PROPRIÉTÉS : ADD_PROPERTY → visibles dans l’inspecteur
    ADD_PROPERTY(
        PropertyInfo(Variant::FLOAT, "speed", PROPERTY_HINT_RANGE, "0,1000,1"),
        "set_speed",
        "get_speed"
    );

    ADD_PROPERTY(
        PropertyInfo(Variant::INT, "health", PROPERTY_HINT_RANGE, "0,999,1"),
        "set_health",
        "get_health"
    );

    ADD_PROPERTY(
        PropertyInfo(Variant::INT, "type", PROPERTY_HINT_ENUM, "Infantry,Tank,Aircraft"),
        "set_type",
        "get_type"
    );

    // 3) SIGNAUX : ADD_SIGNAL → GDScript peut se connecter dessus
    ADD_SIGNAL(MethodInfo("health_changed",
        PropertyInfo(Variant::INT, "new_health")
    ));

    ADD_SIGNAL(MethodInfo("unit_died"));

    // 4) ENUM : BIND_ENUM_CONSTANT → accessibles en script
    BIND_ENUM_CONSTANT(UNIT_INFANTRY);
    BIND_ENUM_CONSTANT(UNIT_TANK);
    BIND_ENUM_CONSTANT(UNIT_AIRCRAFT);

    // 5) CONSTANTE :
    BIND_CONSTANT(MAX_UNITS);
}

// ---- Implémentation simple des méthodes ----

void Unit::set_speed(float p_speed) {
    speed = p_speed;
}

float Unit::get_speed() const {
    return speed;
}

void Unit::set_health(int p_health) {
    health = p_health;
    emit_signal("health_changed", health);
    if (health <= 0) {
        emit_signal("unit_died");
    }
}

int Unit::get_health() const {
    return health;
}

void Unit::set_type(UnitType p_type) {
    type = p_type;
}

Unit::UnitType Unit::get_type() const {
    return type;
}

void Unit::take_damage(int p_amount) {
    set_health(health - p_amount);
}
```

#### 5.2.3 Enregistrement dans ton module

```cpp
// register_types.cpp
#include "register_types.h"
#include "core/object/class_db.h"
#include "unit.h"

void initialize_mymodule_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }

    GDREGISTER_CLASS(Unit);
}

void uninitialize_mymodule_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
}
```

#### 5.2.4 Utilisation côté GDScript

Exemple de Node scripté (le Unit est dans la scène)
```cpp
# UnitController.gd
extends Node2D

@onready var unit: Unit = $Unit   # suppose que tu as un Node "Unit" dans la scène

func _ready() -> void:
    # Connexion des signaux C++
    unit.connect("health_changed", Callable(self, "_on_unit_health_changed"))
    unit.connect("unit_died", Callable(self, "_on_unit_died"))

    # Utilisation des propriétés exposées
    unit.speed = 250.0  # grâce à ADD_PROPERTY + set_speed/get_speed
    unit.health = 80

    # Utilisation de l’enum exposé
    unit.type = Unit.UNIT_TANK

    # Appel de méthode C++ bindée
    unit.take_damage(30) # va émettre "health_changed"

func _on_unit_health_changed(new_health: int) -> void:
    print("HP de l’unité :", new_health)

func _on_unit_died() -> void:
    print("L’unité est morte, faire quelque chose ici.")
```

Exemple de création d’Unit à la volée en GDScript

```cpp
func _ready() -> void:
    var u := Unit.new()
    add_child(u)

    u.connect("unit_died", Callable(self, "_on_dynamic_unit_died"))

    u.speed = 150.0
    u.health = 50
    u.type = Unit.UNIT_INFANTRY

    u.take_damage(60) # déclenche unit_died

func _on_dynamic_unit_died() -> void:
    print("Une unité créée en runtime est morte.")
```
