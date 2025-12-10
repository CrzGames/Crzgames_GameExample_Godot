# 🔄 Tests unitaires pour les modules C++ Godot

Godot 4.x inclut un système de **tests unitaires natifs** basé sur **doctest**.  
⚠️ **Les tests unitaires ne fonctionnent que pour les modules C++**, et **pas** pour les extensions GDExtension.

---

## 📁 Structure obligatoire pour les tests

Pour que Godot détecte vos tests :

1. Créez un dossier **`tests/`** dans votre module.
2. Tous les fichiers de test doivent :
   - être des **fichiers header `.h`** (jamais `.cpp`)
   - commencer par le préfixe **`test_`**
3. Structure exacte :

```
modules/<nom_du_module>/tests/
```

### Exemple de structure :

```
modules/
  summator/
    summator.h
    summator.cpp
    register_types.cpp
    register_types.h
    tests/
      test_summator_basic.h
      test_summator_advanced.h
```

---

## ❗ Règles de nommage importantes

| Élément | Règle |
|--------|-------|
| Nom de fichier | doit commencer par **`test_`** |
| Préfixe recommandé | **`test_<nom_du_module>_*.h`** |
| Type | fichier `.h` uniquement |
| Emplacement | `modules/<module>/tests/` |

Exemples valides :

```
test_summator_math.h
test_summator_edge_cases.h
```

---

## ✨ Exemple minimal de fichier de test

`modules/summator/tests/test_summator_basic.h` :

```cpp
#include "modules/summator/summator.h"
#include "core/io/logger.h"

TEST_CASE("[Summator] Addition simple") {
    Summator s;
    s.add(10);
    s.add(5);
    CHECK(s.get_total() == 15);
}

TEST_CASE("[Summator] Comportement du reset") {
    Summator s;
    s.add(20);
    s.reset();
    CHECK(s.get_total() == 0);
}
```

---

## ▶️ Lancer les tests unitaires

Après compilation du moteur (avec votre module), lancez les tests avec :

```bash
./path/to/godot_editor.exe --test --source-file="*test_summator*" --success
```

### Explication des arguments :

| Argument | Rôle |
|----------|------|
| `--test` | exécute Godot en mode test |
| `--source-file="pattern"` | filtre les fichiers de tests à exécuter |
| `--success` | affiche également les tests réussis |

---

## ⭐ Résumé

- ✔ Fonctionne uniquement pour les **modules C++ intégrés au moteur**  
- ✔ Dossier obligatoire : `modules/<module>/tests/`  
- ✔ Tous les fichiers doivent commencer par `test_`  
- ✔ Tests écrits via **doctest** (intégré dans Godot)  
- ✔ Lancement simple via `godot --test`  