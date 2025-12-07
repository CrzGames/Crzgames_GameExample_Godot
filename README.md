# Crzgames - Game Example - Godot

## 🛠 Tech Stack
- C++ / GDScript (Language)
- CI / CD (Github Actions)
- CMake / SCons (Build script)
- Compiler (GCC, CL, Clang, NDK)

<br /><br /><br /><br />


## 📁 Project Structure

```
📦 Crzgames_RC2DCore
├── 📁 .github                        # Configuration GitHub (workflows CI/CD)
├── 📁 build-scripts                  # Scripts de build personnalisés (.sh / .bat), puis les scripts utilise le CMakelists.txt
├── 📁 cmake                          
│   └── 📄 setup_dependencies.cmake   # Script CMake chargé de lire `dependencies.txt` et cloner/configurer les dépendances dans `/dependencies`
├── 📁 dependencies (git ignored)     # Répertoire local contenant les dépendances clonées (ignoré par Git pour ne pas polluer le repo)
│   ├── 📁 godot                    # Extension SDL3 pour le rendu de polices TrueType
│   ├── 📁 godot-cpp                  # Extension SDL3 pour la gestion audio avancée
├── 📁 docs                           # Documentation du moteur (pages Markdown, auto-générées ou manuelles)
├── 📁 include                        # En-têtes publics exposés aux utilisateurs de la lib (API du moteur)
├── 📁 src                            # Code source interne de la bibliothèque RC2D (implémentations .c)
├── 📁 tests                          # Tests unitaires (avec Criterion) pour vérifier les modules du moteur
├── 📄 .gitignore                     # Fichiers/dossiers à ignorer par Git (ex: /dependencies, builds temporaires)
├── 📄 CHANGELOG.md                   # Historique des versions avec les modifications apportées à chaque release
├── 📄 CMakeLists.txt                 # Point d’entrée de la configuration CMake (build multiplateforme)
├── 📄 dependencies.txt               # Fichier listant les dépendances à cloner (format : nom=repo:version)
├── 📄 README.md                      # Page d’accueil du dépôt (description, installation, exemples d’usage)
├── 📄 release-please-config.json     # Configuration pour `release-please` (outil Google de génération automatique de releases)
├── 📄 version.txt                    # Contient la version actuelle du moteur (utilisé dans le build ou les releases)

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
| **Steam Linux** | x64 / arm64 | Steam Linux Runtime 3.0 (Sniper) | ✓ |
| **Steam Deck** | x64 | Steam Linux Runtime 3.0 (Sniper) | ✓ |
| **Xbox** | x64 | Xbox Série X/S+ |  |
| **Nintendo Switch** | arm64 | Nintendo Switch 1+ |  |
| **Playstation** | x64 | Playstation 5+ |  |

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
  git clone git@github.com:CrzGames/Crzgames_RC2DCore.git
  ```
2. Steps by Platform :
  ```bash
  # Windows :
  1. Requirements : Windows >= 10 (x64 or x86 or arm64)
  2. Download and Install Visual Studio == 2022 (MSVC >= v143 + Windows SDK >= 10) : https://visualstudio.microsoft.com/fr/downloads/
  3. Download and Install CMake >= 3.25 : https://cmake.org/download/ and add PATH ENVIRONMENT.
  4. Download and Install Python >= 3.8 : https://www.python.org/downloads/ and add PATH ENVIRONMENT.
  5. Download and Install SCons >= 0.4.0, ouvrir le powershell (pas en administrateur) puis : <br />
     Set-ExecutionPolicy RemoteSigned -Scope CurrentUser <br /> (choisir la touche "O" (oui))
     irm get.scoop.sh | iex (pour installer faire la touche ENTER, permet dinstaller)
  6. Installer : <br />
     python -m pip install scons
  7. Installer le SDK Vulkan pour la couche de validation (debug shaders..etc) : https://vulkan.lunarg.com/sdk/home



  # Linux :
  1. Requirements : glibc >= 3.25 (Ubuntu >= 22.04 OR Debian >= 12.0)
  2. Download and Install brew : /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  3. Après l'installation de homebrew il faut importer les variables d'environnement et installer les deux librairies : 
    echo '# Set PATH, MANPATH, etc., for Homebrew.' >> /home/debian/.bashrc && 
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/debian/.bashrc && 
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" &&
    sudo apt-get install -y build-essential &&
    brew install gcc
  5. Download and Install CMake >= 3.25 : brew install cmake
  6. Télécharger et Installer patchelf (pour la dépendence SDL_shadercross), puis ajouté au PATH.


  # macOS :
  1. Requirements : MacOS X >= 15.0.0
  2. Download and Install xCode >= 16.4.0
  3. Download and Install Command Line Tools : xcode-select --install
  4. Download and Install CMake >= 3.25 : brew install cmake
  ```
  
4. Avant toute compilation, exécute le script suivant :

```bash
cmake -P cmake/setup_dependencies.cmake
```

Ce script va :
- Lire `dependencies.txt`
- Cloner chaque dépôt dans `dependencies/`
- Faire un `git reset --hard` au commit_sha/tag fourni
- Initialiser les sous-modules si présents dans les librairies cloner

<br /><br /><br /><br />


## 🔄 Updating Dependencies
1. Modifiez le tag/commit_sha dans `dependencies.txt` de la librairie souhaiter.
2. Exécutez le script à la racine du projet :
```bash
cmake -P cmake/setup_dependencies.cmake
```
3. Recompiler Godot avec les scripts situé dans `build-scripts/`, par exemple pour Windows : `.\build-scripts\windows\build_windows_editor_dev.bat`
4. Supprimer `.godot/` dans le projet
5. Ouvrir l'editeur Godot qui à était recompiler avec la nouvelle version de Godot, situé par exemple dans : `dependencies/godot/bin/godot.windows.editor.dev.x86_64.dev.exe`. Ensuite il faut ouvrir le dossier du jeu depuis l'editeur Godot qui est actuellement ouvert.

<br /><br /><br /><br />


## 🔄 Cycle Development
1. Générer le projet du jeu d'exemple
```bash
# Linux - x64
chmod +x ./build-scripts/linux-x64.sh
./build-scripts/linux-x64.sh

# Linux - arm64
chmod +x ./build-scripts/linux-arm64.sh
./build-scripts/linux-arm64.sh

# macOS - Apple Silicon arm64
chmod +x ./build-scripts/macos-arm64.sh
./build-scripts/macos-arm64.sh

# Windows - x64
.\build-scripts\windows-x64.bat

# Windows - arm64
.\build-scripts\windows-arm64.bat

# Android (Unix)
chmod +x ./build-scripts/android.sh
./build-scripts/android.sh

# Android (Windows)
.\build-scripts\android.bat

# iOS (run in macOS)
chmod +x ./build-scripts/ios.sh
./build-scripts/ios.sh
```
3. Il y a un dossier `build` à la racine qui est générer.
```bash
# Pour Windows x64 par exemple, un projet Visual Studio 2022 à été générer au path suivant :
.\build\windows\x64
```
4. Ouvrir le projet générer dans votre IDE favoris.

<br /><br /><br /><br />


## Production
### ⚙️➡️ Automatic Distribution Process (CI / CD)
#### Si c'est un nouveau projet suivez les instructions : 
1. Ajoutées les SECRETS_GITHUB pour :
   - O2SWITCH_FTP_HOST
   - O2SWITCH_FTP_PASSWORD
   - O2SWITCH_FTP_PORT
   - O2SWITCH_FTP_USERNAME
   - PAT (crée un nouveau token si besoin sur le site de github puis dans le menu du "Profil" puis -> "Settings" -> "Developper Settings' -> 'Personnal Access Tokens' -> Tokens (classic))

<br /><br />

### ✋ Manual Distribution Process
1. Générer la librairie RC2D pour le mode Debug/Release.
```bash
# Linux - x64
chmod +x ./build-scripts/linux-x64.sh
./build-scripts/linux-x64.sh

# Linux - arm64
chmod +x ./build-scripts/linux-arm64.sh
./build-scripts/linux-arm64.sh

# macOS - Apple Silicon arm64
chmod +x ./build-scripts/macos-arm64.sh
./build-scripts/macos-arm64.sh

# Windows - x64
.\build-scripts\windows-x64.bat

# Windows - arm64
.\build-scripts\windows-arm64.bat

# Android (Unix)
chmod +x ./build-scripts/android.sh
./build-scripts/android.sh

# Android (Windows)
.\build-scripts\android.bat

# iOS (run in macOS)
chmod +x ./build-scripts/ios.sh
./build-scripts/ios.sh
```
2. Récupérer la librairie RC2D compilé en static pour chaque plateformes :
```bash
# Windows
1. Go directory 'dist/lib/windows/'
2. Go in directory 'Release' OR 'Debug'
3. Get librarie RC2D : rc2d_static.lib

# Linux
1. Go directory 'dist/lib/linux/'
2. Go in directory 'Release' OR 'Debug'
3. Get librarie RC2D : librc2d_static.a

# macOS
1. Go directory 'dist/lib/macos/'
2. Go in directory 'Release' OR 'Debug'
3. Get librarie RC2D : librc2d_static.a

# Android
1. Go directory 'dist/lib/android/'
2. Go in directory 'Release' OR 'Debug'
3. Get librarie RC2D : librc2d_static.so

# iOS
1. Go directory 'dist/lib/ios/'
2. Go in directory 'Release' OR 'Debug'
3. Get librarie RC2D : librc2d_static.a
```
