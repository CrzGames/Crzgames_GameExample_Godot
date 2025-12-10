# 📘 Godot 4.x — Cycle de Vie Complet d’un `Node`

Ce document explique **toutes les méthodes du cycle de vie d’un Node**, leur ordre réel d’appel, et leur usage recommandé — de manière **claire, concise et structurée**.

---

# 🔵 1. Vue d’ensemble — Ordre réel d’appel

Quand un Node est instancié et ajouté à la scène, Godot appelle les callbacks suivants :

1. **_init()** (GDScript) / constructeur C++  
2. **_enter_tree()**  
3. **_ready()**  
4. **_process( delta )**
5. **_physics_process( delta )**
6. **_input( event )**  
7. **_shortcut_input( event )**  
8. **_unhandled_input( event )**  
9. **_unhandled_key_input( event )**  
10. **_exit_tree()**

---

# 🔵 2. Description détaillée de chaque méthode

---

## 2.1 `_init()`  
📌 **Appelé lors de l’instanciation de l’objet.**  
En C++, ceci correspond au **constructeur**.

### ✔ Utilisation recommandée
- Initialiser des variables
- Préparer des structures internes

### ❌ Ne pas faire
- Accéder à d'autres Nodes  
- Appeler `get_tree()` ou `get_parent()`

---

## 2.2 `_enter_tree()`  
📌 **Appelé lorsque le Node entre dans l’arbre de scène.**  
C’est le premier moment où le Node est “vivant” dans le SceneTree.

### ✔ Utilisation recommandée
- Récupérer le parent : `get_parent()`
- Accéder aux autres Nodes déjà dans l’arbre
- Connecter des signaux dynamiques entre Nodes

### ❗ Important
- Les enfants n’ont *pas encore* reçu leur `_enter_tree()` si on est dans un parent.

---

## 2.3 `_ready()`  
📌 **Appelé lorsque le Node et tous ses enfants sont complètement dans l’arbre.**

C’est **le moment idéal pour accéder à tout dans ta scène**.

### ✔ Utilisation recommandée
- Accéder aux children (`$Sprite`, `$Camera2D`)  
- Charger des ressources  
- Lancer des timers, tweens, animations  
- Initialiser le gameplay

### 🧠 Ordre d’appel
- `_enter_tree()` du parent  
- `_enter_tree()` des enfants  
- `_ready()` **des enfants d’abord**  
- `_ready()` du parent

---

## 2.4 `_process(delta)`  
📌 **Appelé à chaque frame**, si `set_process(true)`.

### ✔ Utilisation recommandée
- Logique dépendante du framerate
- Animation manuelle
- Calculs légers

### ❌ Ne pas utiliser pour la physique !

---

## 2.5 `_physics_process(delta)`  
📌 Appelé **à fréquence fixe (60 FPS)** si `set_physics_process(true)`.

### ✔ Utilisation recommandée
- Mouvement du personnage  
- Gestion des forces  
- Détection collision  
- Code nécessitant un timestep fixe

---

## 2.6 `_input(event)`  
📌 Appelé pour **tous** les événements d'entrée *avant* propagation.

### ✔ Utilisation recommandée
- Interfaces personnalisées  
- Capture directe d'événements (ex. remapper touches)

### ❗ Peut interférer avec les `Control`.

---

## 2.7 `_shortcut_input(event)`  
📌 Appelé avant `_unhandled_input()` si un raccourci est détecté.

Exemple : un `Button` avec un raccourci clavier.

---

## 2.8 `_unhandled_input(event)`  
📌 Appelé **si aucun Control n’a consommé l’input**.

### ✔ Utilisation recommandée
- Gameplay (tir, saut...) sans perturber l’UI  
- Contrôles globaux (pause, caméra)

---

## 2.9 `_unhandled_key_input(event)`  
📌 Comme ci-dessus, mais uniquement pour les **touches clavier**.

### Utilisation
- Saisie texte avancée  
- Raccourcis clavier globaux

---

## 2.10 `_exit_tree()`  
📌 Appelé quand le Node quitte l’arbre de scène.

### ✔ Utilisation recommandée
- Déconnecter des signaux  
- Libérer des ressources  
- Sauvegarder état temporaire

---

# 🔵 3. Résumé ultra-compact

| Méthode | Quand ? | Pour quoi faire ? |
|--------|---------|-------------------|
| `_init()` | Instanciation | Initialisation interne |
| `_enter_tree()` | Le Node entre dans la scène | Connexions, accès au parent |
| `_ready()` | Tout est prêt | Setup gameplay, accès aux enfants |
| `_process()` | Chaque frame | Logique non-physique |
| `_physics_process()` | 60 FPS | Physique |
| `_input()` | Tout input brut | Interaction immédiate |
| `_shortcut_input()` | Input lié à un raccourci | Gestion raccourcis |
| `_unhandled_input()` | Input ignoré par l'UI | Gameplay |
| `_unhandled_key_input()` | Clavier non-handled | Hotkeys |
| `_exit_tree()` | Sortie scène | Cleanup |

---

# 🔵 4. Exemple complet (GDScript)

```gdscript
extends Node

func _init():
    print("Init")

func _enter_tree():
    print("Enter tree")

func _ready():
    print("Ready")

func _process(delta):
    print("Process")

func _physics_process(delta):
    print("Physics process")

func _input(event):
    print("Input event")

func _unhandled_input(event):
    print("Unhandled input")

func _exit_tree():
    print("Exit tree")
```

---

# 🔵 5. Exemple complet en C++ (Module / GDExtension)

### Header : `my_node.h`

```cpp
#pragma once

#include "scene/main/node.h"

class MyNode : public Node {
    GDCLASS(MyNode, Node);

protected:
    static void _bind_methods();

public:
    MyNode(); // Constructeur
    ~MyNode() override = default;

    void _enter_tree() override;
    void _ready() override;
    void _process(double p_delta) override;
    void _physics_process(double p_delta) override;
    void _input(const Ref<InputEvent> &p_event) override;
    void _unhandled_input(const Ref<InputEvent> &p_event) override;
    void _unhandled_key_input(const Ref<InputEvent> &p_event) override;
    void _exit_tree() override;
};
```

### Implémentation : `my_node.cpp`

```cpp
#include "my_node.h"
#include "core/object/class_db.h"
#include "core/io/logger.h"

void MyNode::_bind_methods() {
    // Pas obligatoire pour le cycle de vie,
    // mais tu peux binder d’autres méthodes/propriétés ici.
}

MyNode::MyNode() {
    // Constructeur : init C++ pur
    print_line("MyNode::MyNode - constructeur");
}

void MyNode::_enter_tree() {
    print_line("MyNode::_enter_tree()");
}

void MyNode::_ready() {
    print_line("MyNode::_ready()");

    // Activer les différents process
    set_process(true);
    set_physics_process(true);
    set_process_input(true);
    set_process_unhandled_input(true);
    set_process_unhandled_key_input(true);
}

void MyNode::_process(double p_delta) {
    // Logique par frame
    // print_line(vformat("MyNode::_process( delta = %f )", p_delta));
}

void MyNode::_physics_process(double p_delta) {
    // Logique physique
    // print_line(vformat("MyNode::_physics_process( delta = %f )", p_delta));
}

void MyNode::_input(const Ref<InputEvent> &p_event) {
    // print_line("MyNode::_input()");
}

void MyNode::_unhandled_input(const Ref<InputEvent> &p_event) {
    // print_line("MyNode::_unhandled_input()");
}

void MyNode::_unhandled_key_input(const Ref<InputEvent> &p_event) {
    // print_line("MyNode::_unhandled_key_input()");
}

void MyNode::_exit_tree() {
    print_line("MyNode::_exit_tree()");
}
```

### Enregistrement dans le module

Dans `register_types.cpp` de ton module :

```cpp
#include "register_types.h"
#include "core/object/class_db.h"
#include "my_node.h"

void initialize_mymodule_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }

    GDREGISTER_CLASS(MyNode);
}

void uninitialize_mymodule_module(ModuleInitializationLevel p_level) {
    if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
        return;
    }
}
```
