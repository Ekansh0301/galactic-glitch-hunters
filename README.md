# 🚀 Galactic Glitch Hunters

> **A Narrative Logic-Puzzler about debugging bias in the galaxy.**
> *Built with Godot 4 for the [Your University/Class Name] Project.*

![Project Status](https://img.shields.io/badge/Status-In%20Development-yellow)
![Engine](https://img.shields.io/badge/Godot-4.x-blue?logo=godotengine)
![License](https://img.shields.io/badge/License-MIT-green)

## 📖 About The Project

**Galactic Glitch Hunters** is a 2D sci-fi narrative game designed for ages 8-12. The player takes on the role of a Cadet in the "Galactic Harmony Corps," tasked with fixing robots infected by "The Bias"—an ancient virus that corrupts logic and creates unfair stereotypes.

Unlike traditional educational games, we treat social bias as a **"System Error."** Players must use logic, empathy, and debugging skills to patch the glitched robots and save the galaxy.

### 🎯 Core Objectives
* **Gamify Empathy:** Framing "Toxic Masculinity" and "Exclusion" as inefficient code that causes system overheating.
* **Logic Detective Gameplay:** No combat. Players win by choosing the correct logical response to dismantle biased arguments.
* **Inclusion:** Features scenarios addressing gender roles, non-binary identity, and workplace respect.

---

## 🎮 Key Features

* **randomized Mission Deck:** Every run selects 3 random planets from a pool of 10 unique scenarios, ensuring high replayability.
* **The "Logic Battle" System:** A dialogue-driven mechanic where players must identify the logical fallacy in a robot's argument to "debug" them.
* **Dynamic Visuals:** Robots visibly transform from "Glitched" (Red/Static) to "Fixed" (Blue/Clean) based on player choices.
* **Real-time Feedback:** Your AI co-pilot, **Nova**, provides instant context and educational feedback if a player makes a toxic choice.

---

## 🛠️ Built With

* **Engine:** [Godot 4.x](https://godotengine.org/) (Compatibility Mode / OpenGL 3)
* **Language:** GDScript
* **Plugins:**
    * [Dialogue Manager](https://github.com/nathanhoad/godot_dialogue_manager) by Nathan Hoad (for complex narrative branching).

---

## 🚀 Getting Started

To play the game or contribute to the code, follow these steps.

### Prerequisites
* Download **Godot Engine 4.x** (Standard Version).

### Installation
1.  **Clone the repo:**
    ```bash
    git clone [https://github.com/YOUR_USERNAME/galactic-glitch-hunters.git](https://github.com/YOUR_USERNAME/galactic-glitch-hunters.git)
    ```
2.  **Import into Godot:**
    * Open Godot Engine.
    * Click **Import**.
    * Navigate to the cloned folder and select the `project.godot` file.
3.  **Run the Project:**
    * Press the **Play** button (F5) in the top right corner.

---

## 📂 Project Structure

For developers looking at the code, here is how we organized the project:

```text
res://
├── Assets/             # Sprites, Audio, and Fonts
│   ├── Kenney/         # Third-party assets
│   └── UI/
├── Dialogue/           # .dialogue scripts (The narrative logic)
├── Scenes/             # .tscn files (Levels, Menus, UI)
├── Scripts/            # .gd files (Global Logic, GameState)
└── project.godot       # Main configuration
