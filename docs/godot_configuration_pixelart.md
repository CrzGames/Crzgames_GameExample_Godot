# 🎮 Godot 4.x — Configuration Pixel Art (Editor & Project)

Ce document décrit **la configuration recommandée de Godot 4.x pour les projets en pixel art**.  
Objectif : obtenir un rendu **net**, **pixel-perfect**, sans flou, avec une **mise à l’échelle entière** correcte sur tous les écrans modernes.

---

## 📑 Sommaire

1. [Filtrage des textures : Nearest](#1-filtrage-des-textures--nearest)
2. [Choisir la résolution de base](#2-choisir-la-résolution-de-base)
3. [Stretch Mode : disabled vs canvas_items vs viewport](#3-stretch-mode--disabled-vs-canvas_items-vs-viewport)
4. [Stretch Aspect : keep vs expand](#4-stretch-aspect--keep-vs-expand)
5. [Stretch Scale Mode : integer vs fractional](#5-stretch-scale-mode--integer-vs-fractional)
6. [Presets recommandés](#6-presets-recommandés)
7. [Résolution de base “universelle” pour le pixel art](#7-résolution-de-base-universelle-pour-le-pixel-art)
8. [Conclusion](#8-conclusion)

---

## 1) Filtrage des textures : Nearest

Par défaut, Godot utilise un **filtrage linéaire**, qui lisse les pixels lors de la mise à l’échelle.  
Ce comportement est adapté aux graphismes HD, **mais inadapté au pixel art**, car il floute les contours.

Pour un rendu pixel art correct, il faut utiliser le **filtrage par plus proche voisin (Nearest)**.

### Configuration globale (recommandée)

1. **Project → Project Settings…**
2. Activer **Advanced Settings**
3. Aller dans **Rendering → Textures**
4. Régler **Default Texture Filter** sur **Nearest**

➡️ Toutes les textures utiliseront désormais le filtrage *Nearest* par défaut.

### Configuration par nœud (si nécessaire)

Si une texture reste floue :
- Sélectionner le `Sprite2D` / `TextureRect`
- Dans l’Inspector → **Texture Filter**
- Mettre **Nearest** ou **Inherit**

---

## 2) Choisir la résolution de base

La résolution de base correspond à la **taille de la zone de travail virtuelle** (“design size”).  
Elle définit la densité de pixels et la taille apparente des sprites à l’écran.

### Bonnes pratiques

- Utiliser un format **16:9** (le plus répandu)
- Adapter la résolution à la **taille des sprites**
- S’inspirer de jeux existants au style proche

### Exemples de résolutions 16:9 adaptées au pixel art

- `320×180`
- `426×240`
- `568×320`
- `640×360` ✅ (très polyvalente)

### Où configurer la résolution de base

**Project Settings → Display → Window → Size**
- **Viewport Width**
- **Viewport Height**

---

## 3) Stretch Mode — disabled vs canvas_items vs viewport

📍 Emplacement : **Project Settings → Display → Window → Stretch → Mode**

Le **Stretch Mode** détermine **comment la taille de base est adaptée** à la résolution de la fenêtre/écran.

### `disabled` (par défaut) — Non recommandé pour un jeu pixel art

- Aucun étirement
- **1 unité = 1 pixel écran**
- `Stretch Aspect` n’a aucun effet

✅ Utile pour : applications non-jeu / outils  
❌ Pas adapté à : jeux (plein écran, multi-résolutions)

---

### `canvas_items` — Pixel art “moderne” (non strict)

- La taille de base est étirée pour couvrir l’écran (en tenant compte de `Aspect`)
- Tout est rendu **directement à la résolution finale**
- En 2D, il n’y a plus de correspondance 1:1 sprite pixel ↔ pixel écran

✅ Avantages  
- caméra fluide  
- effets modernes (particules, shaders) plus propres  
- sprites nets si `Nearest` est activé  

⚠️ Inconvénients  
- rendu moins “pixel-perfect strict”  
- risque d’artefacts si mouvement sub-pixel / scaling non entier  

➡️ Recommandé si tu veux du **pixel art moderne**, sans chercher un rendu rétro strict.

---

### `viewport` — Recommandé pour du pixel art “rétro / pixel-perfect”

- Le **root Viewport** est fixé à la taille de base
- La scène est rendue à cette résolution d’abord
- Puis ce rendu est **upscalé** pour remplir l’écran (en tenant compte de `Aspect`)

✅ Avantages  
- rendu rétro uniforme (sprites + UI pixelisés de manière cohérente)  
- meilleur mode pour un rendu **pixel-perfect**  
- fonctionne très bien avec `Stretch Scale Mode = integer`

⚠️ Inconvénients  
- les particules / interpolations peuvent paraître saccadées (basse résolution)  
- pas idéal si tu veux des effets haute résolution

➡️ **Choix recommandé** si ton objectif est le **pixel art authentique**.

---

## 4) Stretch Aspect — keep vs expand

📍 Emplacement : **Project Settings → Display → Window → Stretch → Aspect**

Le **Stretch Aspect** définit **comment Godot gère les formats d’écran** différents de ta résolution de base.  
Ce paramètre n’a d’effet que si `Stretch Mode` n’est pas `disabled`.

### `keep` — Imposer un format d’image unique (letterbox/pillarbox)

- Le ratio de la base est strictement conservé
- Des bandes noires sont ajoutées si nécessaire :
  - en haut/bas (**letterbox**)
  - à gauche/droite (**pillarbox**)
- La zone visible du jeu reste **identique** sur tous les écrans

✅ Avantages  
- cadrage constant (gameplay/composition identiques)  
- rendu parfaitement prévisible  
- idéal pour pixel art strict / rétro console

⚠️ Inconvénients  
- perte d’espace sur ultra-wide / formats atypiques

🧠 **Quand choisir `keep` ?**
- tu veux un rendu *pixel-perfect strict* et constant  
- le gameplay dépend d’un cadrage identique  
- tu veux éviter la variation du champ visible

---

### `expand` — Étendre la zone visible (formats variés, moins de bandes noires)

- Le ratio est conservé, mais la zone visible s’étend selon l’écran
- Cela réduit (ou supprime) les bandes noires dans beaucoup de cas
- La caméra peut afficher **un peu plus** selon le format

✅ Avantages  
- meilleure compatibilité avec écrans modernes (ultra-wide, etc.)  
- meilleure utilisation de l’espace écran

⚠️ Inconvénients  
- champ de vision variable selon l’écran (plus de contenu visible)  
- nécessite une UI robuste et adaptative

🧠 **Quand choisir `expand` ?**
- tu veux supporter beaucoup de formats d’écran  
- ton gameplay tolère un champ de vision variable  
- ton UI est conçue pour s’adapter (anchors/containers)

### ⚠️ UI et ancres avec `expand`

En mode `expand`, il est **impératif** d’utiliser :
- **Anchors**
- **Containers** (`HBoxContainer`, `VBoxContainer`, etc.)

Sans cela, l’interface peut être mal positionnée selon le format d’écran.

---

### 🧩 Note importante : `viewport` n’impose pas `keep`

`viewport` décrit **comment le jeu est rendu** (basse résolution puis upscale).  
`keep` / `expand` décrivent **comment on gère les formats d’écran**.

Donc :
- `viewport + keep` = pixel art strict + bandes noires si besoin
- `viewport + expand` = pixel art rétro + zone visible qui s’adapte (UI requise)

---

## 5) Stretch Scale Mode — integer vs fractional

📍 Emplacement : **Project Settings → Display → Window → Stretch → Scale Mode**

Ce paramètre contrôle **comment le facteur de mise à l’échelle est calculé**.

### `fractional` — Non recommandé pour pixel art

- Autorise des facteurs non entiers (ex : 2.133×)
- Cela provoque :
  - pixels non uniformes
  - damier irrégulier
  - contours instables

➡️ À éviter pour un rendu pixel-perfect.

---

### `integer` — Recommandé (pixel art net)

- Force un upscale en facteurs entiers :
  - ×2, ×3, ×4…
- Garantit des pixels parfaitement carrés
- Ajoute des bandes noires si nécessaire plutôt que déformer l’image

➡️ **Recommandé** pour tous les projets pixel art, surtout avec `viewport`.

---

## 6) Presets recommandés

### 🎯 Pixel art rétro / pixel-perfect strict (cadrage constant)

- Texture Filter : **Nearest**
- Base resolution : **640×360**
- Stretch Mode : **viewport**
- Stretch Aspect : **keep** (letterbox/pillarbox si nécessaire)
- Stretch Scale Mode : **integer**

✅ Rendu rétro uniforme  
✅ Cadrage identique sur tous les écrans

---

### 🎯 Pixel art rétro / multi-formats (UI adaptative)

- Texture Filter : **Nearest**
- Base resolution : **640×360**
- Stretch Mode : **viewport**
- Stretch Aspect : **expand**
- Stretch Scale Mode : **integer**

✅ Pixel art rétro (viewport)  
✅ Moins de bandes noires  
⚠️ UI doit être correctement ancrée

---

### 🎯 Pixel art moderne / fluide (UI adaptative)

- Texture Filter : **Nearest**
- Base resolution : **640×360**
- Stretch Mode : **canvas_items**
- Stretch Aspect : **expand**
- Stretch Scale Mode : **integer** (souvent recommandé)

✅ Caméra plus fluide, effets modernes  
⚠️ Moins strict que `viewport`

---

## 7) Résolution de base “universelle” pour le pixel art

La plupart des jeux pixel art utilisent des zones d’affichage comprises entre :

- `256×224`
- `320×180`
- `426×240`
- `568×320`
- `640×480`

### Pourquoi `640×360` est un excellent choix

- Format **16:9**
- Mise à l’échelle entière parfaite vers :
  - 1280×720 (×2)
  - 1920×1080 (×3)
  - 2560×1440 (×4)
  - 3840×2160 (×6)
- Pixels parfaitement carrés avec `integer`
- Très bonne compatibilité avec les écrans modernes

➡️ En pratique, **640×360 couvre presque tous les cas d’écran sans compromis visuel**.

---

## 8) Conclusion

Pour un projet pixel art sous Godot 4.x :

- Activer **Nearest** pour toutes les textures
- Choisir une base (souvent **640×360**)
- Utiliser `Stretch Scale Mode = integer`
- Choisir :
  - **`viewport`** pour un rendu pixel art rétro / pixel-perfect
  - **`canvas_items`** pour un rendu pixel art moderne / fluide
- Choisir `Aspect` selon ton objectif :
  - **`keep`** si tu veux un cadrage strict (bandes noires acceptées)
  - **`expand`** si tu veux supporter de nombreux formats (UI adaptative requise)

Ce setup garantit un rendu **net, cohérent et professionnel** sur PC, console et écrans modernes.
