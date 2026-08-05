# Runtime artwork prompts

The following bitmap assets were generated with Codex's built-in `imagegen`
tool in reference-image mode. The generated sources were chroma-keyed locally,
then resized with nearest-neighbour sampling before being added to the project.

## Proximity mine

Final asset: `assets/hazards/proximity-mine-sprites.png`

```text
Use case: stylized-concept
Asset type: production-ready animated hazard sprite sheet for a colorful 2D pixel-art robot platformer
Input images: Image 1 and Image 2 are STYLE, PIXEL SCALE, OUTLINE, AND COLOR-PALETTE REFERENCES ONLY; Image 3 is a simple hazard readability reference only. Do not reproduce any character, enemy, spike, pose, or existing sprite.
Primary request: create exactly ONE 4-column by 4-row sprite sheet containing 16 equal square animation cells for a compact mechanical proximity mine. The mine is a squat circular floor device with a dark navy metal body, cyan/teal armored casing, small orange feet, and a bright orange warning core.
Animation plan: row 1 has four idle-loop frames with a subtle core blink and tiny antenna movement; row 2 has four armed-warning frames with the orange core flashing brighter and the casing/fins opening; row 3 has four explosion frames progressing clearly from ignition spark to expanding orange-yellow blast at maximum size; row 4 has four aftermath frames progressing from broken casing and energetic sparks to a small clean final spark. Every row reads left to right.
Style/medium: crisp handcrafted pixel art, chunky deliberate pixels, limited palette, high contrast, one-pixel dark outlines, cheerful cyan/orange robot-world styling consistent with the references, no painterly anti-aliasing.
Composition/framing: exact regular 4x4 grid; all 16 cell centers perfectly aligned; equal cell sizes and equal padding; mine footprint consistent in idle and warning frames; explosion stays centered and fits fully inside each cell; no grid lines.
Scene/backdrop: perfectly flat solid #ff00ff chroma-key background for local background removal.
Constraints: exactly 16 frames in a 4x4 grid and no additional sprites; no full robot, character, enemy, coin, spike, platform, text, letters, numbers, symbols, UI panel, border, frame labels, cast shadow, contact shadow, reflection, watermark, or scenery. Background must be one uniform #ff00ff with no gradient, texture, lighting variation, or shadow. Do not use #ff00ff anywhere inside the sprites. Make all smoke and sparks hard-edged opaque pixel clusters rather than translucent effects so chroma removal stays clean.
```

## Sentry shooter

Final asset: `assets/enemies/sentry-shooter-sprites.png`

```text
Use case: stylized-concept
Asset type: production-ready animated ground enemy sprite sheet for a colorful 2D pixel-art robot platformer
Input images: Image 1, Image 2, and Image 3 are STYLE, PIXEL SCALE, OUTLINE, ANIMATION-GRID, AND COLOR-PALETTE REFERENCES ONLY. Do not reproduce any existing character, drone, pose, or sprite.
Primary request: create exactly ONE 4-column by 4-row sprite sheet containing 16 equal square animation cells for a new stationary shooter enemy. It is a compact squat sentry robot with a rounded violet/purple armored body, dark navy joints, a cyan face display with hostile eyes, orange warning lights, two short mechanical feet, and one clearly readable side-mounted orange energy cannon. The body must remain stompable from above.
Animation plan: row 1 has four idle-loop frames with subtle antenna and face movement; row 2 has four aiming/charging frames where the robot turns its cannon horizontally and the cannon core grows brighter; row 3 has four firing/recoil frames with a small cyan-orange muzzle flash that remains fully inside the cell; row 4 has four stomp-defeat frames progressing from impact squash to a flattened powered-off robot. Every row reads left to right.
Style/medium: crisp handcrafted pixel art, chunky deliberate pixels, limited palette, high contrast, one-pixel dark outlines, cheerful but dangerous robot-world styling consistent with the references, no painterly anti-aliasing.
Composition/framing: exact regular 4x4 grid; all 16 cell centers and ground baselines perfectly aligned; equal cell sizes and equal padding; consistent character identity, proportions, cannon side, and scale in every frame; no grid lines.
Scene/backdrop: perfectly flat solid #ff00ff chroma-key background for local background removal.
Constraints: exactly 16 frames in a 4x4 grid and no additional sprites; one enemy per cell; side-facing gameplay view; no player character, existing enemy, projectile traveling away from the muzzle, platform, coin, spike, mine, text, letters, numbers, symbols, UI, border, frame labels, cast shadow, contact shadow, reflection, watermark, or scenery. Background must be one uniform #ff00ff with no gradient, texture, lighting variation, or shadow. Do not use #ff00ff anywhere inside the sprites.
```

## Sentry bolt

Final asset: `assets/enemies/sentry-bolt-sprites.png`

```text
Use case: stylized-concept
Asset type: production-ready animated enemy projectile sprite sheet for a colorful 2D pixel-art robot platformer
Input images: Image 1 and Image 2 are STYLE, PIXEL SCALE, OUTLINE, AND COLOR-PALETTE REFERENCES ONLY. Do not reproduce either enemy.
Primary request: create exactly ONE 2-column by 2-row sprite sheet containing four equal square animation cells for a small horizontal energy projectile fired by a robot cannon. Each cell contains the same compact right-facing cyan plasma bolt with a bright pale-cyan core, dark navy outline, tiny orange energy accents, and a short hard-edged pixel trail. The four frames form a seamless pulse loop: compact, slightly expanded, bright peak, returning compact.
Style/medium: crisp handcrafted pixel art, chunky deliberate pixels, limited cyan/navy/orange palette, high contrast, one-pixel dark outline, no painterly anti-aliasing.
Composition/framing: exact regular 2x2 grid; all four projectile centers perfectly aligned; equal cell sizes and equal padding; projectile scale and right-facing direction consistent; each bolt fills roughly half the cell width; no grid lines.
Scene/backdrop: perfectly flat solid #ff00ff chroma-key background for local background removal.
Constraints: exactly four cells and no additional sprites; one projectile per cell; no cannon, robot, character, enemy, platform, explosion, text, letters, numbers, symbols, UI, border, frame labels, shadow, reflection, watermark, or scenery. Background must be one uniform #ff00ff with no gradient, texture, lighting variation, or shadow. Do not use #ff00ff inside the projectile.
```

## Radial Core boss

Final asset: `assets/enemies/radial-core-boss-sprites.png`

```text
Use case: stylized-concept
Asset type: production-ready animated final boss sprite sheet for a colorful 2D pixel-art robot platformer
Input images: Image 1, Image 2, and Image 3 are STYLE, PIXEL SCALE, OUTLINE, ANIMATION-GRID, AND COLOR-PALETTE REFERENCES ONLY. Do not reproduce any existing character, enemy, pose, or sprite.
Primary request: create exactly ONE 4-column by 4-row sprite sheet containing 16 equal square animation cells for a large final boss called the Radial Core Guardian. It is a wide hovering mechanical orb roughly twice the size of a normal enemy, with a dark navy armored body, cyan/teal plates, violet secondary armor, a bright orange central reactor eye, small crown-like antenna, and eight evenly spaced orange energy emitters around its circular silhouette. The top surface must be broad and visually safe/readable for the player to stomp.
Animation plan: row 1 has four idle-hover frames with subtle reactor pulse and plate movement; row 2 has four radial-attack frames progressing from emitter charge to a bright circular firing pulse around all eight emitters; row 3 has four hurt frames with the orb squashed downward, reactor flickering, and visible hit sparks; row 4 has four defeat frames progressing from cracked armor and power failure to a collapsed dark powered-off core. Every row reads left to right.
Style/medium: crisp handcrafted pixel art, chunky deliberate pixels, limited cyan/navy/violet/orange palette, high contrast, one-pixel dark outlines, cheerful but imposing robot-world boss styling consistent with the references, no painterly anti-aliasing.
Composition/framing: exact regular 4x4 grid; all 16 cell centers and baselines perfectly aligned; equal cell sizes and equal padding; consistent boss identity, proportions, size, emitter count, and facing in every frame; boss centered front/side-neutral for a 2D side-view arena; no grid lines.
Scene/backdrop: perfectly flat solid #ff00ff chroma-key background for local background removal.
Constraints: exactly 16 frames in a 4x4 grid and no additional sprites; one boss per cell; no player, normal enemy, detached projectile, bullet pattern, platform, coin, spike, mine, text, letters, numbers, symbols, UI, border, labels, cast shadow, contact shadow, reflection, watermark, or scenery. Background must be one uniform #ff00ff with no gradient, texture, lighting variation, or shadow. Do not use #ff00ff anywhere inside the boss.
```

## Fire shockwave

Final asset: `assets/hazards/explosion-shockwave-sprites.png`

```text
Use case: stylized-concept
Asset type: production-ready one-shot fiery shockwave sprite sheet for a colorful 2D pixel-art robot platformer
Input images: Image 1 and Image 2 are STYLE, PIXEL SCALE, OUTLINE, FIRE-COLOR, AND ANIMATION-GRID REFERENCES ONLY. Do not reproduce the mine, boss, robot, or any existing sprite.
Primary request: create exactly ONE 4-column by 4-row sprite sheet containing 16 equal square animation cells for a circular explosion shockwave viewed straight-on in a side-view game. Across all 16 frames, read left-to-right and top-to-bottom: begin with a tiny bright ignition ring, expand into a clearly hollow orange-yellow circle of fire, reach a wide maximum-radius ring with a thin bright inner rim and chunky outward flame tongues, then fade into sparse hard-edged embers. The circular hollow center and expanding outer radius must be extremely readable. This is the visual damage radius around an exploding enemy or mine.
Style/medium: crisp handcrafted pixel art, chunky deliberate pixels, limited pale-yellow/orange/deep-orange/navy palette, high contrast, one-pixel dark-orange outline, no painterly anti-aliasing, no soft transparency.
Composition/framing: exact regular 4x4 grid; all 16 ring centers perfectly aligned; equal cell sizes and equal padding; each successive frame grows smoothly; maximum ring nearly fills its cell but never clips; no grid lines.
Scene/backdrop: perfectly flat solid #ff00ff chroma-key background, including the hollow center of every ring, for local background removal.
Constraints: exactly 16 frames in a 4x4 grid and no additional sprites; shockwave ring only; no mine, robot, enemy, projectile, smoke cloud, platform, scenery, text, letters, numbers, symbols, UI, border, labels, cast shadow, reflection, or watermark. Background and ring centers must be one uniform #ff00ff with no gradient, texture, lighting variation, or shadow. Do not use #ff00ff anywhere inside fire or embers. All fire and embers must be hard-edged fully opaque pixel clusters so chroma removal stays clean.
```

## Hover lift

Final asset: `assets/environment/hover-lift-sprites.png`

```text
Use case: stylized-concept
Asset type: production-ready animated horizontal hover-lift platform sprite sheet for a colorful 2D pixel-art robot platformer
Input images: Image 1, Image 2, and Image 3 are STYLE, PIXEL SCALE, OUTLINE, MATERIAL, AND COLOR-PALETTE REFERENCES ONLY. Do not reproduce any character, enemy, grass block, pose, or existing sprite.
Primary request: create exactly ONE 4-column by 4-row sprite sheet containing 16 equal square animation cells for a reusable mechanical lift platform. The platform is a wide sturdy cyan/teal metal deck with a dark navy frame, warm orange edge lights, a flat clearly walkable top, and two compact rocket nozzles mounted beneath it.
Directional animation plan: row 1 has four seamless moving-right frames; the platform remains level while both underside rocket flames visibly angle down-and-left, opposite the rightward travel, with lively flame flicker. Row 2 has four seamless moving-left frames; the same platform remains level while both underside rocket flames visibly angle down-and-right, opposite the leftward travel. Row 3 has four right-to-left turnaround frames where the flames swing smoothly from left through straight down to right. Row 4 has four left-to-right turnaround frames where the flames swing smoothly from right through straight down to left. Every row reads left to right.
Style/medium: crisp handcrafted pixel art, chunky deliberate pixels, limited cyan/teal/navy/orange/pale-yellow palette, high contrast, one-pixel dark outlines, cheerful robot-world styling consistent with the references, no painterly anti-aliasing.
Composition/framing: exact regular 4x4 grid; all 16 platform deck tops, centers, widths, and scale perfectly aligned; equal cell sizes and equal padding; platform fills about 88 percent of each cell width; all flames fit fully inside the cell; no grid lines. The top of the deck must stay horizontally identical across frames so a player can stand on it without visual jitter.
Scene/backdrop: perfectly flat solid #ff00ff chroma-key background for local background removal.
Constraints: exactly 16 frames in a 4x4 grid and no additional sprites; one platform per cell; same platform identity and proportions in every frame; no character, robot, enemy, coin, spike, mine, terrain block, grass, text, arrows, letters, numbers, symbols, UI, border, labels, cast shadow, contact shadow, smoke, reflection, watermark, or scenery. Background must be one uniform #ff00ff with no gradient, texture, lighting variation, or shadow. Do not use #ff00ff anywhere inside the platform or flames. All flames must be hard-edged fully opaque pixel clusters with a pale-yellow core, orange body, and deep-orange outline.
```
