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
- Coin `Value`: change its score value.
- Level `Level Title`: name displayed in the HUD and win menu.
- Level `Level Bounds`: camera limits for that level.
- Level `Background Texture`: background used while that level is active.

## Add Level 2 or later

1. Open `scenes/levels/level_01.tscn`.
2. Choose **Scene → Save As** and save a new file such as
   `scenes/levels/level_02.tscn`.
3. Rename the root to `Level02`, change `Level Title`, then edit the map.
4. Open `scenes/main.tscn` and select the `Main` root.
5. In the Inspector, expand the exported `Levels` array, add an element, and
   drag `level_02.tscn` into the new slot.

The order of the `Levels` array is the play order. The win menu automatically
shows **Next Level** when another scene exists, and **Play Again** after the
last level.

## Scene responsibilities

- `Main`: title/settings/about/pause/win navigation and the ordered level list.
- `GameSession`: score, coins, deaths, checkpoints, respawning, and progression.
- `level_XX.tscn`: all editor-authored terrain and gameplay object positions.
- `scenes/components`: reusable resizable platforms, spike strips, kill zones,
  and checkpoints.

Keep each level root on `scripts/level.gd` and retain its `Terrain`, `Pickups`,
`Enemies`, `GameplayAreas`, and `Markers/PlayerSpawn` branches so the session
can connect gameplay signals automatically.
