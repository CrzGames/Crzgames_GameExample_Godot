# 📘 Godot 4.x — Guide des Notifications (`_notification(what)`)

Les notifications sont des **messages internes du moteur Godot** envoyés à chaque `Node` via :

```gdscript
func _notification(what):
```

Elles permettent de réagir à des événements que les callbacks classiques **ne couvrent pas**, comme :
- redimensionnement de fenêtre  
- pause/reprise mobile  
- changement de langue  
- drag & drop  
- perte/gain de focus OS  
- avertissements mémoire  
- événements internes du moteur  

Ce fichier regroupe les **notifications les plus utiles**, classées par catégories.

<br />

---

<br />

# 🔵 1. Notifications liées au Cycle de Vie  
> ⚠️ Déjà couvert dans le fichier principal (cycle de vie).  
> On utilise généralement les callbacks `*_tree()`, `*_process()` à la place.

| Notification | Explication |
|-------------|-------------|
| `NOTIFICATION_ENTER_TREE` | Équivalent interne de `_enter_tree()` |
| `NOTIFICATION_READY` | Équivalent interne de `_ready()` |
| `NOTIFICATION_EXIT_TREE` | Équivalent interne de `_exit_tree()` |
| `NOTIFICATION_PROCESS` | Envoi chaque frame si `set_process(true)` |
| `NOTIFICATION_PHYSICS_PROCESS` | Envoi chaque tick physique si `set_physics_process(true)` |

<br />

---

<br />

# 🔵 2. Notifications OS / Fenêtre (les plus importantes)

| Notification | Quand ? |
|-------------|---------|
| `NOTIFICATION_WM_WINDOW_FOCUS_IN` | La fenêtre reçoit le focus |
| `NOTIFICATION_WM_WINDOW_FOCUS_OUT` | La fenêtre perd le focus |
| `NOTIFICATION_WM_CLOSE_REQUEST` | L’utilisateur ferme la fenêtre |
| `NOTIFICATION_WM_GO_BACK_REQUEST` | Bouton “Back” Android |
| `NOTIFICATION_WM_SIZE_CHANGED` | La fenêtre est redimensionnée |
| `NOTIFICATION_WM_DPI_CHANGE` | Changement de DPI (macOS/iOS) |
| `NOTIFICATION_WM_MOUSE_ENTER` | La souris entre dans la fenêtre |
| `NOTIFICATION_WM_MOUSE_EXIT` | La souris quitte la fenêtre |
| `NOTIFICATION_WM_POSITION_CHANGED` | Déplacement de la fenêtre |

<br />

---

<br />

# 🔵 3. Notifications Application (Android / iOS / Desktop)

| Notification | Explication |
|-------------|-------------|
| `NOTIFICATION_APPLICATION_PAUSED` | L’application passe en arrière-plan |
| `NOTIFICATION_APPLICATION_RESUMED` | L’application revient au premier plan |
| `NOTIFICATION_APPLICATION_FOCUS_IN` | L'application reçoit le focus |
| `NOTIFICATION_APPLICATION_FOCUS_OUT` | L'application perd le focus |
| `NOTIFICATION_OS_MEMORY_WARNING` | Avertissement mémoire (iOS) |

⚠️ **Sur iOS, après un pause, tu n’as que ~5 secondes pour terminer un traitement**, sinon l’app est tuée.

<br />

---

<br />

# 🔵 4. Notifications UI, Drag & Drop, Éditeur

| Notification | Explication |
|-------------|-------------|
| `NOTIFICATION_DRAG_BEGIN` | Début d’un drag UI |
| `NOTIFICATION_DRAG_END` | Fin d’un drag |
| `NOTIFICATION_TEXT_SERVER_CHANGED` | Changement du moteur de rendu texte |
| `NOTIFICATION_EDITOR_PRE_SAVE` | Avant la sauvegarde d’une scène dans l’éditeur |
| `NOTIFICATION_EDITOR_POST_SAVE` | Après une sauvegarde |

<br />

---

<br />

# 🔵 5. Notifications Hiérarchie / Noms / Enfants

| Notification | Explication |
|-------------|-------------|
| `NOTIFICATION_PATH_RENAMED` | Un node ou parent change de nom |
| `NOTIFICATION_CHILD_ORDER_CHANGED` | Un enfant est ajouté, retiré ou déplacé |
| `NOTIFICATION_PARENTED` | Ce node vient d’être ajouté au parent |
| `NOTIFICATION_UNPARENTED` | Ce node vient d’être retiré du parent |

<br />

---

<br />

# 🔵 6. Notifications traduction / langue

| Notification | Explication |
|-------------|-------------|
| `NOTIFICATION_TRANSLATION_CHANGED` | La langue ou traduction a changé |

Exemple :

```gdscript
func _notification(what):
    if what == NOTIFICATION_TRANSLATION_CHANGED:
        if not is_node_ready():
            await ready
        $Label.text = atr("%d Bananas") % banana_counter
```

<br />

---

<br />

# 🔵 7. Notifications avancées & internes

| Notification | Explication |
|-------------|-------------|
| `NOTIFICATION_RESET_PHYSICS_INTERPOLATION` | Réinitialisation interpolation |
| `NOTIFICATION_INTERNAL_PROCESS` | Process interne |
| `NOTIFICATION_INTERNAL_PHYSICS_PROCESS` | Physique interne |
| `NOTIFICATION_CRASH` | Godot va crasher (debug) |

<br />

---

<br />

# 🟣 Exemple d’utilisation en GDScript / C++

## ✔ GDScript

```gdscript
func _notification(what):
    match what:
        NOTIFICATION_WM_WINDOW_FOCUS_IN:
            print("Focus in")

        NOTIFICATION_WM_WINDOW_FOCUS_OUT:
            print("Focus out")

        NOTIFICATION_APPLICATION_PAUSED:
            print("App paused")

        NOTIFICATION_APPLICATION_RESUMED:
            print("App resumed")

        NOTIFICATION_TRANSLATION_CHANGED:
            print("Language updated")
```

---

## ✔ C++

```cpp
void MyNode::_notification(int p_what) {
    switch (p_what) {
        case NOTIFICATION_WM_WINDOW_FOCUS_IN:
            print_line("Focus in");
            break;

        case NOTIFICATION_WM_WINDOW_FOCUS_OUT:
            print_line("Focus out");
            break;

        case NOTIFICATION_APPLICATION_PAUSED:
            print_line("Paused");
            break;

        case NOTIFICATION_APPLICATION_RESUMED:
            print_line("Resumed");
            break;

        case NOTIFICATION_TRANSLATION_CHANGED:
            print_line("Translation changed");
            break;
    }
}
```

<br />

---

<br />

# 📘 Résumé

## Quand utiliser `_notification()` ?
✔ Événements OS  
✔ Langue / localisation  
✔ Drag & drop  
✔ Changement de fenêtre / DPI  
✔ Comportements mobiles  

## Quand NE PAS l’utiliser ?
❌ Pour le cycle de vie → utilise `_ready()`, `_enter_tree()`, etc.  
❌ Pour le gameplay → utilise `_process()` / `_physics_process()`.