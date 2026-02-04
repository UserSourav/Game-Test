# Temple Sprint (Godot 4)

Temple Sprint is a text-only, pixel-inspired endless runner prototype built in Godot 4. The visuals are made with `ColorRect` nodes and the soundtrack is generated procedurally, so the repository remains free of binary assets.

## How to Run
1. Open the project folder in Godot 4.2+.
2. Press **Play** to run `scenes/Main.tscn`.

## Controls
- **A / Left Arrow**: Move left
- **D / Right Arrow**: Move right
- **R / Enter**: Restart after game over

## Project Layout
- `project.godot`: Godot project configuration and input mappings.
- `scenes/`: Main scene plus obstacle/coin scenes.
- `scripts/`: Gameplay and player movement logic.

## Notes
- All visuals are generated with `ColorRect` nodes to keep assets text-only.
- Music is synthesized at runtime via `AudioStreamGenerator`.
