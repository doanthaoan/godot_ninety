# Troop Movement Test Instructions

## How to Test:
1. Open the project in Godot Editor (Double-click project.godot or open via Godot's Project Manager).
2. Ensure the main scene is set to WorldMap.tscn (should already be set in project.godot).
3. Press F5 to run the game.
4. You should see a green map with colored squares representing resources (brown=wood, gray=stone, yellow=food).
5. Press the **Space Bar** to spawn a troop at the origin (0,0) that will move towards a random tile.
6. Watch the orange square (troop) move across the map.
7. When the troop arrives, it will print "Tile captured at: (x,y)" in the output.

## Controls:
- **WASD / Arrow Keys**: Move the camera
- **+ / - or Numpad Add/Sub**: Zoom in/out
- **Space Bar**: Spawn a test troop
- **Left Click**: (Future) Will send a troop to the clicked tile (currently just prints)

## Next Steps:
Once you verify the troop movement works, we will:
1. Replace the colored placeholders with your actual 64x64 resource sprites.
2. Implement the Base Construction UI (bottom/left panel).
3. Implement the Troop creation UI (spending resources to create units and form troops).
4. Add combat when troops encounter enemies or other players.
5. Implement the win condition (capture 5 tiles).

Enjoy building your game!