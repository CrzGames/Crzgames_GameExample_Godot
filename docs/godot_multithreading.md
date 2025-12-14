# 📘 Godot 4.x — Threading (Multithreading)
## Utiliser plusieurs fils d’exécution proprement (GDScript / C++)

Les **threads** permettent d’exécuter du code **en parallèle** pour **décharger le thread principal** (celui qui gère le rendu, l’input, la logique de scène…).

Godot supporte le multithreading et fournit plusieurs outils :
- `Thread` → exécuter une fonction sur un autre thread
- `Mutex` → protéger des données partagées
- `Semaphore` → réveiller un thread “à la demande”
- (et d’autres : `RWLock`, `Condition`, `WorkerThreadPool`, etc.)

> ⚠️ Avant d’utiliser une API Godot dans un thread, lis d’abord la section **“API thread-safe”** de ce document (plus bas).  
> Le point le plus important : **l’arbre de scène (SceneTree) n’est PAS thread-safe**.

---

## 📑 Sommaire

- [🧠 Modèle mental](#-modèle-mental)
- [0. Règles d’or (à retenir)](#0-règles-dor-à-retenir)
- [1. Créer un thread](#1-créer-un-thread)
  - [1.1 GDScript](#11-gdscript)
  - [1.2 C++](#12-c)
- [2. Mutex](#2-mutex)
  - [2.1 Pourquoi un Mutex ?](#21-pourquoi-un-mutex-)
  - [2.2 GDScript](#22-gdscript)
  - [2.3 C++](#23-c)
- [3. Semaphores](#3-semaphores)
  - [3.1 Quand utiliser un Semaphore ?](#31-quand-utiliser-un-semaphore-)
  - [3.2 GDScript](#32-gdscript)
  - [3.3 C++](#33-c)
- [4. API sûres / non sûres (Thread Safety)](#4-api-sûres--non-sûres-thread-safety)
  - [4.1 Portée globale (singletons Global Scope)](#41-portée-globale-singletons-global-scope)
  - [4.2 Arbre de scène (SceneTree)](#42-arbre-de-scène-scenetree)
  - [4.3 Rendu / GPU](#43-rendu--gpu)
  - [4.4 Tableaux / Dictionnaires en GDScript](#44-tableaux--dictionnaires-en-gdscript)
  - [4.5 Ressources](#45-ressources)
- [5. Patterns propres (pratiques)](#5-patterns-propres-pratiques)
  - [5.1 Thread de calcul → résultat → main thread](#51-thread-de-calcul--résultat--main-thread)
  - [5.2 Thread “worker” persistent (avec Semaphore)](#52-thread-worker-persistent-avec-semaphore)
  - [5.3 call_deferred : la passerelle sûre vers la scène](#53-call_deferred--la-passerelle-sûre-vers-la-scène)
- [6. Pièges classiques](#6-pièges-classiques)
- [📚 Références officielles](#-références-officielles)

---

## 🧠 Modèle mental

```
Main thread = scène + rendu + input + gameplay “visible”
Worker thread = calcul / IO / préparation de données
Mutex = “je protège une donnée partagée”
Semaphore = “je dors tant qu’on ne me réveille pas”
```

Le bon workflow dans Godot est souvent :

1) Calcul lourd dans un thread (IA, pathfinding, génération, parsing, etc.)  
2) Tu écris le résultat dans une structure partagée **protégée** (Mutex)  
3) Tu reviens au main thread pour appliquer le résultat (via `call_deferred` / signal / file de jobs)

---

## 0. Règles d’or (à retenir)

✅ À faire :
- Faire du multithreading pour **les calculs**, **le chargement**, **la préparation de données**
- **Protéger** toute donnée partagée avec un `Mutex`
- Passer de worker → scène via `call_deferred()` (ou signal émis depuis le main thread)
- Toujours “join” un thread (attendre la fin) avec `wait_to_finish()`

❌ À éviter :
- Modifier directement le **SceneTree** depuis un thread (`add_child`, `queue_free`, etc.)
- Faire des opérations qui touchent directement au GPU (textures/images) sur un autre thread
- Créer/détruire des threads en boucle en gameplay (coûteux, surtout Windows)

> ⚠️ Créer des threads est lent (notamment sur Windows).  
> Préfère : créer des workers au chargement du niveau, et les réutiliser ensuite.

---

## 1. Créer un thread

### 1.1 GDScript

> Objectif : démarrer un thread au `_ready()`, le terminer proprement à `_exit_tree()`.

```gdscript
extends Node

var worker: Thread

func _ready() -> void:
    worker = Thread.new()
    worker.start(Callable(self, "_threaded_function"))

func _exit_tree() -> void:
    if worker:
        worker.wait_to_finish()
        worker = null

func _threaded_function() -> void:
    print("Thread started!")
    var i := 0
    var start := Time.get_ticks_msec()
    while Time.get_ticks_msec() - start < 5000:
        OS.delay_msec(10)
        i += 1
    print("Thread counted to:", i)
```

✅ Ce que ça montre :
- La fonction threadée tourne **jusqu’au return**
- `wait_to_finish()` est obligatoire pour cleanup portable

---

### 1.2 C++

> Même exemple que la doc : `Thread.start(callable_mp(...))` + `wait_to_finish()` au `EXIT_TREE`.

**Header : `multithreading_demo.h`**
```cpp
#pragma once

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/thread.hpp>

namespace godot {

class MultithreadingDemo : public Node {
    GDCLASS(MultithreadingDemo, Node);

private:
    Ref<Thread> worker;

protected:
    static void _bind_methods();
    void _notification(int p_what);

public:
    MultithreadingDemo();
    ~MultithreadingDemo();

    void demo_threaded_function();
};

} // namespace godot
```

**CPP : `multithreading_demo.cpp`**
```cpp
#include "multithreading_demo.h"

#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/classes/os.hpp>
#include <godot_cpp/classes/time.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void MultithreadingDemo::_bind_methods() {
    ClassDB::bind_method(D_METHOD("threaded_function"), &MultithreadingDemo::demo_threaded_function);
}

void MultithreadingDemo::_notification(int p_what) {
    // Ne pas exécuter dans l'éditeur (en Godot 4.3+ tu peux préférer des runtime classes).
    if (Engine::get_singleton()->is_editor_hint()) {
        return;
    }

    switch (p_what) {
        case NOTIFICATION_READY: {
            worker.instantiate();
            worker->start(callable_mp(this, &MultithreadingDemo::demo_threaded_function), Thread::PRIORITY_NORMAL);
        } break;

        case NOTIFICATION_EXIT_TREE: {
            if (worker.is_valid()) {
                worker->wait_to_finish();
            }
            worker.unref();
        } break;
    }
}

MultithreadingDemo::MultithreadingDemo() {}
MultithreadingDemo::~MultithreadingDemo() {}

void MultithreadingDemo::demo_threaded_function() {
    UtilityFunctions::print("demo_threaded_function started!");
    int i = 0;
    uint64_t start = Time::get_singleton()->get_ticks_msec();

    while (Time::get_singleton()->get_ticks_msec() - start < 5000) {
        OS::get_singleton()->delay_msec(10);
        i++;
    }

    UtilityFunctions::print("demo_threaded_function counted to: ", i, ".");
}
```

---

## 2. Mutex

### 2.1 Pourquoi un Mutex ?

Même si “ça marche parfois”, accéder à une donnée depuis plusieurs threads **sans protection** peut provoquer :
- valeurs incohérentes (race condition)
- crash (modification simultanée)
- bugs “aléatoires” impossibles à reproduire

Règle simple :
> **Dès qu’une donnée peut être lue/écrite par plusieurs threads → Mutex.**

---

### 2.2 GDScript

```gdscript
extends Node

var counter := 0
var mutex := Mutex.new()
var t: Thread

func _ready() -> void:
    print("Counter starts at:", counter)
    t = Thread.new()
    t.start(Callable(self, "_thread_fn"))

    # Main thread incrémente aussi (protégé)
    mutex.lock()
    counter += 1
    print("Counter after main +1:", counter)
    mutex.unlock()

func _exit_tree() -> void:
    if t:
        t.wait_to_finish()
        t = null
    print("Counter at exit:", counter) # devrait être 2

func _thread_fn() -> void:
    mutex.lock()
    counter += 1
    mutex.unlock()
```

---

### 2.3 C++

**Header : `mutex_demo.h`**
```cpp
#pragma once

#include <godot_cpp/classes/mutex.hpp>
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/thread.hpp>

namespace godot {

class MutexDemo : public Node {
    GDCLASS(MutexDemo, Node);

private:
    int counter = 0;
    Ref<Mutex> mutex;
    Ref<Thread> thread;

protected:
    static void _bind_methods();
    void _notification(int p_what);

public:
    MutexDemo();
    ~MutexDemo();

    void thread_function();
};

} // namespace godot
```

**CPP : `mutex_demo.cpp`**
```cpp
#include "mutex_demo.h"

#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void MutexDemo::_bind_methods() {
    ClassDB::bind_method(D_METHOD("thread_function"), &MutexDemo::thread_function);
}

void MutexDemo::_notification(int p_what) {
    if (Engine::get_singleton()->is_editor_hint()) {
        return;
    }

    switch (p_what) {
        case NOTIFICATION_READY: {
            UtilityFunctions::print("Mutex Demo Counter is starting at: ", counter);

            mutex.instantiate();
            thread.instantiate();
            thread->start(callable_mp(this, &MutexDemo::thread_function), Thread::PRIORITY_NORMAL);

            // Main thread +1 (protégé)
            mutex->lock();
            counter += 1;
            UtilityFunctions::print("Mutex Demo Counter is ", counter, " after adding with Mutex protection.");
            mutex->unlock();
        } break;

        case NOTIFICATION_EXIT_TREE: {
            if (thread.is_valid()) {
                thread->wait_to_finish();
            }
            thread.unref();

            UtilityFunctions::print("Mutex Demo Counter is ", counter, " at EXIT_TREE."); // attendu : 2
        } break;
    }
}

MutexDemo::MutexDemo() {}
MutexDemo::~MutexDemo() {}

void MutexDemo::thread_function() {
    mutex->lock();
    counter += 1;
    mutex->unlock();
}
```

---

## 3. Semaphores

### 3.1 Quand utiliser un Semaphore ?

Quand tu veux un thread **persistant** qui :
- dort tant qu’il n’a rien à faire
- se réveille “à la demande” (job, signal, événement)
- évite de tourner en boucle (polling) dans le vide

Le worker fait :
- `semaphore.wait()` → dort jusqu’à un `post()`

Le main thread fait :
- `semaphore.post()` → réveille le worker

---

### 3.2 GDScript

Exemple : un worker qui incrémente `counter` uniquement quand on lui demande.

```gdscript
extends Node

var counter := 0
var mutex := Mutex.new()
var sem := Semaphore.new()
var t: Thread
var exit_thread := false

func _ready() -> void:
    t = Thread.new()
    t.start(Callable(self, "_thread_fn"))

    increment_counter() # demande 1 job

func _exit_tree() -> void:
    mutex.lock()
    exit_thread = true
    mutex.unlock()

    sem.post() # réveille le thread pour qu'il voie exit_thread

    if t:
        t.wait_to_finish()
        t = null

    print("Counter at exit:", get_counter())

func _thread_fn() -> void:
    while true:
        sem.wait()

        mutex.lock()
        var should_exit := exit_thread
        mutex.unlock()
        if should_exit:
            break

        mutex.lock()
        counter += 1
        mutex.unlock()

func increment_counter() -> void:
    sem.post()

func get_counter() -> int:
    mutex.lock()
    var v := counter
    mutex.unlock()
    return v
```

---

### 3.3 C++

**Header : `semaphore_demo.h`**
```cpp
#pragma once

#include <godot_cpp/classes/mutex.hpp>
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/semaphore.hpp>
#include <godot_cpp/classes/thread.hpp>

namespace godot {

class SemaphoreDemo : public Node {
    GDCLASS(SemaphoreDemo, Node);

private:
    int counter = 0;
    Ref<Mutex> mutex;
    Ref<Semaphore> semaphore;
    Ref<Thread> thread;
    bool exit_thread = false;

protected:
    static void _bind_methods();
    void _notification(int p_what);

public:
    SemaphoreDemo();
    ~SemaphoreDemo();

    void thread_function();
    void increment_counter();
    int get_counter();
};

} // namespace godot
```

**CPP : `semaphore_demo.cpp`**
```cpp
#include "semaphore_demo.h"

#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

void SemaphoreDemo::_bind_methods() {
    ClassDB::bind_method(D_METHOD("thread_function"), &SemaphoreDemo::thread_function);
}

void SemaphoreDemo::_notification(int p_what) {
    if (Engine::get_singleton()->is_editor_hint()) {
        return;
    }

    switch (p_what) {
        case NOTIFICATION_READY: {
            UtilityFunctions::print("Semaphore Demo Counter is starting at: ", counter);

            mutex.instantiate();
            semaphore.instantiate();
            exit_thread = false;

            thread.instantiate();
            thread->start(callable_mp(this, &SemaphoreDemo::thread_function), Thread::PRIORITY_NORMAL);

            increment_counter(); // demande 1 job
        } break;

        case NOTIFICATION_EXIT_TREE: {
            // Demande d’arrêt (protégé)
            mutex->lock();
            exit_thread = true;
            mutex->unlock();

            // Réveille le thread pour qu’il sorte
            semaphore->post();

            if (thread.is_valid()) {
                thread->wait_to_finish();
            }
            thread.unref();

            UtilityFunctions::print("Semaphore Demo Counter is ", get_counter(), " at EXIT_TREE.");
        } break;
    }
}

SemaphoreDemo::SemaphoreDemo() {}
SemaphoreDemo::~SemaphoreDemo() {}

void SemaphoreDemo::thread_function() {
    while (true) {
        semaphore->wait();

        mutex->lock();
        bool should_exit = exit_thread;
        mutex->unlock();

        if (should_exit) {
            break;
        }

        mutex->lock();
        counter += 1;
        mutex->unlock();
    }
}

void SemaphoreDemo::increment_counter() {
    semaphore->post();
}

int SemaphoreDemo::get_counter() {
    mutex->lock();
    int counter_value = counter;
    mutex->unlock();
    return counter_value;
}
```

---

## 4. API sûres / non sûres (Thread Safety)

### 4.1 Portée globale (singletons Global Scope)

✅ Les singletons de Global Scope sont **thread-safe**.  
✅ Accéder aux **Servers** depuis des threads est supporté.

> ⚠️ Pour `RenderingServer` / `PhysicsServer`, assure-toi que le mode threadé / thread-safe est activé si nécessaire (Project Settings).

👉 C’est idéal si tu veux produire beaucoup d’instances côté serveurs **sans toucher au SceneTree**.

---

### 4.2 Arbre de scène (SceneTree)

❌ Interagir avec l’arbre de scène actif n’est **PAS thread-safe**.

Unsafe :
```gdscript
node.add_child(child_node)
```

Safe (main thread) :
```gdscript
node.add_child.call_deferred(child_node)
```

✅ Autorisé : construire des nodes **en dehors** de l’arbre actif, puis les ajouter sur le thread principal :

```gdscript
var enemy_scene = load("res://enemy_scene.tscn")
var enemy = enemy_scene.instantiate()

enemy.add_child(weapon) # encore hors arbre actif
world.add_child.call_deferred(enemy) # ajout safe
```

> ⚠️ Attention : charger la même ressource depuis plusieurs threads peut provoquer des comportements inattendus si cette ressource est modifiée en parallèle.

---

### 4.3 Rendu / GPU

❌ Instancier des nodes de rendu (Sprite/3D, etc.) n’est pas thread-safe par défaut.  
Tu peux rendre le rendu plus thread-safe via : `Rendering > Driver > Thread Model = Multi-Threaded`  
… mais ce mode peut avoir des bugs connus selon les versions / plateformes.

⚠️ Évite d’appeler des fonctions qui interagissent directement avec le GPU sur d’autres threads :
- créer/modifier des textures
- modifier/récupérer des données d’image

➡️ Ces opérations peuvent provoquer des stalls (synchronisation avec le RenderingServer).

---

### 4.4 Tableaux / Dictionnaires en GDScript

✅ Lire/écrire des éléments depuis plusieurs threads est possible **tant que tu ne changes pas la taille**.  
⚠️ Tout ce qui redimensionne (append/erase/resize) → **Mutex obligatoire**.

---

### 4.5 Ressources

✅ La gestion de références est supportée sur plusieurs threads.  
✅ Charger des ressources sur un thread est OK (scènes, textures, meshes…), puis appliquer sur le main thread.

❌ Modifier une **même ressource** depuis plusieurs threads n’est pas supporté.

---

## 5. Patterns propres (pratiques)

### 5.1 Thread de calcul → résultat → main thread

Pattern typique :
- worker calcule (sans SceneTree)
- écrit le résultat dans `shared_result` (Mutex)
- main thread lit `shared_result` et applique (SceneTree)

✅ Idéal pour :
- pathfinding
- génération de map
- parsing JSON
- compression/décompression
- IA

---

### 5.2 Thread “worker” persistent (avec Semaphore)

- Le thread dort, ne consomme rien
- Tu “post” quand tu as un job
- Tu peux faire une petite queue de jobs (protégée par Mutex)

✅ C’est généralement mieux que créer/détruire des threads en boucle.

---

### 5.3 call_deferred : la passerelle sûre vers la scène

Quand tu veux modifier la scène depuis un worker :
- tu ne le fais pas
- tu demandes au main thread via `call_deferred`

Exemple :

```gdscript
# depuis un thread : tu peux déclencher un callback main-thread
Callable(self, "_apply_result").call_deferred(result)
```

---

## 6. Pièges classiques

- Oublier `wait_to_finish()` → leaks / comportements non portables
- Mutex lock trop long → ton thread principal peut se retrouver bloqué
- Polling en boucle (`while true` sans wait) → CPU à 100%
- Modifier une Resource partagée depuis plusieurs threads
- Toucher au SceneTree depuis un worker (crash aléatoire)

---

## 📚 Références officielles

- Utiliser plusieurs fils d’exécution (Thread/Mutex/Semaphore) :
  https://docs.godotengine.org/fr/4.x/tutorials/performance/using_multiple_threads.html

- API sûres pour plusieurs fils d’exécution (Thread Safety) :
  https://docs.godotengine.org/fr/4.x/tutorials/performance/thread_safe_apis.html
