# Modules C++ Godot – Créer ses propres types et architecture C++

Ce document explique comment :

- créer un module C++ pour Godot (exemple : `summator`) ;
- comprendre **quand il faut `GDCLASS` / `ClassDB::register_class`** ;
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
  - C’est **ici** que l’on appelle `ClassDB::register_class<T>()` si l’on veut exposer des types (class) au moteur (GDScript / éditeur).

- `*.h` / `*.cpp`  
  - Vos classes C++ :
    - soit **pures** (sans `GDCLASS`, non exposées, POO C++ normale) ;
    - soit **exposées** à Godot (`GDCLASS` + `ClassDB::register_class`).

Ensuite, ce dossier de module doit être **placé à un endroit visible par le build** (voir section suivante).

---

## 1. Où mettre le module ?

Vous pouvez soit :

- mettre votre module **dans le dossier `modules/` du moteur Godot**, par ex. :

```text
godot/              # code sources du moteur
  modules/
    summator/
      config.py
      SCsub
      register_types.h
      register_types.cpp
      summator.h
      summator.cpp
```

- La meilleur méthode pour séparer du code du moteur : utiliser un dossier **externe** et le passer à SCons via `custom_modules`, par ex. :

```text
<repo>/              # notre repo
  dependencies/
    godot/           # code sources du moteur
  modules/           # notre dossier modules à nous et pas directement le dossier modules du moteur Godot
    summator/
      ...
```

Compilation :

```bash
# Exemple simple sous Windows
cd dependencies/godot
scons platform=windows target=editor custom_modules=../modules
```

---

## 2. Exposée ou non nos classes C++ dans Godot

### 2.1. Classe C++ non exposée à Godot

Si vous écrivez une simple classe C++ comme ceci :

```cpp
class InternalAccumulator {
    int value = 0;

public:
    void add(int v) { value += v; }
    void reset() { value = 0; }
    int get_total() const { return value; }
};
```

- pas de `GDCLASS` ;
- pas de `ClassDB::register_class` ;
- pas d’héritage depuis `Object`/`RefCounted`/`Node`..etc

👉 Cette classe est **invisible pour Godot** (GDScript, inspecteur, scènes),  
mais **totalement utilisable dans votre code C++**, comme dans n’importe quel projet C++ classique.

Vous pouvez l’utiliser à l’intérieur d’autres classes C++ (y compris des Nodes/Class exposés) pour faire autant de POO que vous voulez : héritage multiple, interfaces, patterns, etc.

### 2.2. Classe C++ exposé à Godot

Pour qu’une classe soit **visible dans Godot** (instanciable en GDScript, listée dans le ClassDB, utilisable comme type de propriété), il faut :

1. qu’elle **hérite d’un type Godot** (`Object`, `RefCounted`, `Node`, `Resource`, etc.) ;
2. qu’elle ait la macro `GDCLASS` à l'intérieur de la class ;
3. qu'elle bind les methods pour les exposés
3. qu’elle soit enregistrée avec `ClassDB::register_class<MyClass>()` dans le module.

Exemple :

```cpp
// summator.h
#ifndef SUMMATOR_H
#define SUMMATOR_H

#include "core/object/ref_counted.h"

class Summator : public RefCounted {
    GDCLASS(Summator, RefCounted);

    int count = 0;

protected:
    static void _bind_methods();

public:
    void add(int p_value);
    void reset();
    int get_total() const;

    Summator();
};

#endif // SUMMATOR_H
```

```cpp
// summator.cpp
#include "summator.h"
#include "core/object/class_db.h"

void Summator::add(int p_value) {
    count += p_value;
}

void Summator::reset() {
    count = 0;
}

int Summator::get_total() const {
    return count;
}

void Summator::_bind_methods() {
    ClassDB::bind_method(D_METHOD("add", "value"), &Summator::add);
    ClassDB::bind_method(D_METHOD("reset"), &Summator::reset);
    ClassDB::bind_method(D_METHOD("get_total"), &Summator::get_total);
}

Summator::Summator() {
    count = 0;
}
```

Dans `register_types.cpp` :

```cpp
#include "register_types.h"
#include "core/object/class_db.h"
#include "summator.h"

void initialize_summator_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }

    // Enregistre Summator dans le ClassDB → visible en GDScript
    ClassDB::register_class<Summator>();
}

void uninitialize_summator_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
    // Rien à faire ici dans cet exemple.
}
```

À partir de là, dans GDScript :

```gdscript
func _ready():
    print(ClassDB.class_exists("Summator")) # true
    var s := Summator.new()
    s.add(10)
    s.add(20)
    print(s.get_total()) # 30
```

👉 **Conclusion :**  
- Sans `GDCLASS` + `register_class` → la classe n’existe que côté C++.  
- Avec `GDCLASS` + `register_class` → la classe devient un vrai type Godot, utilisable depuis GDScript / l’éditeur.

---

## 3. `register_types.*` : ce qui est obligatoire et ce qui ne l’est pas

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
    // Exemple : ClassDB::register_class<Summator>();
}

void uninitialize_summator_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
}
```

Vous **êtes obligé** de fournir ces fonctions pour que le module soit intégré,  
mais **vous n’êtes pas obligé** d’y appeler `ClassDB::register_class` si vous ne voulez rien exposer à Godot.

---

## 4. Fichiers de build : `SCsub` et `config.py`

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

## 5. Créer un “vrai” type ajoutable dans l’éditeur (Node custom)

Pour avoir un **Node** custom que l’on peut :

- ajouter via le bouton **“+ Add Node”**,
- voir dans l’arborescence de scène,
- avec des **propriétés éditables dans l’inspecteur**,

il faut :

1. hériter de `Node` (ou `Node2D`, `CharacterBody2D`, etc.) ;
2. utiliser la macro `GDCLASS` dans la nouvelle class créer ;
3. enregistrer la classe via `ClassDB::register_class` ;
4. binder des propriétés via `_bind_methods` et `ADD_PROPERTY`.

### Exemple : `MySystemNode`

```cpp
// my_system_node.h
#ifndef MY_SYSTEM_NODE_H
#define MY_SYSTEM_NODE_H

#include "scene/main/node.h"

class MySystemNode : public Node {
    GDCLASS(MySystemNode, Node);

    int speed = 10;

protected:
    static void _bind_methods();

public:
    void set_speed(int p_speed);
    int get_speed() const;

    void _process(double p_delta) override;
};

#endif // MY_SYSTEM_NODE_H
```

```cpp
// my_system_node.cpp
#include "my_system_node.h"
#include "core/object/class_db.h"
#include "core/io/logger.h"

void MySystemNode::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_speed", "speed"), &MySystemNode::set_speed);
    ClassDB::bind_method(D_METHOD("get_speed"), &MySystemNode::get_speed);

    // Déclare une propriété visible dans l’inspecteur
    ADD_PROPERTY(
        PropertyInfo(Variant::INT, "speed", PROPERTY_HINT_RANGE, "0,100,1"),
        "set_speed",
        "get_speed"
    );
}

void MySystemNode::set_speed(int p_speed) {
    speed = p_speed;
}

int MySystemNode::get_speed() const {
    return speed;
}

void MySystemNode::_process(double p_delta) {
    // Exemple : logique 100% C++ exécutée chaque frame
    // print_line("MySystemNode running, speed = " + String::num(speed));
}
```

Dans `register_types.cpp` du module :

```cpp
#include "register_types.h"
#include "core/object/class_db.h"
#include "my_system_node.h"

void initialize_mymodule_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }

    ClassDB::register_class<MySystemNode>();
}
```

Après compilation :

- Dans l’éditeur, bouton **“+ Add Node”**, cherchez `MySystemNode` → il apparaît.
- Quand vous le sélectionnez dans la scène, l’inspecteur affiche la propriété **`speed`**, éditable.

👉 C’est comme ça que vous ajoutez **de vrais types custom** au moteur, utilisables comme n’importe quel Node natif.

---

### 6. POO et limitations quand une classe est exposée à Godot

Exposer une classe à Godot avec :

- un héritage depuis `Object` / `RefCounted` / `Node` / `Resource`, etc. ;
- la macro `GDCLASS(MyClass, BaseClass)` ;
- et `ClassDB::register_class<MyClass>()`

**ne veut pas dire qu’on ne peut plus faire de POO**.  
En revanche, cela impose quelques **contraintes importantes** :

- La classe doit faire partie d’une **chaîne d’héritage unique** basée sur les types Godot  
  (par exemple : `MyEnemy : public CharacterBody2D`, ou `MyData : public Resource`).
- On ne peut pas faire d’**héritage multiple** avec d’autres bases C++ arbitraires en même temps que la base Godot  
  (par ex. `class MyEnemy : public CharacterBody2D, public SomeCppBase` → à éviter).
- Tout ce qui ne rentre pas dans cette hiérarchie doit passer par :
  - de la **composition** (membres C++ “purs”) ;
  - ou des **classes C++ non exposées** (sans `GDCLASS`, non enregistrées).

En pratique, le pattern recommandé est :

- utiliser une classe exposée (Node / Resource) comme **“façade”** visible dans Godot ;
- mettre toute la logique complexe, les patterns, l’héritage multiple, etc. dans des **classes C++ “pures”** internes, non exposées.

Exemple :

```cpp
// Classe interne, POO C++ classique (non exposée)
class InternalAIStateMachine {
public:
    void update(double delta);
};

// Classe exposée à Godot (Node visible dans l’éditeur)
class EnemyController : public Node2D {
    GDCLASS(EnemyController, Node2D);

    InternalAIStateMachine ai; // composition

protected:
    static void _bind_methods();

public:
    void _process(double delta) override {
        ai.update(delta);
    }
};
```

---

## 7. Résumé

- **Sans `GDCLASS` + `ClassDB::register_class` :**
  - votre classe est **invisible** pour Godot (GDScript, inspecteur, scènes) ;
  - mais vous pouvez l’utiliser librement dans votre module C++ ;
  - vous faites de la POO C++ classique (héritage multiple, patterns, etc.).

- **Avec `GDCLASS` + `ClassDB::register_class` :**
  - la classe devient un **vrai type Godot** ;
  - vous pouvez l’instancier depuis GDScript (`MyType.new()`) ;
  - vous pouvez en faire un Node ou un Resource apparaissant dans l’éditeur ;
  - vous pouvez lui ajouter des propriétés éditables dans l’inspecteur via `ADD_PROPERTY`.

- **Pour des systèmes de gameplay propres et performants :**
  - exposez uniquement des **Nodes / Resources “façades”** ;
  - implémentez toute la logique métier en **C++ pur non exposé**.
