# 📘 Godot 4.x — Singletons (Autoload)
## État global et services persistants

Les **Singletons (Autoload)** permettent de définir des **objets toujours présents**
pendant toute l’exécution du jeu, indépendamment des scènes chargées.

Ils servent principalement à :
- conserver un **état global** (score, progression, options),
- exposer des **services transversaux** (audio, sauvegarde, scènes),
- éviter le couplage direct entre scènes.

---

## 📑 Sommaire

- [1. Problème résolu par les Autoloads](#1-problème-résolu-par-les-autoloads)
- [2. Définition et modèle mental](#2-définition-et-modèle-mental)
- [3. Création d’un Autoload (sans dépendre de l’éditeur)](#3-création-dun-autoload-sans-dépendre-de-léditeur)
- [4. Accès et cycle de vie](#4-accès-et-cycle-de-vie)
- [5. Bon usage vs mauvais usage](#5-bon-usage-vs-mauvais-usage)
- [6. Autoload et changement de scène](#6-autoload-et-changement-de-scène)
- [7. GDScript et C++](#7-gdscript-et-c)
- [8. Références](#8-références)

---

## 1. Problème résolu par les Autoloads

Dans Godot :
- chaque **scène** est pensée pour être autonome,
- GDScript **n’a pas de variables globales** par design.

Cela pose un problème courant :
- partager des données entre scènes,
- garder un état persistant lors d’un changement de scène,
- centraliser certaines responsabilités.

👉 Les Autoloads sont la solution officielle à ce besoin.

---

## 2. Définition et modèle mental

Un **Autoload** est :
- un **Node instancié automatiquement** au démarrage du jeu,
- attaché à la racine du **SceneTree** (`/root`),
- **jamais détruit** lors des changements de scène.

Un point fondamental à comprendre :

> Un Autoload **n’est pas une scène de gameplay**,  
> même s’il peut être **techniquement créé à partir d’une scène**.

Il représente un **objet persistant global**, dont le rôle est :
- de fournir un **service**,
- ou de stocker un **état partagé**,
- indépendamment de la scène courante.

Modèle mental à retenir :

```
Autoload = service global / état persistant
Scene    = logique locale / contenu affiché
```

---

### Position réelle dans l’architecture Godot

Hiérarchie simplifiée côté moteur :

```
OS
 └─ MainLoop
     └─ SceneTree
         └─ Viewport racine
             ├─ Autoloads (persistants)
             │   ├─ GameState
             │   ├─ AudioManager
             │   └─ SceneManager
             └─ Scène courante (change au runtime)
```

Les Autoloads sont donc :
- **frères de la scène courante**,
- jamais remplacés lors d’un changement de scène.

---

## 3. Création d’un Autoload (sans dépendre de l’éditeur)

Sur le plan **technique**, un Autoload est :
- un **Node** créé automatiquement par le moteur,
- à partir d’un **script** ou d’une **scène**,
- ajouté au viewport racine **avant toute scène jouable**.

Sur le plan **architectural**, un Autoload est :
- un **service global**,
- ou un **conteneur d’état persistant**,
- jamais un niveau, un écran ou une entité de gameplay.

Exemple minimal :

```gdscript
# res://autoloads/game_state.gd
extends Node

var score := 0
var player_name := "Player"
```

Une fois enregistré comme Autoload au niveau du projet,
il devient accessible globalement :

```gdscript
GameState.score += 10
```

👉 Le point important n’est pas *comment* il est enregistré,
mais **le rôle architectural** qu’il joue.

---

## 4. Accès et cycle de vie

- Les Autoloads sont créés **avant la scène principale**
- Leur `_ready()` est appelé **avant celui des scènes**
- Ils apparaissent dans l’arbre :

```
/root
 ├─ GameState
 ├─ AudioManager
 └─ MainScene
```

⚠️ Un Autoload **ne doit jamais être libéré manuellement** :

```gdscript
# INTERDIT
queue_free()
free()
```

Cela peut provoquer un crash moteur.

---

## 5. Bon usage vs mauvais usage

### ✔ Bon usage

Un Autoload doit :
- avoir **une responsabilité claire**,
- exposer des données ou des services,
- rester **indépendant des scènes concrètes**.

Exemples typiques :
- `GameState` → progression, score, flags
- `AudioManager` → musique, SFX
- `SaveManager` → sauvegarde / chargement
- `SceneManager` → transitions de scènes
- `EventBus` → signaux globaux

---

### ❌ Mauvais usage

Un Autoload **ne doit pas** :
- référencer directement des nodes de gameplay,
- accéder au Player, UI ou Level en dur,
- centraliser toute la logique du jeu.

Exemples à éviter :

```gdscript
# Couplage direct à une scène
GameState.player.health -= 10
```

```gdscript
# Autoload "Dieu"
Game.save()
Game.load()
Game.play_sound()
Game.spawn_enemy()
Game.change_scene()
```

➡ Problèmes :
- fort couplage,
- difficile à tester,
- fragile lors des changements de scène.

👉 Préférer **plusieurs Autoloads spécialisés** plutôt qu’un seul global.

---

## 6. Autoload et changement de scène

Changer de scène **pendant l’exécution du code courant**
peut provoquer des comportements indéfinis.

Règle :
> Toute modification lourde de l’arbre doit être **différée**.

Exemple : Autoload `SceneManager`

```gdscript
extends Node

var current_scene: Node

func _ready():
    current_scene = get_tree().current_scene

func goto_scene(path: String):
    _deferred_goto_scene.call_deferred(path)

func _deferred_goto_scene(path: String):
    current_scene.free()

    var packed := load(path)
    current_scene = packed.instantiate()

    get_tree().root.add_child(current_scene)
    get_tree().current_scene = current_scene
```

Utilisation :

```gdscript
SceneManager.goto_scene("res://levels/level_2.tscn")
```

---

## 7. GDScript et C++

### GDScript
- accès direct par le nom de l’Autoload,
- simple et lisible,
- recommandé pour la majorité des projets.

### C++
- Autoload = Node classique,
- accessible via le SceneTree (`get_root()->get_node("GameState")`),
- souvent utilisé comme **façade** vers des services C++ purs.

---

## 8. Références

Documentation officielle :  
https://docs.godotengine.org/fr/4.x/tutorials/scripting/singletons_autoload.html
