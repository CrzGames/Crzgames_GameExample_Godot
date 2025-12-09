# Crzgames - Template Project Godot

## 🛠 Tech Stack
- C++ / GDScript (Language) (Infos : Godot utilise un sous-ensembles de C++ 17, mais on peux utilisé la version qu'ont souhaite pour nos propre modules et extensions GDExtension)
- CI / CD (Github Actions)
- CMake / SCons (Build script)
- Compiler (GCC, CL, Clang, NDK)
- Projet de jeu Godot comme exemple (Créer à partir de l'editeur Godot v4.5.1)

<br /><br /><br /><br />


## 📁 Project Structure

```
📦 Crzgames_TemplateProjectGodot
├── 📁 .github                        # Dossier GitHub Actions (workflows CI/CD)
├── 📁 build-scripts                  # Scripts de build/run personnalisés (.sh / .bat)
├── 📁 cmake                          
│   └── 📄 setup_dependencies.cmake   # Script CMake chargé de lire `dependencies.txt` et cloner/configurer les dépendances dans `/dependencies`
├── 📁 dependencies (git ignored)     # Répertoire local contenant les dépendances clonées (ignoré par Git pour ne pas polluer le repo)
│   ├── 📁 godot                      # Repository Github de Godot Engine
├── 📁 docs                           # Documentation du moteur/projet (pages Markdown, auto-générées ou manuelles)
├── 📁 game-example-projectgodot      # Projet de jeu Godot comme exemple 
├── 📄 .gitignore                     # Fichiers/dossiers à ignorer par Git (ex: /dependencies, builds temporaires)
├── 📄 CHANGELOG.md                   # Historique des versions avec les modifications apportées à chaque release
├── 📄 dependencies.txt               # Fichier listant les dépendances à cloner (format : nom=repo:version)
├── 📄 README.md                      # Page d’accueil du dépôt (description, installation, exemples d’usage)
├── 📄 release-please-config.json     # Configuration pour `release-please` (outil Google de génération automatique de releases)
├── 📄 version.txt                    # Contient la version actuelle du projet (utilisé dans le build ou les releases)

```

<br /><br /><br /><br />


## 📋 Plateformes supportées
| Platform | Architectures | System Version | Compatible |
|----------|---------------|----------------|------------|
| **Windows** | x64 / arm64 | Windows 10+   | ✓          |
| **macOS** | Apple Silicon arm64 | macOS 15.0+ | ✓ |
| **iOS/iPadOS** | arm64 (iphoneos) - not iphonesimulator | iOS/iPadOS 18.0+ | ✓ |
| **Android** | arm64-v8a / armeabi-v7a | Android 9.0+ | ✓ |
| **Linux** | x64 / arm64 | glibc 2.35+ | ✓ |
| **Steam Linux** | x64 / arm64 | Steam Linux Runtime 3.0 (Sniper) |  |
| **Steam Deck** | x64 | Steam Linux Runtime 3.0 (Sniper) |  |
| **Xbox Série X/S** | x64 | Xbox Série X/S |  |
| **Nintendo Switch 1** | arm64 | Nintendo Switch 1 |  |
| **Nintendo Switch 2** | arm64 | Nintendo Switch 2 |  |
| **Playstation 5** | x64 | Playstation 5 |  |

<br /><br /><br /><br />


## 📱 Appareils compatibles par plateforme

### **iOS / iPadOS (18.0+)**

#### iPhones:
- iPhone XR / XS / XS Max
- iPhone SE (2/3ème génération)
- iPhone 11 / 12 / 13 / 14 / 15 / 16 (Normal, Mini, Plus, Pro, Pro Max, E) et plus récent

#### iPads:
- iPad mini (5/6ème génération, A17 Pro) et plus récent
- iPad (7/8/9/10ème génération, A16) et plus récent
- iPad Air (3/4/5ème génération, M2, M3) et plus récent
- iPad Pro (1/2/3/4/5/6ème génération, M4) et plus récent

### **macOS (15.0+)**
- Tous les modèles macOS Apple Silicon (M1, M2, M3, M4) et plus récent.

### **Android (9.0+)**
- Samsung Galaxy S9+ (2018) et plus récent.
- Google Pixel 3 et plus récent.
- OnePlus 6T et plus récent.
- Galaxy Tab S4 (2018) et plus récent.

### **Linux (glibc 2.35+)**
- Ubuntu 22.04 et plus récent.
- Debian 12 et plus récent.
- Fedora 36 et plus récent.
- Linux Mint 21 et plus récent.
- elementary OS 7 et plus récent.
- CentOS/RHEL 10 et plus récent.

### **Windows (10+)**
- Windows 10 et plus récent.

### Steam Deck (Steam Linux Runtime 3.0+ - Sniper)
- Steam Deck 1 (LCD / OLED, sous SteamOS 3.0 ou supérieur) et plus récent.

### Steam Linux (Steam Linux Runtime 3.0+ - Sniper)
- Compatible avec toute distribution Linux x64 / arm64 supportant Steam et le runtime Sniper.

<br /><br /><br /><br />


## ⚙️ Setup Environment Development
1. Cloner le projet :
  ```bash
  git clone git@github.com:CrzGames/Crzgames_TemplateProjectGodot.git
  ```
2. Steps by Platform :
  ```bash
  # Windows :
  1. Requirements : Windows >= 10 and architecture processor x64 or x86 or arm64
  2. Download and Install Visual Studio == 2022 (MSVC >= v143 + Windows SDK >= 10) : https://visualstudio.microsoft.com/fr/downloads/
  3. Download and Install CMake >= 3.25.0 : https://cmake.org/download/ and add PATH ENVIRONMENT.
  4. Download and Install Python >= 3.8.0 : https://www.python.org/downloads/ and add PATH ENVIRONMENT.
  5. Download and Install SCons >= 4.0.0, via Python : <br />
     python -m pip install scons (puis ajouté le binaire scons dans le PATH ENVIRONMENT)
  6. Installer le SDK Vulkan pour la couche de validation (debug shaders..etc) : https://vulkan.lunarg.com/sdk/home



  # macOS :
  1. Requirements : macOS >= 26.0.0 and architecture processor Apple Silicon arm64 or Intel x86_64
  2. Download and Install xCode >= 26.1.1
  3. Download and Install Command Line Tools : xcode-select --install
  4. Download and Install brew.
  5. Download and Install CMake >= 3.25.0 : brew install cmake
  6. Download and Install scons >= 4.0.0 : brew install scons
  7. Download and Install Python >= 3.8.0 : brew install python



  # Linux :
  1. Requirements : glibc >= 
  ```
  
3. Avant toute compilation, exécute le script suivant :
```bash
cmake -P cmake/setup_dependencies.cmake
```

Ce script va :
- Lire `dependencies.txt`
- Cloner chaque dépôt dans `dependencies/`
- Faire un `git reset --hard` au commit_sha/tag fourni
- Initialiser les sous-modules si présents dans les librairies cloner

4. Compiler l'editeur Godot Engine, depuis la racine de ce dépôt :
```bash
# Windows :
.\build-scripts\windows\build_windows_editor.bat

# macOS
chmod +x ./build-scripts/macos/build_macos_editor.sh
./build-scripts/macos/build_macos_editor.sh

# Linux
chmod +x ./build-scripts/linux/build_linux_editor.sh
./build-scripts/linux/build_linux_editor.sh
```

<br /><br /><br /><br />


## 🔄 Updating Dependencies
1. Modifiez le tag/commit_sha dans `dependencies.txt` de la librairie souhaiter.
2. Supprimer le dossier de la librairie qu'ont a modifier la version, situé dans le dossier : dependencies/
3. Exécutez le script à la racine du projet :
```bash
cmake -P cmake/setup_dependencies.cmake
```
4. Recompiler l'editeur Godot avec les scripts situé dans `build-scripts/` à la racine du projet :
```bash
# Windows :
.\build-scripts\windows\build_windows_editor.bat

# macOS
chmod +x ./build-scripts/macos/build_macos_editor.sh
./build-scripts/macos/build_macos_editor.sh

# Linux
chmod +x ./build-scripts/linux/build_linux_editor.sh
./build-scripts/linux/build_linux_editor.sh
```

<br /><br /><br /><br />


## 🔄 Unit Tests
Informations important : Pour les test unitaires cela marche seulements pour les modules C++, pas pour les extensions. <br />
Il faut créer un dossier appeler "tests" dans le dossier du module, par exemple : modules/mymodule/tests/. <br />
TOUT les fichiers include (.h) doit être préfixé par "test_", par exemple : test_summator.h <br /><br />

Lancer les test unitaires :
```bash
# Structure (exemple), préfixé le nom des .h par le nom du module donc test_summator_quelqueschoses
# 1er fichier de test : "modules/summator/tests/test_summator_toto1.h
# 2er fichier de test : "modules/summator/tests/test_summator_toto2.h
./bin/<godot_binary_editor> --test --source-file="*test_summator*" --success
```

<br /><br /><br /><br />


## 🔄 Cycle Development
1. (Optionnel) Rebuilder l'editeur Godot Engine à chaque modifications fait côté C++ si utilisation de modules ou extensions GDExtension :
```bash
# Windows :
.\build-scripts\windows\build_windows_editor.bat

# macOS
chmod +x ./build-scripts/macos/build_macos_editor.sh
./build-scripts/macos/build_macos_editor.sh

# Linux
chmod +x ./build-scripts/linux/build_linux_editor.sh
./build-scripts/linux/build_linux_editor.sh
```
2. Lancer l'editeur Godot Engine après qu'il à était compiler :
```bash
# Windows :
.\build-scripts\windows\run_windows_editor.bat

# macOS

# Linux
```

<br /><br /><br /><br />


## Production
### ⚙️➡️ Automatic Distribution Process (CI / CD)

<br /><br />

### ✋ Manual Distribution Process
