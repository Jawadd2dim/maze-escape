# Maze Escape
*A Top-Down 2D Maze Survival Game*  

## Table of Contents  
1. [Description] 
2. [Installation]
3. [Controls] 
4. [NPC Interaction System]
5. [Save/Load System] 
6. [Credits]
7. [License]

## Description  
**Maze Escape** is a challenging top-down 2D maze game where you navigate through 5 perilous levels while avoiding relentless AI enemies. With no combat abilities, survival hinges on your speed, strategy, and cooperation with a mysterious friendly NPC. Built using **Godot 4**, this project demonstrates advanced AI systems, dynamic NPC interactions, and scalable difficulty.  

### Gameplay  
- **5 Increasingly Difficult Levels**: Mazes grow larger, and enemies become faster and deadlier.  
- **Enemy AI**:  
  - **Finite State Machine (FSM)**: Enemies switch between *Idle*, *Patrol*, *Chase*, and *Attack* states.  
  - **A* Pathfinding**: Enemies dynamically calculate optimal paths around obstacles to hunt the player.  
- **Friendly NPC**:  
  - **Memory System**: Remembers past interactions (e.g., "We meet again!").  
  - **Healing & Buffs**: Restores health or grants temporary speed boosts based on player needs.  
- **Save/Load System**: Save your progress, NPC dialogue history, and custom keybindings.  
- **Customizable Controls**: Rebind keys in the settings menu.  

### Technical Implementation  
- **Godot 4**: Utilizes `Navigation2D`, `AStar2D`, and signals for AI behavior.  
- **State Management**: Tracks NPC interactions using boolean flags and counters.  


## Installation  
### Option 1: Godot Editor  
1. **Clone the Repository**:  
   ```bash  
   git clone https://github.com/Jawadd2dim/maze-escape.git
2. Open the project in Godot 4.0+.
3. Run MainMenu.tscn or Press F6 to start the game.

Option 2: Pre-Built Executables
Download the latest release
** Release **


Controls
Action                	Default Key
Move                      	WASD
Interact  (NPC)             	E
Pause Menu	                 ESC
Save Game	                    F5
Load Game                   	F9
Customize keys in the Settings Menu.


NPC Interaction System
The NPC uses a decision tree to respond to the player:

1.First Interaction:
    *Introduces itself: "I am Alden, the Keeper of the Labyrinth. Stay vigilant!"
    *Grants a tutorial hint.
2.Subsequent Interactions:
    *Short greetings: "Hello again, wanderer."
    *Context-aware actions:
        *Heals player if health < 50%.
        *Grants a 10-second speed boost if enemies are nearby.
3.Memory: Tracks interactions using has_met_player and interaction_count variables.


##Save/Load System
Saved Data:
Current level and player position.
NPC interaction history.
Custom keybindings.
File Location:
Saved to user://savegame.json (Godot’s user data directory).
How to Reset: Delete savegame.json or use the "New Game" option.




##Credits
Code & Systems
*A Pathfinding**: Adapted from Patel, A. (2005). A Pathfinding for Beginners.
FSM Architecture: Inspired by Millington, I. (2019). Artificial Intelligence for Games.
Godot Tutorials: KidsCanCode, GDQuest.

Assets
Art: Kenney.nl (CC0 1.0 Universal).
Fonts: Google Fonts (Open Font License).






Created by Muhammad Jawad Ahmed as part of an Undergraduate Project.
