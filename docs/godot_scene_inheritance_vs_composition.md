# 📘 Godot 4.x — Héritage de scène vs Composition
## Bonnes pratiques, pièges courants et workflow recommandé

Ce document clarifie **quand et comment utiliser l’héritage de scène dans Godot**,
et pourquoi il est souvent préférable de le **combiner avec la composition** plutôt que
de construire de grandes hiérarchies d’héritage (de scènes ou de classes).

Objectif : **éviter les pièges classiques**, comprendre le **modèle mental réel de Godot**,
et adopter un workflow **robuste et scalable**.

---

## 📑 Sommaire

- [1. Pourquoi l’héritage de scène est controversé](#1-pourquoi-lhéritage-de-scène-est-controversé)
- [2. Deux types d’héritage à ne pas confondre](#2-deux-types-dhéritage-à-ne-pas-confondre)
- [3. Ce que fait réellement l’héritage de scène](#3-ce-que-fait-réellement-lhéritage-de-scène)
- [4. Pourquoi ça “casse” parfois](#4-pourquoi-ça-casse-parfois)
- [5. Quand l’héritage de scène est une bonne idée](#5-quand-lhéritage-de-scène-est-une-bonne-idée)
- [6. Quand il faut l’éviter](#6-quand-il-faut-léviter)
- [7. Composition : le pattern recommandé](#7-composition--le-pattern-recommandé)
- [8. Workflow conseillé (cas RPG / ennemis)](#8-workflow-conseillé-cas-rpg--ennemis)
- [9. Règles d’or](#9-règles-dor)

---

## 1. Pourquoi l’héritage de scène est controversé

Si tu parcours la communauté Godot (forums, Reddit, Discord), tu verras souvent :
> “L’héritage de scène est buggé / déconseillé / inutile.”

La réalité est plus nuancée :
- l’héritage de scène **fonctionne**,
- mais il est **facile à mal utiliser**,
- et il est souvent confondu avec l’héritage de classes classique (POO).

👉 Le problème n’est pas la fonctionnalité,
👉 mais **le workflow adopté autour**.

---

## 2. Deux types d’héritage à ne pas confondre

### 2.1 Héritage de classe (scripts)

```gdscript
extends CharacterBody2D
```

- concerne **la logique**
- fonctionne comme dans la POO classique
- stable, prévisible
- recommandé pour partager du comportement

---

### 2.2 Héritage de scène

- une scène basée sur une autre scène
- hérite de **la structure de nodes**
- permet override de propriétés / scripts / visuels
- agit comme un **template structurel**

👉 Ces deux héritages sont **orthogonaux** et ne doivent pas être mélangés mentalement.

---

## 3. Ce que fait réellement l’héritage de scène

Une scène héritée :
- référence une **scène parent**
- applique des **overrides** (propriétés, scripts, ajouts de nodes)
- conserve un lien vers la scène parent

Important :
> Une scène héritée n’est **pas une classe abstraite**  
> c’est un **conteneur de structure + données**.

---

## 4. Pourquoi ça “casse” parfois

### 4.1 Ressources partagées

Beaucoup d’éléments sont des **Resources** :
- animations
- shapes de collision
- materials

Les Resources sont **partagées par défaut**.

Conséquence classique :
> “Je modifie l’enfant et ça modifie le parent.”

➡ Ce n’est pas l’héritage qui remonte,  
➡ c’est **la même Resource**.

Solution :
- dupliquer la ressource
- ou la rendre **unique / locale à la scène**

---

### 4.2 Structure instable

L’héritage de scène devient fragile si :
- tu renommes souvent des nodes hérités
- tu changes profondément la hiérarchie
- tu empiles plusieurs niveaux d’héritage

➡ Les overrides deviennent difficiles à suivre.

---

## 5. Quand l’héritage de scène est une bonne idée

✔ Quand tu veux garantir une **structure minimale obligatoire**  
✔ Quand la scène parent est **stable**  
✔ Quand tu te limites à **1 niveau d’héritage**

Exemples pertinents :
- `BaseActor.tscn` (hitbox, health, sockets)
- UI template (HUD commun)
- objets interactifs très proches

👉 Utiliser l’héritage de scène comme un **template**, pas comme une hiérarchie profonde.

---

## 6. Quand il faut l’éviter

❌ Si tu veux modéliser toute ta logique métier  
❌ Si chaque enfant modifie profondément la structure  
❌ Si tu fais :
```
Actor → Enemy → MeleeEnemy → WolfEnemy
```

➡ Là, tu vas vers un système fragile et difficile à maintenir.

---

## 7. Composition : le pattern recommandé

Godot favorise **la composition** plutôt qu’un héritage profond.

Idée clé :
> Ajouter des capacités par **nodes / scripts spécialisés**
> plutôt que par héritage.

Exemples de composants :
- `HealthComponent`
- `InventoryComponent`
- `AIController`
- `GraphicsController`

Chaque composant :
- fait une chose
- communique via **signaux**
- ne dépend pas du contexte global

---

## 8. Workflow conseillé (cas RPG / ennemis)

### Structure recommandée

- `BaseActor.tscn`
  - structure minimale (collision, health, sockets)
  - script `actor.gd`

- `EnemyStats.tres` (Resource)
  - HP, attaque, défense, vitesse

- `Wolf.tscn`
  - instance ou héritage léger de `BaseActor`
  - sprite + animation spécifiques
  - ressource `WolfStats.tres`
  - script d’IA spécifique si besoin

👉 Les **différences sont portées par les données**, pas par l’héritage.

---

## 9. Règles d’or

✔ 1 niveau d’héritage de scène max  
✔ Héritage de scène = **structure**, pas logique  
✔ Héritage de script = **comportement partagé**  
✔ Resources pour les données  
✔ Composition + signaux pour le reste  

❌ Pas de hiérarchies profondes  
❌ Pas de “God Scene”  
❌ Pas de logique métier dans les scènes parents

---

## 🧠 Synthèse

- L’héritage de scène **n’est pas mauvais**
- Il est **puissant mais délicat**
- Il devient sain quand :
  - il est limité
  - combiné à la composition
  - et appuyé par des Resources

👉 **Penser Godot**, ce n’est pas copier la POO classique,
👉 c’est composer des systèmes simples et stables.
