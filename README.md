<p align="center">
  <img src="marketing/itch/jumpstart-kingdom-banner.png" alt="Jumpstart Kingdom banner" width="960">
</p>

<h1 align="center">Jumpstart Kingdom</h1>

<p align="center">
  A cheerful browser platformer about quick jumps, golden collectibles, and tiny purple troublemakers.
</p>

<p align="center">
  <a href="https://khengyun.itch.io/jumpstart-kingdom"><strong>Play in your browser</strong></a>
  ·
  <a href="https://khengyun.itch.io/">More games by Ken</a>
</p>

<p align="center">
  <a href="https://github.com/khengyun/jumpstart-kingdom/actions/workflows/godot-export.yml">
    <img src="https://github.com/khengyun/jumpstart-kingdom/actions/workflows/godot-export.yml/badge.svg?branch=main" alt="Build and Deploy Web status">
  </a>
</p>

## About

Jumpstart Kingdom is a compact 2D platformer built with Godot 4.7. Run across grassy platforms, collect golden pickups, avoid spikes, stomp patrol enemies, activate the checkpoint, and reach the goal.

The game is designed at 960×540, uses the GL Compatibility renderer, and can be played directly in a modern desktop browser.

## Features

- Responsive movement with separate ground and air acceleration.
- Coyote time, jump buffering, and variable-height jumping.
- Collectibles, scoring, hazards, pits, and player respawning.
- Stompable patrol enemies and a mid-level checkpoint.
- Pause, restart, death counter, and level-complete flow.
- Five-state robot animation: idle, run, jump, fall, and shutdown.
- Original pixel-art background, terrain, animated pickups, and animated enemies.
- Code-drawn hazards, checkpoint, and goal visuals layered over stable physics shapes.
- Automated Web builds and itch.io deployment through GitHub Actions.

## Controls

| Action | Keyboard |
| --- | --- |
| Move left | `A` or `←` |
| Move right | `D` or `→` |
| Jump | `Space`, `W`, or `↑` |
| Respawn / restart | `R` |
| Pause / resume | `Esc` |

## Run Locally

### Requirements

- Godot 4.7.x. The CI build currently uses Godot 4.7.1.
- Git, if you want to clone the repository.

Clone and open the project:

```bash
git clone https://github.com/khengyun/jumpstart-kingdom.git
cd jumpstart-kingdom
godot --editor --path .
```

Press `F5` in the editor, or launch the game directly:

```bash
godot --path .
```

For a Flatpak installation of Godot:

```bash
flatpak run --filesystem="$PWD" org.godotengine.Godot --editor --path .
flatpak run --filesystem="$PWD" org.godotengine.Godot --path .
```

Run the same headless checks used during development:

```bash
godot --headless --editor --path . --quit
godot --headless --path . --quit-after 180
```

## Project Structure

```text
.
├── assets/branding/      # Project icon used by exported builds
├── assets/environment/   # Background plate and repeatable terrain textures
├── assets/enemies/       # Purple drone sprite sheet and animation resource
├── assets/pickups/       # Circuit coin sprite sheet and animation resource
├── assets/player/        # Robot sprite sheet and animation resource
├── marketing/itch/       # Storefront artwork; excluded from game exports
├── scenes/               # Main, player, collectible, enemy, and goal scenes
├── scripts/              # Gameplay, movement, UI, and scene construction
├── .github/workflows/    # Web build and itch.io deployment pipeline
├── .vscode/              # Optional Flatpak tasks and Godot debug settings
├── export_presets.cfg    # Godot Web export preset
└── project.godot         # Project settings, input map, and entry scene
```

The collision layers are named `World`, `Player`, `Enemy`, and `Pickup`. Storefront artwork lives under `marketing/` and is kept out of Godot imports and release bundles by `marketing/.gdignore`.

The included VS Code tasks open or run the project through Flatpak. Debug launch configurations use the recommended `geequlim.godot-tools` extension.

## Web Export

Install the matching Godot export templates, then run:

```bash
mkdir -p build/web
godot --headless --path . --export-release Web build/web/index.html
```

The exported directory must keep `index.html`, the `.wasm` file, the `.pck` file, and the remaining generated files together.

## Continuous Delivery

The [`Build and Deploy Web`](.github/workflows/godot-export.yml) workflow runs for pushes to `main`, `v*` tag pushes, pull requests targeting `main`, and manual dispatches. It:

1. imports and validates the Godot project;
2. runs a headless smoke test;
3. exports and verifies the Web bundle;
4. stores the bundle as a GitHub Actions artifact for 14 days;
5. deploys the bundle to the itch.io `web` channel for `v*` tags or a manual run with **deploy** enabled.

Production deployment requires the repository secret `BUTLER_API_KEY`, the repository variable `ITCH_GAME`, and an existing itch.io HTML project matching that slug. The workflow validates the target page before uploading with Butler. After the first upload, mark the `web` upload as **HTML5 / Playable in browser** in the itch.io editor.

## Credits

Created by [Ken](https://khengyun.itch.io/) with [Godot Engine](https://godotengine.org/). Gameplay code and runtime artwork are original to this project.

This independent project is not affiliated with Nintendo and contains no Nintendo characters, names, or assets.
