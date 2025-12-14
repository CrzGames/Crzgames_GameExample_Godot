# 📘 Godot 4.x — Signaux & Callables
## Communication événementielle claire, robuste et scalable

Ce document explique **comment fonctionnent réellement les signaux et les Callables dans Godot 4.x**,  
et surtout **comment bien les utiliser** pour écrire un code **découplé, lisible et maintenable**.

Objectif : **penser Godot** (event-driven), pas juste connecter des boutons.

---

## 📑 Sommaire

- [🧠 Modèle mental fondamental](#-modèle-mental-fondamental)
- [1️⃣ Callable — comprendre VRAIMENT ce que c’est](#1️⃣-callable--comprendre-vraiment-ce-que-cest)
  - [1.1 Qu’est-ce qu’un Callable ?](#11-quest-ce-quun-callable-)
  - [1.2 Exemple simple (méthode d’un Node)](#12-exemple-simple-méthode-dun-node)
  - [1.3 Exemple avec lambda (Callable custom)](#13-exemple-avec-lambda-callable-custom)
  - [1.4 Callable standard vs custom](#14-callable-standard-vs-custom)
- [2️⃣ bind() — adapter une fonction à un contexte](#2️⃣-bind--adapter-une-fonction-à-un-contexte)
  - [2.1 bind : ajouter des arguments](#21-bind--ajouter-des-arguments)
  - [2.2 bind avec signal](#22-bind-avec-signal)
- [3️⃣ unbind() — gérer les signaux trop verbeux](#3️⃣-unbind--gérer-les-signaux-trop-verbeux)
- [4️⃣ call() vs call_deferred()](#4️⃣-call-vs-call_deferred)
  - [4.1 call()](#41-call)
  - [4.2 call_deferred()](#42-call_deferred)
- [5️⃣ Signaux — le cœur de Godot](#5️⃣-signaux--le-cœur-de-godot)
  - [5.1 Qu’est-ce qu’un signal ?](#51-quest-ce-quun-signal-)
  - [5.2 Exemple concret : Player → UI](#52-exemple-concret--player--ui)
- [6️⃣ Connexion de signaux par le code (RECOMMANDÉ)](#6️⃣-connexion-de-signaux-par-le-code-recommandé)
  - [6.1 Exemple complet : Timer](#61-exemple-complet--timer)
- [7️⃣ Signaux personnalisés (propre et scalable)](#7️⃣-signaux-personnalisés-propre-et-scalable)
  - [7.1 Déclaration](#71-déclaration)
  - [7.2 Émission](#72-émission)
  - [7.3 Écoute](#73-écoute)
- [8️⃣ Bonnes pratiques essentielles](#8️⃣-bonnes-pratiques-essentielles)
- [9️⃣ Anti-patterns à éviter ABSOLUMENT](#9️⃣-anti-patterns-à-éviter-absolument)
- [🔚 Résumé final](#-résumé-final)
- [📚 Références officielles](#-références-officielles)

---

## 🧠 Modèle mental fondamental

Avant toute chose, retiens ceci :

```
Signal   = événement (quelque chose s’est produit)
Callable = action (quoi exécuter quand ça arrive)
```

Un **signal n’appelle jamais directement une fonction**.  
Il **émet** une information.

Un **Callable** est ce qui **réagit** à cette information.

👉 Godot est **event-driven**, pas orienté appels directs.

---

## 1️⃣ Callable — comprendre VRAIMENT ce que c’est

### 1.1 Qu’est-ce qu’un Callable ?

Un `Callable` est un **objet qui représente une fonction appelable**.

Il peut représenter :
- une méthode d’un Node (`self.take_damage`)
- une fonction globale (`print`)
- une lambda GDScript
- une méthode d’un type Variant (`array.clear`)
- une fonction RPC réseau

C’est un **Variant typé**, stockable dans une variable.

---

### 1.2 Exemple simple (méthode d’un Node)

```gdscript
extends Node

func say_hello(name: String) -> void:
    print("Bonjour", name)

func _ready():
    var c := Callable(self, "say_hello")
    c.call("Corentin")
```

🧩 Explication :
- `Callable(self, "say_hello")` → référence la méthode
- `call("Corentin")` → exécute la fonction
- **aucune string fragile ailleurs dans le code**

---

### 1.3 Exemple avec lambda (Callable custom)

```gdscript
func _ready():
    var log_damage := func(amount: int):
        print("Dégâts subis :", amount)

    log_damage.call(25)
```

✔ Lambda = Callable **sans objet**  
✔ Très utile pour :
- callbacks temporaires
- tests
- logique locale

---

### 1.4 Callable standard vs custom

```gdscript
var a = Callable(self, "say_hello")
var b = func(): pass

print(a.is_standard()) # true → méthode d’un Object
print(b.is_custom())   # true → lambda
```

📌 Pourquoi c’est important ?
- Godot gère différemment les signatures
- `bind()` / `unbind()` créent des callables custom

---

## 2️⃣ bind() — adapter une fonction à un contexte

### 2.1 bind : ajouter des arguments

Cas réel : tu veux connecter un bouton à une fonction avec paramètres.

```gdscript
func attack(target: String, damage: int):
    print("Attaque", target, "pour", damage)

func _ready():
    var c = Callable(self, "attack").bind("Orc", 10)
    c.call()
```

➡️ Résultat :
```
Attaque Orc pour 10
```

💡 `bind()` permet de **préconfigurer** une action.

---

### 2.2 bind avec signal

```gdscript
button.pressed.connect(
    Callable(self, "attack").bind("Gobelin", 25)
)
```

✔ Pas besoin de fonction intermédiaire  
✔ Très lisible

---

## 3️⃣ unbind() — gérer les signaux trop verbeux

Certains signaux envoient **plus d’arguments que nécessaire**.

Exemple :

```gdscript
signal something_happened(a, b, c)
```

Mais ta fonction n’en attend qu’un :

```gdscript
func on_event(a):
    print(a)
```

Solution :

```gdscript
node.something_happened.connect(
    Callable(self, "on_event").unbind(2)
)
```

➡️ Godot ignore les 2 derniers paramètres.

---

## 4️⃣ call() vs call_deferred()

### 4.1 call()

```gdscript
do_something.call()
```

✔ Exécution immédiate  
❌ Dangereux si :
- Node en cours de suppression
- modification de la scène pendant une frame

---

### 4.2 call_deferred()

```gdscript
queue_free.call_deferred()
```

✔ Appelé **en fin de frame**  
✔ Sécurisé pour :
- suppression de Node
- modification de l’arbre

⚠️ **Ne jamais rappeler une méthode deferred depuis elle-même**

---

## 5️⃣ Signaux — le cœur de Godot

### 5.1 Qu’est-ce qu’un signal ?

Un signal est un **événement émis par un Node**.

Exemples :
- `Button.pressed`
- `Timer.timeout`
- `Area2D.body_entered`

👉 Le Node **ne sait pas qui écoute**.

---

### 5.2 Exemple concret : Player → UI

❌ Mauvais (couplé) :

```gdscript
ui.update_health(health)
```

✅ Bon (signal) :

```gdscript
signal health_changed(new_value)

func take_damage(amount):
    health -= amount
    health_changed.emit(health)
```

Connexion :

```gdscript
player.health_changed.connect(ui.update_health)
```

✔ Player indépendant  
✔ UI remplaçable  
✔ Code testable

---

## 6️⃣ Connexion de signaux par le code (RECOMMANDÉ)

### 6.1 Exemple complet : Timer

```gdscript
extends Sprite2D

@onready var timer: Timer = $Timer

func _ready():
    timer.timeout.connect(_on_timer_timeout)
    timer.start()

func _on_timer_timeout():
    visible = not visible
```

🧠 Pourquoi `_ready()` ?
- le Node est **dans le SceneTree**
- les enfants existent

---

## 7️⃣ Signaux personnalisés (propre et scalable)

### 7.1 Déclaration

```gdscript
signal died
signal health_changed(old_value, new_value)
```

📌 Convention :
- verbe au passé
- événement déjà arrivé

---

### 7.2 Émission

```gdscript
func take_damage(amount):
    var old = health
    health -= amount

    if health <= 0:
        died.emit()

    health_changed.emit(old, health)
```

---

### 7.3 Écoute

```gdscript
player.died.connect(show_game_over)
player.health_changed.connect(update_ui)
```

---

## 8️⃣ Bonnes pratiques essentielles

✔ Utiliser les signaux pour **communiquer**, pas appeler directement  
✔ Utiliser `Callable`, jamais des strings  
✔ Connecter dans `_ready()`  
✔ `bind()` pour contextualiser  
✔ `unbind()` pour adapter  
✔ Déconnecter dans `_exit_tree()` si nécessaire

---

## 9️⃣ Anti-patterns à éviter ABSOLUMENT

❌ `_process()` qui surveille un état  
❌ `get_parent().get_parent()`  
❌ Couplage gameplay ↔ UI  
❌ Signaux utilisés comme fonctions  
❌ Connexions avec `"method_name"` (strings)

---

## 🔚 Résumé final

```
Signal   = notification
Callable = réaction
connect  = abonnement
emit     = événement
```

👉 **Godot = architecture orientée événements**  
👉 **Code modulaire, clair, extensible**  
👉 **Indispensable pour jeux moyens / gros**

---

## 📚 Références officielles

- Callable : https://docs.godotengine.org/fr/4.x/classes/class_callable.html  
- Signals : https://docs.godotengine.org/fr/4.x/getting_started/step_by_step/signals.html
