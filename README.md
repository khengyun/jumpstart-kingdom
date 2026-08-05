# Jumpstart Kingdom

Jumpstart Kingdom is a 2D platformer built and tested with Godot 4.7.x. The project uses a 960×540 design resolution, `canvas_items` stretch mode, and the GL Compatibility renderer for broad hardware support.

## Controls

| Action | Key |
| --- | --- |
| Move left | `A` or `←` |
| Move right | `D` or `→` |
| Jump | `Space`, `W`, or `↑` |
| Respawn | `R` |
| Pause/resume | `Esc` |

## Current Features

The starter includes a playable vertical slice rendered entirely with code:

- responsive acceleration and deceleration, coyote time, jump buffering, and variable jump height;
- a complete level with platforms, pits, spikes, a checkpoint, and a finish gate;
- collectible crystals, stompable patrol enemies, scoring, and respawning;
- a HUD, pause state, and level restart flow;
- no Nintendo assets or names.

## Project Structure

```text
.
├── project.godot          # Project settings and Input Map
├── scenes/
│   ├── main.tscn          # Entry scene and gameplay containers
│   ├── player.tscn        # Player character and camera
│   ├── coin.tscn          # Collectible crystal
│   ├── patrol_enemy.tscn  # Patrol enemy
│   └── goal.tscn          # Level finish gate
├── scripts/               # GDScript files used by the scenes
└── .vscode/               # Optional Godot Tools tasks and debug settings
```

The 2D collision layers are named `World`, `Player`, `Enemy`, and `Pickup`.

## Running the Game

1. Install a stable Godot 4.7.x release. The project is currently saved with the `4.7` feature flag.
2. Open Godot Project Manager, select **Import**, and choose `project.godot` from this directory.
3. Press `F6` to run the current scene or `F5` to run the main scene.

On a Flatpak-based installation, run the project directly with:

```bash
flatpak run org.godotengine.Godot --path .
```

Headless smoke test:

```bash
flatpak run org.godotengine.Godot --headless --path . --quit-after 180
```

The **Godot: Open Editor** and **Godot: Run Project** VS Code tasks also use the Flatpak installation. The debug launch configurations require the recommended `geequlim.godot-tools` extension.

## Continuous Delivery

The GitHub Actions workflow in `.github/workflows/godot-export.yml` validates the project, runs a headless smoke test, exports the Web build, and stores it as a workflow artifact on every push or pull request.

Publishing to itch.io is enabled for version tags such as `v1.0.0`, or by manually running the workflow with the **deploy** input enabled. The repository must define:

- an Actions secret named `BUTLER_API_KEY`;
- an Actions variable named `ITCH_USER` containing the itch.io username;
- an Actions variable named `ITCH_GAME` containing the itch.io project slug;
- an existing itch.io HTML game page matching those values.

The deployment job uses the protected `itch-production` GitHub environment and uploads the directory containing `index.html` to the `web` Butler channel.

All future artwork, audio, characters, and names should be original or used under an appropriate license.
