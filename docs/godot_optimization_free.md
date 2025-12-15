# 📘 Godot 4.x - `queue_free() / free()`
## Comment ça marche vraiment, et comment libérer proprement RAM + VRAM

`queue_free()` est la méthode standard pour **détruire un Node** dans Godot **sans casser la frame en cours**.
Elle ne détruit pas l’objet instantanément : elle le **planifie pour destruction** et Godot le supprimera **à un moment sûr** (typiquement **en fin de frame / fin d’itération**), quand le moteur sait qu’il ne l’utilise plus.

---

## 📑 Sommaire

1. [C’est quoi `queue_free()`](#1-cest-quoi-queue_free)
2. [“Fin de frame” : ce que ça veut dire](#2-fin-de-frame--ce-que-ça-veut-dire)
3. [`free()` vs `queue_free()`](#3-free-vs-queue_free)
4. [Ce qui est libéré : Node / ressources / RAM / VRAM](#4-ce-qui-est-libéré--node--ressources--ram--vram)

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
- il est détruit **après que Godot ait fini ce qu’il fait dans la frame** (rendu, callbacks, itérations internes)

C’est important parce que sinon tu pourrais :
- supprimer un Node pendant qu’un signal est en train de l’utiliser,
- casser une boucle qui parcourt les enfants,
- invalider des références internes du moteur.

👉 En pratique : **si tu testes juste après `queue_free()` dans la même fonction**, il est “en sursis”.

---

## 3. `free()` vs `queue_free()`

### `queue_free()` (recommandé)
- destruction différée, **safe**
- le moteur choisit le moment sûr

### `free()` (à utiliser avec prudence)
- destruction **immédiate**
- peut casser des itérations / signaux / traitements en cours si mal utilisé

👉 Dans 95% des cas : **utilise `queue_free()`**.

---

## 4. Ce qui est libéré : Node / Ressources / RAM / VRAM

### 4.1 Le Node lui-même (RAM)
Quand Godot détruit le Node :
- la mémoire du Node et de ses scripts part
- les enfants sont aussi libérés (si tu supprimes un parent)

### 4.2 Les `Resource` (textures, meshes, audio…) : pas toujours “tout de suite”
Beaucoup de choses en Godot (Texture2D, Mesh, AudioStream…) sont des `Resource` **référencées**.
Donc la règle est :

> Une ressource n’est libérée que quand **plus rien ne la référence**.

Exemples :
- si tu supprimes un Sprite2D, mais que sa Texture est aussi utilisée ailleurs → la texture reste.
- si tu as mis une ressource dans un cache global / variable statique / singleton → elle reste.

### 4.3 VRAM (GPU)
La VRAM est libérée quand :
- la ressource GPU correspondante n’est plus utilisée,
- et que le moteur/driver purge réellement (ça peut être différé)

Donc :
- `queue_free()` libère **le Node**
- mais **VRAM** dépend surtout des **textures/meshes** et de leurs **références**.