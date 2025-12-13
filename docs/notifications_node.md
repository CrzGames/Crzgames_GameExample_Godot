# 📘 Godot 4.x — Guide des Notifications d'un `Node`

Les notifications sont des **messages internes du moteur Godot** envoyés à chaque `Node` via :

```gdscript
# GDScript
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
- ...

📌 Les notifications sont nombreuses : **ce guide ne liste que quelques exemples**.
- Pour les valeurs exactes et la liste complète :
  https://docs.godotengine.org/en/stable/classes/class_node.html#constants

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

# 🔵 2. Notifications OS / Fenêtre

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

# 🟣 Exemple d’utilisation en GDScript / C++

## GDScript

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

## C++

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
