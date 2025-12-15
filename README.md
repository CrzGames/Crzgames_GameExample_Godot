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


## Projet Godot du jeu ce qui est déjà configurer depuis l'éditeur Godot.
- Activation de **Nearest** pour toutes les textures
- Résolution logique du jeu par défault (**640×360**)
- Résolution de la fenetre par défault lors de l'ouverture (**1280x720**)
- Etirement :
  - `Mode` : **`viewport`** pour un rendu pixel art rétro / pixel-perfect
  - `Aspect` : **`keep`** (bandes noires acceptées si besoin, letterbox/pillarbox)
  - `Mode mise à l'échelle`  : 1.0
  - `Mode de misee à l'échelle` : integer
- Désactivation **l'antialliasing pour les fonts**.
- Désactivation du **HDR 2D**.
- Activation de **Snap 2D Transforms to Pixel**.

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

4. Pour `Windows`, `le moteur de rendu Godot utilise à présent Direct3D12 par défault` à partir de la version >= `4.6.x` de Godot Engine au lieu de Vulkan, il faut lancer un script Python pour installer les dépendences :
```bash
cd dependencies/godot
python misc/scripts/install_d3d12_sdk_windows.py
```
`Pour utiliser Vulkan par défault (déconseillé)` passé cela à `SCons` : `d3d12=no`.

5. Compiler l'editeur Godot Engine, depuis la racine de ce dépôt :
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
2. Concernant les versions `snapshot` de Godot Engine comme `4.6-beta1`, il faut récupérer le commit_sha du dernier commit, ici par exemple : https://godotengine.github.io/godot-interactive-changelog/, cliquer sur la version snapshot souhaiter et il y a le numéro du commit.
3. Supprimer le dossier de la librairie qu'ont a modifier la version, situé dans le dossier : dependencies/
4. Exécutez le script à la racine du projet :
```bash
cmake -P cmake/setup_dependencies.cmake
```
5. Recompiler l'editeur Godot avec les scripts situé dans `build-scripts/` à la racine du projet :
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
2. Ouvrir l'executable de l'editeur Godot Engine ou ouvrir l'executable du jeu sans l'editeur (comme si on faisais run depuis l'editeur Godot) :
```bash
# Windows :
.\build-scripts\windows\run_windows_editor.bat # Editor
.\build-scripts\windows\run_windows_game.bat   # Game

# macOS

# Linux
```

<br /><br /><br /><br />


## Production
### ⚙️➡️ Automatic Distribution Process (CI / CD)

<br /><br />

### ✋ Manual Distribution Process
