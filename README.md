# 🌌 Galactic Glitch Hunters

> **A Narrative Logic-Puzzler where you debug the galaxy's prejudice.**
> *Project Nova | Built with Godot 4 | CS Capstone Project*

![Status](https://img.shields.io/badge/Status-In%20Development-yellow)
![Engine](https://img.shields.io/badge/Godot-4.x-478cbf?logo=godotengine)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📜 The Premise
The year is 30XX. You are the newest Cadet in the **Galactic Harmony Corps**.

An ancient, dormant virus known as **"The Bias"** has resurfaced. It does not destroy hardware; it corrupts logic. It rewrites the behavioral code of droids and citizens, forcing them to act on outdated, unfair, and toxic stereotypes.

Your mission is not to fight enemies with lasers, but to **fight bad logic with better logic**. Accompanied by **Nova**, your hyper-intelligent AI co-pilot (who is often ignored by the glitching systems), you must travel to infected planets and "Debug" the population.

---

## 🎮 Gameplay Mechanics

**Galactic Glitch Hunters** is a 10-minute session-based game designed to be replayable.

### 1. The Loop 
* **The Deploy:** The game randomly selects **3 Planets** from a "Deck" of 10+ unique scenarios. No two runs are exactly the same.
* **The Glitch:** Upon landing, an NPC blocks your path with a "System Error" (a biased statement).
* **The Choice:** You must select the correct logical counter-argument from 3 options.
* **The Result:**
    * ** Debug Success:** The NPC's eyes turn Blue. You earn a **Gold Data Shard** (+100 Pts).
    * ** Logic Failure:** The NPC remains corrupted. Nova interrupts the simulation to explain the logical fallacy. (+0 Pts).

### 2. The Scoreboard 
At the end of the patrol, you are ranked based on your debugging efficiency:
* **0-100 Pts:** *Glitch Magnet* (Try Again)
* **200 Pts:** *System Administrator*
* **300 Pts (Max):** *Galactic Legend* (Perfect Run)

---

##  The Scenario Deck
The game tackles complex social issues by framing them as "System Errors." Current scenarios include:

| Scenario | Setting | The "Glitch" (Theme) |
| :--- | :--- | :--- |
| **Engineering Bay** | Hangar | A robot claims female units cannot perform heavy repairs. (STEM Bias) |
| **The Kitchen** | Restaurant | A Chef Bot refuses to let a male unit bake. (Gender Roles) |
| **Security Gate** | Archive | A scanner rejects a Non-Binary user for not fitting "A or B". (Inclusion) |
| **Battle Arena** | Boxing Ring | A fighter bot refuses to vent steam/cry because it is "weak." (Toxic Masculinity) |
| **The Council** | Senate Hall | An Elder Bot interrupts Nova to speak to the male Cadet. (Respect/Allyship) |

---

## 🛠️ Technical Stack (For Developers)

This project is built using **Godot 4.5+** and follows a component-based architecture.

* **Engine:** Godot 4 (Compatibility Renderer / OpenGL 3)
* **Language:** GDScript
* **Key Plugins:**
    * **[Dialogue Manager](https://github.com/nathanhoad/godot_dialogue_manager):** Handles the branching narrative and state tracking.
* **Architecture Patterns:**
    * **Singleton Pattern (`GameState.gd`):** Manages global score, current planet index, and user settings across scenes.
    * **Resource-Based Loading:** Scenarios are loaded as Resources to allow for an extensible "Deck" system.

---

## 🚀 Installation & Setup

### Prerequisites
* [Godot Engine 4.x](https://godotengine.org/) (Standard Version)
* Git

### Quick Start
1.  **Clone the Repository:**
    ```bash
    git clone [https://github.com/YOUR_USERNAME/galactic-glitch-hunters.git](https://github.com/YOUR_USERNAME/galactic-glitch-hunters.git)
    ```
2.  **Import to Godot:**
    * Open Godot -> `Import`.
    * Select the `project.godot` file in the cloned folder.
    * *Note: The first import may take a moment to re-import assets.*
3.  **Run:**
    * Press `F5` to run the Main Scene.

---

## 📁 Project Structure
```text
res://
├── Assets/
│   ├── Audio/          # SFX and Background Ambience
│   ├── Sprites/        # Kenney Assets & Custom Shaders
│   └── UI/             # Themes and Fonts
├── Dialogue/           # .dialogue script files
├── Scenes/             # .tscn files (MainMenu, PlanetTemplate, EndScreen)
├── Scripts/            # .gd logic (Randomizer, ScoreManager)
└── project.godot
