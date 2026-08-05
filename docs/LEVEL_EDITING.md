# Editing and adding levels

Jumpstart Kingdom levels are regular Godot scenes. The current map is no longer
built in code.

## Edit Level 1

1. Open `scenes/levels/level_01.tscn` in Godot.
2. In `EditorGuides`, select `LevelBounds` and press `F` to frame the whole map.
3. Expand `Terrain` and select a platform.
4. Drag the platform to move it. Use the native rectangle handles to resize it.
5. Move coins, enemies, spikes, mines, moving platforms, checkpoints, and the
   goal directly in the 2D viewport.
6. Move `Markers/PlayerSpawn` to change where the player begins.

Platforms and spike strips are reusable scene components. Their visuals and
collision rectangles update together in the editor. Resize their rectangle;
do not change their Node scale.

Useful Inspector settings:

- Platform `Grass Top`: show or hide the grass edge.
- Enemy `Patrol Distance`: change how far an enemy walks from its placed point.
- Flying enemy `Hover Amplitude` and `Hover Frequency`: shape its flight path.
- Moving platform `Travel Distance`, `Speed`, and `Initial Direction`: edit its
  horizontal route. The cyan editor guide shows the complete path. Its lift
  stays level and changes exhaust direction immediately when it reverses.
- Explosive hazard `Trigger Radius`, `Blast Radius`, and timing values: tune
  when the mine arms and how far its visible fire ring can kill the player.
- Shooter enemy `Detection Range`, `Vertical Fire Tolerance`, and
  `Fire Interval`: tune its detection lane. The default interval is two
  seconds, the cyan editor rectangle shows the lane, and each projectile aims
  at the player's current position when fired rather than staying horizontal.
- Radial boss health and volley settings: tune stomp hits, projectile count,
  safe wedges, rotation, interval, speed, lifetime, activation radius, and
  visible hover amplitude. Place it above the arena floor and provide ledges
  from which its stompable top remains reachable.
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

Other reusable gameplay modules:

- Drag `scenes/components/moving_platform.tscn` beneath `Terrain` for moving
  ground. Its placed position is the center of its editor-visible route. For a
  mandatory crossing, make the pit wider than the player's double-jump range,
  remove fixed-platform bypasses, and set the lift endpoints close enough to
  both banks for a short boarding jump.
- Drag `scenes/components/explosive_hazard.tscn` beneath `GameplayAreas` for a
  one-shot proximity mine. Its editor rings show trigger and lethal radius;
  the runtime fire shockwave matches the lethal radius.
- Drag `scenes/shooter_enemy.tscn` beneath `Enemies` for a stationary sentry.
  Place solid terrain or cover between firing lanes so a checkpoint never
  respawns the player into an unavoidable projectile.
- Drag `scenes/radial_boss.tscn` beneath `Enemies` for the final radial boss.
  Set the corresponding goal's `Required Group` Inspector property to
  `level_boss` so the goal remains locked until the boss is defeated.

Keep checkpoints clear of mines, spikes, enemy detection areas, and shooter
lanes. A checkpoint's respawn marker is at its placed position plus its scene's
configured spawn offset, so test the actual respawn rather than only the flag
base.

## Scene responsibilities

- `Main`: title/settings/about/pause/final menus and animated transitions.
- `LevelCatalog`: export-safe discovery and natural ordering of level scenes.
- `GameSession`: score, coins, three lives, checkpoints, respawning, and progression.
- `level_XX.tscn`: all editor-authored terrain and gameplay object positions.
- `scenes/components`: reusable fixed and moving platforms, spike strips,
  explosive hazards, kill zones, and checkpoints.

Keep each level root on `scripts/level.gd` and retain its `Terrain`, `Pickups`,
`Enemies`, `GameplayAreas`, and `Markers/PlayerSpawn` branches so the session
can connect gameplay signals automatically.
