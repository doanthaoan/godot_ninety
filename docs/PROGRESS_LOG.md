# 📚 Ninety Thousand Acres (Offline) - Progress Log & Lessons Learned

This document tracks our development progress, serving as a step-by-step guide and reference for the project. It highlights key files, critical code concepts, common issues we've solved, and tips for working with Godot Engine.

---

## 🗺️ Current Status
We have successfully completed **Phase 4 (Part 3 & 4)** of the World Map & Troop Movement system.
- ✅ Tile Levels & Resource Generation (Lv1-Lv5)
- ✅ Territory Border Visualization
- ✅ Troop Movement & Multi-Selection
- ✅ Building System (Sawmill, Farm, Quarry, Tower)
- ✅ Resource Economy & Passive Income
- ✅ Unified Tile Command UI

---

##  Phase 4: World Map & Troop Movement (Part 3) - Tile Levels & Command System

**Goal:** Implement tile levels, resource density, and advanced troop command UI.

### 📂 Files Created/Updated
1.  **`src/scripts/WorldMapGenerator.gd`**
    - **Update:** Added `WorldTileData` class to store type + level per tile.
    - **Level System:** Waste=1, Resources=2-5. Weighted distribution (L2 > L3 > L4 > L5).
    - **Clustering Limit:** Max 3 high-level tiles (L4-5) per 5x5 area to prevent resource hoarding.
    - **Debug Output:** Prints level distribution after generation.

2.  **`src/scripts/Tile.gd`**
    - **Update:** Integrated `resource_lv1_5.png` sprite sheet with region mapping for all levels.
    - **Building Overlay:** Added `building_overlay` Sprite2D (hidden) ready for Sawmill, Farm, Quarry, etc.

3.  **`src/scripts/TroopCommandPanel.gd`**
    - **New:** Replaces `CommandPalette.gd`. Displays target coordinates, distance, estimated time, and context-aware action button ("Attack" vs "Move").
    - **Key Concept:** **Contextual UI**. Button text and logic change based on tile ownership.

4.  **`src/scripts/TroopMovementManager.gd`**
    - **Update:** Added `get_distance_in_tiles()` and `calculate_movement_time()` for accurate ETA.
    - **Update:** Removed movement range restriction. Troops can now traverse the entire map.
    - **Update:** Added `BASE_SPEED` constant for consistent movement calculation.

5.  **`src/scripts/WorldMapInput.gd`**
    - **Update:** Removed `get_troops_in_range()` check. Now finds nearest available troop globally.
    - **Update:** Checks tile ownership to determine "Attack" (unowned) vs "Move" (owned).
    - **Update:** Passes distance and time estimate to `TroopCommandPanel`.
    - **Update:** Instantiates `TroopsMovingManagementPanel` on `_ready()` for real-time tracking.

6.  **`src/scripts/TroopsMovingManagementPanel.gd`**
    - **New:** Persistent UI panel that lists all moving troops.
    - **Features:** Displays Troop ID, Start/Destination coordinates, and live ETA countdown.
    - **Key Concept:** **Dynamic UI Management**. Automatically adds/removes rows based on troop movement state.

---

## 🔵 Phase 4: World Map & Troop Movement (Part 4) - Economy & Buildings

**Goal:** Implement resource generation, building placement, and unified command flow.

### 📂 Files Created/Updated
1.  **`src/scripts/ResourceManager.gd`**
    - **Update:** Added 1-second production loop (`_on_production_tick`).
    - **Base Production:** Simulated 4 Base tiles generating 4/sec of each resource.
    - **Tile Accumulation:** Sums up `generation` rates of all owned tiles every second.
    - **Building Integration:** Supports `update_tile_rate()` for building bonuses.

2.  **`src/scripts/BuildingStats.gd`**
    - **New:** Data class for building costs, bonuses, and tile type restrictions.

3.  **`src/scripts/BuildingManager.gd`**
    - **New:** Handles building placement, costs, and production bonuses.
    - **Restrictions:** Sawmill→Wood, Farm→Food, Quarry→Stone, Tower→Any.
    - **Remove Logic:** Supports removing buildings and resetting tile income.

4.  **`src/scripts/TileCommandPanel.gd`**
    - **New:** Unified panel for tile actions: Attack, Move, Build, Remove.
    - **Flow:** Unowned→Attack, Owned→Move+Buildings.

5.  **`src/scripts/TroopSelectPanel.gd`**
    - **New:** Panel to select multiple troops for an action.
    - **Features:** Multi-select toggle, distance/ETA display, confirm button.

6.  **`src/scripts/WorldMapInput.gd`**
    - **Update:** Integrated `TileCommandPanel` and `TroopSelectPanel`.
    - **Flow:** Click Tile→Command Panel→Select Troops→Confirm→Action.
    - **Input Handling:** Uses `_unhandled_input` to prevent click-through bugs.

### 💡 Tips & Tricks
- **Manhattan Distance:** Used `abs(dx) + abs(dy)` for grid-based distance calculation, which matches troop movement logic.
- **Contextual Actions:** The same click interaction produces different commands based on game state (ownership), reducing UI clutter.
- **Global vs Screen Coordinates:** UI panels use screen coordinates (`get_viewport().get_mouse_position()`), while game logic uses world coordinates (`camera.get_global_mouse_position()`).
- **Input Blocking:** UI panels must have solid backgrounds and `mouse_filter = STOP` to prevent clicks from passing through to the game world.

---

## 🛠️ General Development Tips

### 1. Godot Editor Features
- **Remote Scene Tree:** While the game is running, click the "Remote" tab in the Scene dock. You can inspect live nodes, see their current properties, and debug layout issues in real-time.
- **Debugger:** The "Debugger" tab at the bottom shows errors and warnings. Always check this first if something isn't working.

### 2. GDScript Best Practices
- **Type Hints:** Use `var health: int = 100` instead of `var health = 100`. It helps catch errors early.
- **Constants:** Use `const TILE_SIZE = 64` for magic numbers. If you change the tile size later, you only change it in one place.
- **Naming Conventions:**
  - Scripts: `PascalCase` (e.g., `BaseManager.gd`)
  - Variables/Functions: `snake_case` (e.g., `unit_pool`, `spawn_unit()`)
  - Constants: `UPPER_SNAKE_CASE` (e.g., `UI_HEIGHT`)

### 3. Scene Management
- **Instancing:** Use `preload("res://path/to/scene.tscn").instantiate()` to create objects dynamically.
- **Groups:** Assign nodes to groups (e.g., `groups = ["resource_manager"]`) to find them easily using `get_tree().get_first_node_in_group()`.

---

## 🚀 Next Steps
We are ready to move to **Phase 5: Tactical Combat & Base Integration**.
- Implement enemy AI and troop encounters.
- Develop combat mechanics (HP, Attack, Defense).
- Create Base-to-World Map transition logic.
- Add unit stats and battle resolution.

*Keep this document updated as we progress!*
