# Project: Ninety Thousand Acres (Offline)
## Game Concept
A pixel-art construction and strategic game with grid-based base management and tactical combat inspired by Final Fantasy Tactics/Tearing Saga.

## Version 1: The Foundation - Specifications
### 1. Economy
- Resources: Wood, Stone, Food.
- Starting Balance: 1000 each.
- Cost Logic:
    - Buildings: Wood + Stone.
    - Units: Food.
- Passive Income: Based on occupied World Map tiles. Waste tiles provide minimum of all resources.

### 2. Base Construction
- Main Tower: Central core.
- Barracks: Produces Blade-Shield Units (30s training time).

### 3. World Map (100x100)
- Randomly generated tiles: Wood, Stone, Food, Waste.
- Moving Speed: Determines travel distance per second.
- Goal: Occupy 5 tiles.

### 4. Combat Engine
- Action Speed: Determines turn order.
- Movement: Tactical grid movement toward the nearest enemy.
- Attack: Range-based melee/ranged attacks.
- Damage: (Min-Max Attack) - Defense.

---
## Development Roadmap
- [ ] Phase 1: Project Setup & Data Layer (ResourceManager, UnitStats)
- [ ] Phase 2: Base UI & Training Logic
- [ ] Phase 3: World Map Generation & Troop Movement
- [ ] Phase 4: Tactical Combat Loop & A* Pathfinding
- [ ] Phase 5: Win/Loss Conditions (5 Tile Capture)
