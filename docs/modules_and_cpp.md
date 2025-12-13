# 📘 Godot 4.x — Modules C++  
## Créer ses propres types, modules et architecture C++

Ce document est un **guide complet et structuré** pour travailler avec des **modules C++ natifs dans Godot 4.x**.

Il explique notamment comment :

- créer un module C++ pour Godot (intégré ou via `custom_modules`) ;
- comprendre **quand et pourquoi utiliser `GDCLASS` / `GDREGISTER_*`** ;
- organiser du **C++ “pur”** pour une vraie POO sans dépendance inutile au moteur ;
- exposer correctement des **types Godot** (Nodes, Resources, classes runtime) ;
- maîtriser le **système de binding** (`_bind_methods`, propriétés, signaux, enums) ;
- gérer les **limites internes du moteur** (nombre de paramètres, fichiers générés) ;
- nettoyer et maintenir un build propre avec **SCons** ;
- accélérer fortement les itérations en dev grâce à la **compilation en bibliothèque partagée** (DEV) tout en gardant une **compilation statique** pour la production ;
- **override / remplacer un module intégré** du moteur par une implémentation custom.

<br />

---

## 📑 Sommaire

- [0. Structure minimale d’un module C++ Godot](#0-structure-minimale-dun-module-c-godot)
- [1. Où mettre le module ?](#1-où-mettre-le-module)
- [2. `register_types.h / register_type.cpp` : ce qui est obligatoire et ce qui ne l’est pas](#2-register_typesh--register_typecpp--ce-qui-est-obligatoire-et-ce-qui-ne-lest-pas)
- [3. Fichiers de build : `SCsub` et `config.py`](#3-fichiers-de-build--scsub-et-configpy)

- [4. Les 5 types de classes C++ dans Godot](#4-les-5-types-de-classes-c-dans-godot)
  - [4.1 Classe C++ pure (non Godot et non exposée)](#41-classe-c-pure-non-godot-et-non-exposée)
  - [4.2 Classe interne Godot (non exposée)](#42-classe-interne-godot-non-exposée)
  - [4.3 Classe abstraite Godot (exposée)](#43-classe-abstraite-godot-exposée)
  - [4.4 Classe Godot (exposée)](#44-classe-godot-exposée)
  - [4.5 Classe runtime Godot (exposée)](#45-classe-runtime-godot-exposée)
  - [4.6 Fichier complet final pour : `register_types.cpp`](#46-fichier-complet-final-pour--register_typescpp)

- [5. `_bind_methods()` : exposer des éléments à Godot](#5-_bind_methods--exposer-des-éléments-à-godot)
  - [5.1 Ce qu’on peut exposer](#51-ce-quon-peut-exposer)
  - [5.2 Exemple complet : classe Unit côté C++](#52-exemple-complet--classe-unit-côté-c)

- [6. Augmenter le nombre de paramètres bindés d'une méthode d'une classe C++ (5 par défaut → 13`)](#6-augmenter-le-nombre-de-paramètres-bindés-dune-méthode-dune-classe-c-5-par-défaut--13-avec-include-coremethod_bind_extgeninc)
  - [6.1 Activer le nombre de paramètre étendu d'une méthode (jusqu’à 13 paramètres au lieu de 5)](#61-activer-le-nombre-de-paramètre-étendu-dune-méthode-jusquà-13-paramètres-au-lieu-de-5)
  - [6.2 Recommandation (design)](#62-recommandation-design)

- [7.0 Nettoyage des fichiers générés par SCons](#70-nettoyage-des-fichiers-générés-par-scons)
  - [7.1 Quand faut-il nettoyer ?](#71-quand-faut-il-nettoyer-)
  - [7.2 Nettoyage avec SCons](#72-nettoyage-avec-scons)
  - [7.3 Bonnes pratiques](#73-bonnes-pratiques)

- [8.0 Override d'un module C++ intégrée par Godot Engine par notre propre module](#80-override-dun-module-intégrée-par-godot-engine-par-notre-propre-module)
  - [8.1 Principe général](#81-principe-général)
  - [8.2 Règle essentielle](#82-règle-essentielle)
  - [8.3 Cas d’usage concrets](#83-cas-dusage-concrets)
  - [8.4 Résumé rapide](#84-résumé-rapide)

- [9. Compilation d’un module C++ : statique (Template) vs bibliothèque partagée (Editor)](#9-compilation-dun-module-c--statique-template-vs-bibliothèque-partagée-editor)
  - [9.1 Principe général](#91-principe-général)
  - [9.2 SCsub unique avec switch DEV (Editor) / PROD (Template)](#92-scsub-unique-avec-switch-dev-editor--prod-template)
  - [9.3 Commandes SCons](#93-commandes-scons)
  - [9.4 Règle absolue : jamais de bibliothèque partagée en production](#-règle-absolue)

<br />

---

<br />

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

<br />

---

<br />

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

<br />

---

<br />

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

Vous **devez obligatoirement** fournir ces deux fonctions pour que Godot reconnaisse et intègre le module.

Le **nom des fonctions** (`initialize_summator_module` / `uninitialize_summator_module`) doit **correspondre exactement** au nom du dossier du module (`summator` dans cet exemple).

En revanche, vous **n’êtes pas obligé** d’y appeler `GDREGISTER_CLASS`, `GDREGISTER_ABSTRACT_CLASS`, etc.  
Un module peut parfaitement exister **sans exposer de classes à Godot**, par exemple pour :
- de la logique interne ;
- des utilitaires C++ ;
- du code bas niveau non accessible depuis GDScript.


<br />

---

<br />

## 3. Fichiers de build : `SCsub` et `config.py`

Exemple minimal :

```python
# SCsub
Import('env')


# Créer un environnement de build séparé
env.add_source_files(env.modules_sources, "*.cpp") # Ajouter tous les fichiers .cpp à la compilation


# Pour ajouter des répertoires d'inclusion que le compilateur doit prendre en compte, comme des libraries externes, vous pouvez les ajouter aux chemins d'accès de l'environnement :
# env.Append(CPPPATH=["mylib/include"]) # Il s'agit d'un chemin relatif
# env.Append(CPPPATH=["#myotherlib/include"]) # il s'agit d'un chemin absolu


# Si vous souhaitez ajouter des options de compilation personnalisées lors de la création de votre module, vous devez d'abord cloner l'environnement afin que ces options ne soient pas ajoutées à l'ensemble de la compilation Godot (ce qui peut entraîner des erreurs).
# Ajouter les indicateurs CCFLAGS au code C et C++ : 
# module_env.Append(CCFLAGS=['-O2'])
```

```python
# config.py

# Documentation :
# Le module est interrogé pour savoir s'il est possible de le compiler pour la plateforme spécifique (dans ce cas, True signifie qu'il sera compilé pour toutes les plateformes).

def can_build(env, platform):
    return True

def configure(env):
    pass
```

<br />

---

<br />

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

<br />

---

<br />

## 5. _bind_methods() : exposer des éléments à Godot

Documentation officiel pour plus de détaille : https://docs.godotengine.org/fr/4.5/engine_details/architecture/object_class.html

**_bind_methods()** est la fonction centrale qui construit le pont C++ → Godot.

### 5.1 Ce qu’on peut exposer
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

<br />

---

<br />

## 6. Augmenter le nombre de paramètres bindés d'une méthode d'une classe C++ (5 par défaut → 13 avec `#include "core/method_bind_ext.gen.inc"`)

Quand tu exposes des méthodes C++ d'une classe à Godot avec :

```cpp
ClassDB::bind_method(D_METHOD("my_func", "..."), &MyClass::my_func);
```

Godot utilise un système interne de *MethodBind* qui, **par défaut**, ne fournit les surcharges/templates que jusqu’à **5 paramètres**.

✅ Donc : une méthode exposée avec **0 à 5 paramètres** marche.  
⚠️ Si tu veux exposer une méthode avec **6 à 13 paramètres**, tu dois activer les binders étendus.

### 6.1 Activer le nombre de paramètre étendu d'une méthode (jusqu’à 13 paramètres au lieu de 5)

Il suffit d’inclure le header suivant **dans le `.cpp` où tu fais tes `bind_method`** (souvent le fichier qui contient `_bind_methods()`) :

```cpp
#include "my_class.h"

#include "core/object/class_db.h"
#include "core/method_bind_ext.gen.inc" // Permet de binder des méthodes jusqu'à 13 paramètres
```

Ensuite tu peux binder une méthode avec plus de 5 paramètres :

```cpp
// my_class.h
class MyClass : public Object {
    GDCLASS(MyClass, Object);

protected:
    static void _bind_methods();

public:
    void do_big_thing(int a, int b, int c, int d, int e, int f);
};
```

```cpp
// my_class.cpp
#include "my_class.h"

#include "core/object/class_db.h"
#include "core/method_bind_ext.gen.inc" // Permet de binder des méthodes jusqu'à 13 paramètres

void MyClass::do_big_thing(int a, int b, int c, int d, int e, int f) {
    // ...
}

void MyClass::_bind_methods() {
    ClassDB::bind_method(
        D_METHOD("do_big_thing", "a", "b", "c", "d", "e", "f"),
        &MyClass::do_big_thing
    );
}
```

### 6.2 Recommandation (design)

Même si tu peux monter à **13**, au-delà de ~5 paramètres, c’est souvent plus propre côté Godot de regrouper les paramètres dans :

- une `Dictionary` (paramètres nommés) ;
- une `Array` ;
- ou une `Resource` / `Object` “Params” (plus typé, plus lisible et plus maintenable).

> 💡 Astuce : si tu commences à avoir des signatures très longues, c’est souvent le signe qu’il faut regrouper ces valeurs dans une structure dédiée.

<br />

---

<br />

## 7.0 Nettoyage des fichiers générés par SCons

Lors du développement de modules C++ ou lors de changements importants dans la configuration de build (options SCons, modules, plateformes, flags…), il peut arriver que Godot échoue à compiler à cause de **fichiers générés obsolètes**.

Ces fichiers sont produits automatiquement par SCons lors des précédentes compilations.

### 7.1 Quand faut-il nettoyer ?

Il est recommandé de faire un nettoyage complet dans les cas suivants :

- erreurs de compilation incohérentes ou inexpliquées ;
- ajout / suppression d’un module C++ ;
- changement de `custom_modules` ;
- changement de plateforme (`platform=windows`, `linux`, `android`, etc.) ;
- modification importante des options de build (`target`, `tools`, `production`, etc.).

### 7.2 Nettoyage avec SCons

Godot fournit une commande dédiée via SCons :

```bash
scons --clean <options>
```

⚠️ **Important** :  
Les `<options>` doivent être **strictement identiques** à celles utilisées lors de la compilation précédente.

#### Exemple concret

Si tu as compilé Godot avec :

```bash
scons platform=windows target=editor custom_modules=..\..\modules
```

Alors le nettoyage doit être fait avec **exactement les mêmes options** :

```bash
scons --clean platform=windows target=editor custom_modules=..\..\modules
```

Cela va :
- supprimer les fichiers `.o`, `.obj`, `.gen.*`, etc. ;
- forcer une recompilation propre au prochain build ;
- éviter des erreurs liées à des fichiers générés incompatibles.

### 7.3 Bonnes pratiques

- Toujours nettoyer après une **erreur étrange** ou non reproductible.
- Toujours nettoyer après avoir **ajouté ou renommé un module**.
- En CI, privilégier un workspace propre pour éviter ces problèmes.

<br />

---

<br />

## 8.0 Override d'un module intégrée par Godot Engine par notre propre module

Godot permet de **remplacer un module intégré du moteur** par un **module personnalisé**, sans modifier le code source original du moteur.

### 8.1 Principe général

👉 **Si un module personnalisé possède exactement le même nom de dossier qu’un module intégré**,  
**Godot ne compilera que le module personnalisé**.

Le module intégré est alors **ignoré**.

### 8.2 Règle essentielle

Le nom du dossier du module personnalisé doit être **strictement identique** au module intégré ciblé.

#### Exemple

Module intégré :

```text
godot/modules/navigation/
```

Module custom (à nous) :

```text
modules/navigation/
```

Compilation :

```bash
scons custom_modules=..\..\modules
```

➡️ Résultat :
- `modules/navigation/` notre module à nous est utilisé ;
- `godot/modules/navigation/` module intégré à Godot Engine est ignoré.

### 8.3 Cas d’usage concrets

- corriger ou modifier un module existant ;
- expérimenter une implémentation alternative ;
- désactiver une feature intégrée sans patcher le moteur.

### 8.4 Résumé rapide

| Situation | Comportement |
|---------|--------------|
| Nom différent | Les modules coexistent |
| Nom de module identique | Le module à nous remplace le module intégré par Godot Engine |

<br />

---

<br />

## 9.0 Compilation d'un module C++ : statique (Template) vs bibliothèque partagée (Editor)

⚠️ Disponible que pour macOS et Linux/BSD concernant les bibliothèque partagée pendant la phase de développement d'un module C++ Godot, en attente d'une PR pour que Godot fasse fonctionner sous Windows avec MSVC. Donc pour la phase de développement sous Windows/MSVC il faudras utiliser la compilation static pour l'editeur comme pour les Template.

Lors du développement d’un module C++ Godot, **le temps de compilation devient rapidement un problème**.

Par défaut, un module est compilé **statiquement** dans le binaire Godot.  
C’est **parfait pour la production**, mais **très pénalisant pendant le développement**, car :

- chaque modification du module :
  - déclenche un **relink du binaire Godot** ;
  - rallonge fortement le **temps de build** ;
- même si **un seul fichier `.cpp` change**, le binaire final doit être reconstruit.

👉 Pour résoudre ce problème **pendant le développement**, Godot permet de compiler un module sous forme de **bibliothèque partagée** (`.so` et `.dylib`) chargée dynamiquement au lancement.

---

### 9.1 Principe général

L’idée est simple :

#### 🔧 Développement
- le module est compilé en **bibliothèque partagée** ;
- recompilation **rapide** ;
- itérations fréquentes et confortables.

#### 🚀 Production
- le module est compilé **statiquement** ;
- un **seul binaire Godot** ;
- déploiement propre, fiable et portable.

---

### 9.2 SCsub unique avec switch DEV (Editor) / PROD (Template)

```python
# SCsub
Import('env')

sources = Glob("*.cpp")

# Commencez par créer un environnement personnalisé pour la bibliothèque partagée.
module_env = env.Clone()

# Pour ajouter des répertoires d'inclusion que le compilateur doit prendre en compte, comme des libraries externes, 
# vous pouvez les ajouter aux chemins d'accès de l'environnement :
# env.Append(CPPPATH=["mylib/include"]) # Il s'agit d'un chemin relatif
# env.Append(CPPPATH=["#myotherlib/include"]) # il s'agit d'un chemin absolu

# Si vous souhaitez ajouter des options de compilation personnalisées lors de la création de votre module, vous devez d'abord cloner l'environnement afin que ces options ne soient pas ajoutées à l'ensemble de la compilation Godot (ce qui peut entraîner des erreurs).
# Ajouter les indicateurs CCFLAGS au code C et C++ : 
# module_env.Append(CCFLAGS=['-O2']) # Exemple d'optimisation de compilation

platform = env.get("platform", "")

if ARGUMENTS.get("summator_shared", "no") == "yes" and env["platform"] in ("linuxbsd", "macos"):
    # ==========================
    # DEV : bibliothèque partagée
    # ==========================

    if platform in ("linuxbsd", "macos"):
        # On ne veut pas embarquer les libs Godot dans la DLL
        module_env["LIBS"] = []
        # Un code indépendant de la position est requis pour une bibliothèque partagée.
        module_env.Append(CCFLAGS=["-fPIC"])

    if env["platform"] == "linuxbsd":
        # Le module .so résout des symboles depuis l'exécutable Godot
        module_env.Append(LINKFLAGS=["-rdynamic"])

    if env["platform"] == "macos":
        # Ceci indique à l'éditeur de liens que les symboles sont externes et seront donc liés dynamiquement.
        # Requirements : Xcode 15 ou une version ultérieure
        module_env.Append(LINKFLAGS=["-Wl,-undefined,dynamic_lookup"])

    # Définir la bibliothèque partagée. Par défaut, elle serait créée dans le dossier du module,
    # mais il est préférable de la placer dans `bin` à côté du binaire Godot.
    # Génère la lib partagée dans /bin à côté du binaire Godot
    # - Linux/BSD : libsummator.*.so
    # - macOS     : libsummator.*.dylib
    shared_lib = module_env.SharedLibrary(
        target='#bin/summator',
        source=sources
    )
        
    # Enfin, notifiez l'environnement de compilation principal qu'il dispose désormais de notre bibliothèque partagée
    # comme nouvelle dépendance.
    # Les variables d'environnement LIBPATH et LIBS doivent être définies dans l'environnement réel (et non dans le clone)
    # afin de lier les bibliothèques spécifiées à l'exécutable Godot.
    env.Append(LIBPATH=['#bin'])

    # SCons souhaite le nom de la bibliothèque avec ses suffixes personnalisés
    # (par exemple « .linuxbsd.tools.64 ») mais sans l'extension finale « .so ».
    shared_lib_shim = shared_lib[0].name.rsplit(".", 1)[0]
    # Ajouter la bibliothèque partagée aux bibliothèques à lier
    env.Append(LIBS=[shared_lib_shim])
    
else:
    # ==========================
    # PROD : compilation statique
    # ==========================
    module_env.add_source_files(env.modules_sources, sources)
```

---

### 9.3 Commandes SCons

#### 🔧 Développement (bibliothèque partagée) - Pour l'editeur Godot pendant la phase de développement

##### Linux/BSD
```bash
scons platform=linuxbsd target=editor profile=../../build-scripts/build_profile_editor.py custom_modules=../../modules summator_shared=yes redirect_build_objects="no"
```

Compilation ciblée (accélérer la compilation en spécifiant explicitement votre module partagé comme cible) :
```bash
scons platform=linuxbsd target=editor profile=../../build-scripts/build_profile_editor.py custom_modules=../../modules summator_shared=yes redirect_build_objects="no" bin/libsummator.linuxbsd.tools.64.so
```

##### macOS
```bash
scons platform=macos target=editor profile=../../build-scripts/build_profile_editor.py custom_modules=../../modules summator_shared=yes redirect_build_objects="no"
```

Compilation ciblée (accélérer la compilation en spécifiant explicitement votre module partagé comme cible) :
```bash
scons platform=macos target=editor profile=../../build-scripts/build_profile_editor.py custom_modules=../../modules summator_shared=yes redirect_build_objects="no" bin/libsummator.?.tools.64.dylib
```

##### Windows (⚠️Pas de bibliothèque dynamique, compilation static même pour l'editeur Godot sous Windows)
```bash
scons platform=windows target=editor vsproj=yes vsproj_gen_only=no profile=..\..\build-scripts\build_profile_editor.py custom_modules=..\..\modules summator_shared=no
```

---

#### 🚀 Production (compilation statique) - Pour les templates (binaire du jeu)

##### Linux / BSD
```bash
scons platform=linuxbsd target=template_release profile=../../build-scripts/build_profile_template_prod.py custom_modules=../../modules summator_shared=no
```

##### macOS
```bash
scons platform=macos target=template_release profile=../../build-scripts/build_profile_template_prod.py custom_modules=../../modules summator_shared=no
```

##### Windows
```bash
scons platform=macos target=template_release profile=..\..\build-scripts\build_profile_template_prod.py custom_modules=..\..\modules summator_shared=no
```

---

### ⚠️ Règle absolue : jamais de bibliothèque partagée en production

> **Ne jamais livrer un jeu Godot avec un module compilé en bibliothèque partagée.**

La bibliothèque partagée est **strictement réservée au développement**.
