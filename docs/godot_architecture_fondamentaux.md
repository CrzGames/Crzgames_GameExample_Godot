# 📘 Godot 4.x - Philosophie & Architecture du moteur

Ce document synthétise **la philosophie de design de Godot** et ses **concepts architecturaux clés**
(Node, Scene, Resource, SceneTree), en s’appuyant sur la **documentation officielle Godot 4.x**.

Objectif : comprendre **comment penser Godot**, pas seulement comment cliquer dans l’éditeur.

---

## 📑 Sommaire

- [1. Philosophie de design de Godot](#1-philosophie-de-design-de-godot)

- [2. Node (Nœud)](#2-node-nœud)
  - [Définition](#définition)
  - [Exemple](#exemple)

- [3. Scene (Scène)](#3-scene-scène)
  - [Définition](#définition-1)
  - [Formats de fichiers de scène (.tscn/ .scn / .escn)](#formats-de-fichiers-de-scène-tscn-scn--escn)
    - [TSCN — Text Scene](#tscn--text-scene)
    - [SCN — Binary Scene](#scn--binary-scene)
    - [ESCN — Exported Scene](#escn--exported-scene)

- [4. Resource (Ressource)](#4-resource-ressource)
  - [Définition](#définition-2)

- [5. SceneTree & MainLoop](#5-scenetree--mainloop)
  - [Architecture interne simplifiée](#architecture-interne-simplifiée)

- [6. Viewport racine](#6-viewport-racine)

- [7. Activation et cycle de vie](#7-activation-et-cycle-de-vie)

- [8. Changement de scène courante](#8-changement-de-scène-courante)
  - [Méthode simple (par chemin)](#méthode-simple-par-chemin)
  - [Méthode via PackedScene (préchargement)](#méthode-via-packedscene-préchargement)
  - [Pourquoi c’est “bloquant” ?](#pourquoi-cest-bloquant)

- [8.1 Chargement d'une scène/ressource en arrière-plan (threaded) avec ResourceLoader](#81--chargement-dune-scèneressource-en-arrière-plan-threaded-avec-resourceloader)
  - [Exemple : charger une scène en arrière-plan + changer quand c’est prêt](#exemple--charger-une-scène-en-arrière-plan--changer-quand-cest-prêt)
  - [Exemple “doc-style” : précharger une scène (ennemi) et instancier au clic](#exemple-doc-style--précharger-une-scène-ennemi-et-instancier-au-clic)

- [9. Modèle mental à retenir](#9-modèle-mental-à-retenir)

- [10. Références (doc officielle)](#10-références-doc-officielle)

---

## 1️⃣ Philosophie de design de Godot

Godot est conçu autour de **la composition orientée objet**, pas autour de composants.

Principes clés :
- tout est **Node**
- les Nodes forment un **arbre**
- une **Scene est un arbre de Nodes**
- on compose plutôt que multiplier l’héritage
- le moteur reste **agnostique du gameplay**

👉 Godot ne force **aucun pattern** (MVC, ECS, etc.), mais fournit une structure intuitive.

---

## 2️⃣ Node (Nœud)

### Définition
Un **Node** est un **objet actif** du moteur.

Il :
- vit dans le **SceneTree**
- reçoit des callbacks (`_ready`, `_process`, `_input`, etc.)
- possède un parent et des enfants
- expose des propriétés
- peut être étendu par script ou C++/GDExtension

👉 **Node = comportement + hiérarchie**

### Exemple
```
Player (CharacterBody2D)
 ├─ Sprite2D
 ├─ CollisionShape2D
 └─ Camera2D
```

Chaque node a **une responsabilité claire**.

---

## 3️⃣ Scene (Scène)

### Définition
Une **Scene** est :
> 📦 un arbre de Nodes sauvegardé sur disque (`.tscn`, `.scn`)

Une scène :
- a toujours **un node racine**
- agit comme un **nouveau type de node** dans l’éditeur (quand tu l’instances)
- peut être instanciée plusieurs fois
- peut être héritée (scènes héritées)

👉 Une scène peut être :
- un personnage
- un objet
- un UI
- un niveau
- une partie de niveau

### Formats de fichiers de scène (.tscn/ .scn / .escn)

#### 📄 TSCN — Text Scene
Le format **TSCN** (*Text Scene*) représente **un arbre de scène unique** sous forme **texte**.

Caractéristiques :
- lisible par l’humain
- idéal pour **Git / versioning**
- modifiable directement (même hors éditeur)
- format par défaut de Godot

👉 C’est le format **recommandé** pour le développement.

#### 📦 SCN — Binary Scene
Le format **SCN** est une version **binaire** d’une scène.

Caractéristiques :
- non lisible par l’humain
- plus rapide à charger
- moins adapté au versioning

👉 Utilisé surtout comme **format compilé/intermédiaire**.

#### 📤 ESCN — Exported Scene
Le format **ESCN** est identique syntaxiquement au TSCN, mais indique :
- que la scène provient d’un **outil externe**
- qu’elle **ne doit pas être modifiée** dans Godot

Lors de l’import :
- les fichiers `.escn` sont **convertis en `.scn` binaires**
- stockés dans le dossier `.godot/imported/`
- optimisés pour la taille et le chargement

---

## 4️⃣ Resource (Ressource)

### Définition
Une **Resource** est une **donnée**, pas un objet vivant.

Elle :
- n’est pas dans le SceneTree
- n’a pas de callbacks
- est sérialisable (sauvegarde/chargement)
- est partageable (réutilisable entre plusieurs scènes/nodes)

👉 **Resource = data / asset / configuration**

Exemples :
- `Texture2D`
- `AudioStream`
- `Material`
- `TileSet`
- `PackedScene` (une scène “packagée”/chargeable comme ressource)
- Resources custom (ex. `UnitStats`, `WeaponData`, etc.)

---

## 5️⃣ SceneTree & MainLoop

### Architecture interne simplifiée
```
OS
 └─ MainLoop
     └─ SceneTree
         └─ Viewport racine
             └─ Scène courante
```

- **MainLoop** : boucle bas niveau (OS)
- **SceneTree** : boucle haut niveau (jeu)

SceneTree :
- gère les scènes (scène courante, changement de scène, etc.)
- gère les groupes
- gère la pause
- gère la fermeture du jeu

Accessible via :
```gdscript
get_tree()
```

---

## 6️⃣ Viewport racine

Le **Viewport racine** :
- est le sommet de l’arbre
- contient la fenêtre principale
- rend tout ce qui est visible

Accès :
```gdscript
get_tree().root
get_node("/root")
```

Tout node visible est **enfant d’un Viewport** (directement ou indirectement).

---

## 7️⃣ Activation et cycle de vie

Un Node devient “actif” quand il est **connecté** (directement ou indirectement) au **Viewport racine**.

Conséquence :
- il reçoit `_enter_tree()`
- puis `_ready()`
- puis éventuellement `_process()`, `_physics_process()`, `_input()`, etc.
- et enfin `_exit_tree()` quand il sort de l’arbre

👉 Retenir : **pas dans le SceneTree = pas d’activité**.

---

## 8️⃣ Changement de scène courante

### Méthode simple (par chemin)
```gdscript
get_tree().change_scene_to_file("res://levels/level2.tscn")
```

✔ rapide  
❌ charge/instancie/active d’un coup → peut **geler** si la scène est lourde

---

### Méthode via PackedScene (préchargement)
```gdscript
var next_scene: PackedScene = preload("res://levels/level2.tscn")

func _my_level_was_completed():
    get_tree().change_scene_to_packed(next_scene)
```

✔ te permet de précharger à l’avance (`preload`)  
✔ plus propre si tu veux préparer un système de loading  
⚠️ mais si la scène est lourde à **instancier/activer**, tu peux quand même avoir un petit freeze.

---

### ⚠️ Pourquoi c’est “bloquant” ?
La méthode standard `load()` (ou `ResourceLoader.load()`) est **bloquante** : elle occupe le thread principal.
Pendant ce temps :
- le rendu ne se met plus à jour,
- l’input semble “mort”,
- ton jeu paraît figé.

---

## 8.1 ✅ Chargement d'une scène/ressource en arrière-plan (threaded) avec ResourceLoader

Pour charger une scène (ou une ressource) **en arrière-plan**, Godot propose un workflow en 3 étapes :

1) **Demander** le chargement en arrière-plan :
```gdscript
ResourceLoader.load_threaded_request(path)
```

2) **Vérifier** l’état + progression :
```gdscript
var progress := []
var status := ResourceLoader.load_threaded_get_status(path, progress)
```

3) **Récupérer** la ressource quand c’est prêt :
```gdscript
var res := ResourceLoader.load_threaded_get(path)
```

> ⚠️ Point crucial (doc officielle) :  
> `load_threaded_get()` peut **bloquer** si le chargement n’est pas fini.  
> Donc pour garantir “pas de freeze”, on attend `THREAD_LOAD_LOADED`.

---

### Exemple : charger une scène en arrière-plan + changer quand c’est prêt

```gdscript
extends Node

const NEXT_SCENE_PATH := "res://levels/level2.tscn"

func _ready() -> void:
    # 1) Lancer le chargement en arrière-plan
    ResourceLoader.load_threaded_request(NEXT_SCENE_PATH)

func _process(_delta: float) -> void:
    # 2) Vérifier statut + progression
    var progress := []
    var status := ResourceLoader.load_threaded_get_status(NEXT_SCENE_PATH, progress)

    if progress.size() > 0:
        var p := progress[0] # 0..1
        # Ici tu updates une ProgressBar / Label / spinner
        # print("Loading: ", int(p * 100), "%")

    if status == ResourceLoader.THREAD_LOAD_LOADED:
        # 3) Safe : la ressource est prête
        var packed := ResourceLoader.load_threaded_get(NEXT_SCENE_PATH) as PackedScene
        if packed:
            # 4) Switch scène
            get_tree().change_scene_to_packed(packed)
        else:
            push_error("La ressource chargée n'est pas une PackedScene.")
    elif status == ResourceLoader.THREAD_LOAD_FAILED:
        push_error("Chargement échoué : " + NEXT_SCENE_PATH)
```

✅ Résultat : ton jeu peut afficher une **loading screen animée** sans freeze.

---

### Exemple “doc-style” : précharger une scène (ennemi) et instancier au clic

```gdscript
const ENEMY_SCENE_PATH : String = "res://Enemy.tscn"

func _ready() -> void:
    ResourceLoader.load_threaded_request(ENEMY_SCENE_PATH)
    $Button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
    var enemy_scene := ResourceLoader.load_threaded_get(ENEMY_SCENE_PATH) as PackedScene
    var enemy := enemy_scene.instantiate()
    add_child(enemy)
```

⚠️ Si tu appelles `load_threaded_get()` trop tôt, ça peut bloquer.  
Pour être 100% safe : attendre `THREAD_LOAD_LOADED` (comme dans l’exemple précédent).

---

## 9️⃣ Modèle mental à retenir

- **Node** → vit et agit (callbacks, hiérarchie)
- **Scene** → structure et composition (arbre de nodes, réutilisable)
- **Resource** → données (partageables, sérialisées)
- **PackedScene** → une scène “packagée” comme ressource (charger → instancier)
- **SceneTree** → moteur global du jeu (scène courante, pause, groupes…)
- **Viewport** → rendu (tout ce qui est visible vit sous un Viewport)
- **Changement de scène**
  - simple : `change_scene_to_file()` (peut freeze)
  - propre : `load_threaded_request()` + progress + `change_scene_to_packed()` (loading UX)

---

## 10. Références (doc officielle)

- Changer la scène courante :
  https://docs.godotengine.org/fr/4.x/tutorials/scripting/scene_tree.html#changing-current-scene

- Chargement en arrière-plan d'une nouvelle scène/ressource (Background loading) :
  https://docs.godotengine.org/fr/4.x/tutorials/io/background_loading.html#doc-background-loading

- Format de fichiers Godot (.tscn, .esn..etc) : https://docs.godotengine.org/fr/4.x/engine_details/file_formats/tscn.html
