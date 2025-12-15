# 📘 Godot 4.x - `queue_free()` / `free()`
## Comment ça marche vraiment, et comment libérer proprement RAM + VRAM

`queue_free()` est la méthode standard pour **détruire un Node** dans Godot **sans casser la frame en cours**.  
Elle ne détruit pas l’objet instantanément : elle le **planifie pour destruction** et Godot le supprimera **à un moment sûr** (typiquement **en fin de frame / fin d’itération**), quand le moteur sait qu’il ne l’utilise plus.

---

## 📑 Sommaire

1. [C’est quoi `queue_free()`](#1-cest-quoi-queue_free)
2. [“Fin de frame” : ce que ça veut dire](#2-fin-de-frame--ce-que-ça-veut-dire)
3. [`free()` vs `queue_free()`](#3-free-vs-queue_free)
4. [Ce qui est libéré : Node / Ressources / RAM / VRAM](#4-ce-qui-est-libéré--node--ressources--ram--vram)
5. [⚠️ Point fondamental : `RefCounted` vs non-`RefCounted`](#5-point-fondamental--refcounted-vs-non-refcounted)

---

## 1. C’est quoi `queue_free()`

- `queue_free()` **marque** le Node comme “à supprimer”.
- Le Node sera **retiré de l’arbre** et **détruit** quand Godot arrive à une phase sûre.
- Tu peux appeler `queue_free()` depuis :
  - `_process()`, `_physics_process()`, `_input()`, signaux, etc.
  - même au milieu d’une boucle qui parcourt des enfants (ça évite les crashes).

✅ Avantage : **safe**  
❗ Conséquence : pendant le reste de la frame, l’objet peut encore exister en mémoire, donc il faut coder en conséquence.

---

## 2. “Fin de frame” : ce que ça veut dire

Quand tu fais `queue_free()` :
- l’objet **n’est pas détruit tout de suite**
- il est détruit **après que Godot ait fini ce qu’il fait dans la frame**  
  (rendu, callbacks, itérations internes, signaux)

C’est important parce que sinon tu pourrais :
- supprimer un Node pendant qu’un signal est en train de l’utiliser,
- casser une boucle qui parcourt les enfants,
- invalider des références internes du moteur.

👉 En pratique : **si tu testes juste après `queue_free()` dans la même fonction**, l’objet est **en sursis**.

---

## 3. `free()` vs `queue_free()`

### `queue_free()` (recommandé)
- destruction différée, **safe**
- le moteur choisit le moment sûr

### `free()` (à utiliser avec prudence)
- destruction **immédiate**
- peut casser des itérations / signaux / traitements en cours si mal utilisé

👉 Dans **95 % des cas** : **utilise `queue_free()`**.

---

## 4. Ce qui est libéré : Node / Ressources / RAM / VRAM

### 4.1 Le Node lui-même (RAM)
Quand Godot détruit le Node :
- la mémoire du Node et de ses scripts est libérée
- tous ses enfants sont aussi supprimés (si tu supprimes un parent)

---

### 4.2 Les `Resource` (textures, meshes, audio…) : pas toujours “tout de suite”

Beaucoup de données importantes en Godot (`Texture2D`, `Mesh`, `AudioStream`, etc.) sont des **`Resource` référencées**.

Règle clé :

> Une `Resource` n’est libérée **que lorsque plus aucune référence n’existe**.

Exemples :
- Tu supprimes un `Sprite2D`, mais sa `Texture2D` est utilisée ailleurs → **la texture reste en mémoire**
- Une ressource stockée dans :
  - un singleton (Autoload)
  - un cache
  - un tableau global  
  **ne sera jamais libérée tant que la référence existe**

---

### 4.3 VRAM (GPU)

La VRAM est libérée quand :
- la ressource GPU (texture, mesh…) n’est plus référencée
- `le moteur libére la mémoire automatiquement ce n'ai pas à nous de le faire`.

Donc :
- `queue_free()` libère **le Node**
- la **VRAM dépend surtout des `Resource`**, pas des Nodes eux-mêmes

---

## 5. ⚠️ Point fondamental : `RefCounted` vs non-`RefCounted`

C’est **ESSENTIEL** à comprendre pour gérer correctement la mémoire dans Godot.

### 5.1 Classes `RefCounted` (libération automatique)

Toute instance d’une classe qui hérite de **`RefCounted`** est :

- **libérée automatiquement**
- dès qu’il n’existe **plus aucune référence** vers elle

Exemples de classes `RefCounted` :
- `Resource`
- `Texture2D`
- `Mesh`
- `AudioStream`
- `PackedScene`
- etc.

➡️ **Aucune nécessité d’appeler `free()` ou `queue_free()`**  
➡️ La libération est **automatique et sûre**

---

### 5.2 Classes NON `RefCounted` (libération manuelle obligatoire)

À l’inverse, les classes qui **n’héritent pas de `RefCounted`** :

- **ne sont jamais libérées automatiquement**
- restent en mémoire **tant que tu ne les détruis pas explicitement**

Exemples :
- `Node`
- `Node2D`
- `Control`
- `Object` (classe de base)
- ...

➡️ Ces objets **DOIVENT** être supprimés manuellement via :
- `queue_free()` (recommandé pour les Nodes)
- ou `free()` (cas très spécifiques)

⚠️ **Oublier de les libérer = fuite mémoire (RAM)**

---

### 5.3 Résumé mental à retenir

| Type | Libération |
|----|----|
| `RefCounted` / `Resource` | ✅ Automatique (si références = 0) |
| `Node` / `Object` | ❌ Manuelle obligatoire |
| VRAM | ❌ Dépend des `Resource`, pas des Nodes |

👉 **Supprimer un Node ne libère pas forcément la VRAM**    
👉 **Libérer une Resource sans référence libère RAM + VRAM**