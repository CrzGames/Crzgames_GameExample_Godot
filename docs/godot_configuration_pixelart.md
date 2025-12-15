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
8. [GUI & Fonts — Anticrénelage](#8-gui--fonts--anticrénelage)
9. [Écran de démarrage (Splash Screen)](#9-écran-de-démarrage-splash-screen)
10. [Rendu 2D — Pixel Snap (Transform & Vertices)](#10-rendu-2d--pixel-snap-transform--vertices)
11. [Conclusion](#11-conclusion)

---

## 1) Filtrage des textures : Nearest

Par défaut, Godot utilise un **filtrage linéaire**, qui lisse les pixels lors de la mise à l’échelle.  
Ce comportement est adapté aux graphismes HD, **mais inadapté au pixel art**, car il floute les contours.

### Configuration globale (recommandée)

1. **Project → Project Settings…**
2. Activer **Advanced Settings**
3. Aller dans **Rendering → Textures**
4. Régler **Default Texture Filter** sur **Nearest**

➡️ Toutes les textures utiliseront désormais le filtrage *Nearest* par défaut.

---

## 2) Choisir la résolution de base

La résolution de base correspond à la **taille de la zone de travail virtuelle** (“design size”).

Résolutions courantes :
- `320×180`
- `426×240`
- `568×320`
- `640×360` ✅ (très polyvalente)

📍 **Project Settings → Display → Window → Size**

---

## 3) Stretch Mode — disabled vs canvas_items vs viewport

📍 **Project Settings → Display → Window → Stretch → Mode**

### `canvas_items`
Pixel art moderne, caméra fluide, moins strict.

### `viewport` (recommandé pixel art rétro)
Rendu à basse résolution puis upscale → **pixel-perfect**.

---

## 4) Stretch Aspect — keep vs expand

📍 **Project Settings → Display → Window → Stretch → Aspect**

- `keep` → cadrage constant, bandes noires (letterbox/pillarbox possible)
- `expand` → zone visible variable, UI adaptative requise

---

## 5) Stretch Scale Mode — integer vs fractional

📍 **Project Settings → Display → Window → Stretch → Scale Mode**

- ❌ `fractional` → pixels irréguliers
- ✅ `integer` → pixels parfaitement carrés

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

## 8) GUI & Fonts — Anticrénelage

📍 **Project Settings → GUI → Theme**

### Default Font Antialiasing

- Par défaut : `Grayscale`
- ❌ Provoque du flou en pixel art
- ✅ **Mettre sur : `None`**

Recommandations :
- bitmap fonts si possible
- tailles entières
- éviter le scaling fractionnaire

---

## 9) Écran de démarrage (Splash Screen)

📍 **Project Settings → Application → Boot Splash**

### Use Filter

- Par défaut : **coché**
- ❌ applique un filtrage linéaire
- ✅ **Décocher pour du pixel art**

➡️ Permet un splash screen **pixel-perfect**, sans flou.

---

## 10) Rendu 2D — Pixel Snap (Transform & Vertices)

Godot utilise par défaut des **coordonnées flottantes**, ce qui peut provoquer des **demi-pixels**, du **flou** ou des **micro-tremblements** en pixel art, notamment lors des déplacements de caméra.

Pour garantir un rendu **pixel-perfect**, il est recommandé d’activer le *pixel snapping* côté rendu 2D.

📍 **Project Settings → Rendering → 2D**

### ✅ Snap 2D Transforms to Pixel (RECOMMANDÉ)

- **Activer** ✅
- Force l’alignement des `CanvasItem` (Sprite2D, TileMap, etc.) sur des **coordonnées entières au rendu**
- Réduit fortement :
  - le flou
  - les artefacts visuels
  - le jitter lors des déplacements

➡️ **À activer systématiquement pour les projets pixel art**.

---

### ❌ Snap 2D Vertices to Pixel (généralement désactivé)

- **Laisser désactivé** ❌ dans la majorité des cas
- Utile surtout pour :
  - `Polygon2D`
  - `Line2D`
  - formes vectorielles

⚠️ Sur des jeux basés sur des **sprites et tilemaps**, ce réglage n’apporte généralement aucun bénéfice et peut accentuer un rendu saccadé.

📌 **Éviter d’activer les deux options simultanément**.  
👉 Pour le pixel art classique, **Transforms suffit**.

---

## 11) Conclusion

Pour un projet pixel art sous Godot 4.x :

- Texture Filter : **Nearest**
- Résolution de base : **640×360**
- Stretch Scale Mode : **integer**
- GUI Font Antialiasing : **None**
- Splash Screen Filter : **désactivé**
- Snap 2D Transforms to Pixel : **activé**

Choisir :
- `viewport` → pixel art rétro strict
- `canvas_items` → pixel art moderne fluide
