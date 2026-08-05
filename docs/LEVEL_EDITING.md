# Editing and adding levels

Jumpstart Kingdom levels are regular Godot scenes. The current map is no longer
built in code.

## Edit Level 1

1. Open `scenes/levels/level_01.tscn` in Godot.
2. In `EditorGuides`, select `LevelBounds` and press `F` to frame the whole map.
3. Expand `Terrain` and select a platform.
4. Drag the platform to move it. Use the native rectangle handles to resize it.
5. Move coins, enemies, spikes, the checkpoint, and the goal directly in the
   2D viewport.
6. Move `Markers/PlayerSpawn` to change where the player begins.

Platforms and spike strips are reusable scene components. Their visuals and
collision rectangles update together in the editor. Resize their rectangle;
do not change their Node scale.

Useful Inspector settings:

- Platform `Grass Top`: show or hide the grass edge.
- Enemy `Patrol Distance`: change how far an enemy walks from its placed point.
- Flying enemy `Hover Amplitude` and `Hover Frequency`: shape its flight path.
- Coin `Value`: change its score value.
- Level `Level Title`: name displayed in the HUD and win menu.
- Level `Level Bounds`: camera limits for that level.
- Level `Background Texture`: background used while that level is active.

## Add another level

1. Open the closest existing scene under `scenes/levels/`.
2. Choose **Scene → Save As** and save a new file such as
   `scenes/levels/level_03.tscn`.
3. Rename the root, change `Level Title`, `Level Bounds`, and the background,
   then edit the map.
4. Keep the file directly inside `scenes/levels/` and keep its name beginning
   with `level_`.
5. Save and run. No array or `main.tscn` change is required.

Open **DEV MODE** from the main menu to jump directly to any discovered map.
The selector is generated at runtime from the same `LevelCatalog`, so a valid
new `level_*.tscn` file appears there automatically without another code edit.

`LevelCatalog` discovers these files with `ResourceLoader`, including inside a
Web export, and plays them in natural filename order. For example,
`level_02.tscn` comes before `level_10.tscn`. Reaching a goal automatically
runs the stage transition and loads the next discovered map. Only the final
level opens the completion menu.

To add the reusable aerial enemy, drag `scenes/flying_enemy.tscn` beneath the
level's `Enemies` node. The flight range and hover guide are visible in the 2D
editor but hidden at runtime.

## Scene responsibilities

- `Main`: title/settings/about/pause/final menus and animated transitions.
- `LevelCatalog`: export-safe discovery and natural ordering of level scenes.
- `GameSession`: score, coins, three lives, checkpoints, respawning, and progression.
- `level_XX.tscn`: all editor-authored terrain and gameplay object positions.
- `scenes/components`: reusable resizable platforms, spike strips, kill zones,
  and checkpoints.

Keep each level root on `scripts/level.gd` and retain its `Terrain`, `Pickups`,
`Enemies`, `GameplayAreas`, and `Markers/PlayerSpawn` branches so the session
can connect gameplay signals automatically.
