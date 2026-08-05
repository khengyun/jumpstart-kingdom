# Sound effects

The 16 WAV files in `sfx/` are game-specific adaptations of sound effects
published on Pixabay and collected on 2026-08-06. The original MP3 files are
not stored in this repository.

Each output is cut to its gameplay timing, converted to mono 44.1 kHz 16-bit
PCM, and altered with combinations of EQ, pitch shifting, reversal, fades,
layering, and limiting. The complete, reproducible recipe is in
[`build_pixabay_sfx.sh`](build_pixabay_sfx.sh).

## Source recordings

All source pages state that the recording is free for use under the
[Pixabay Content License](https://pixabay.com/service/license-summary/).
Attribution is not required by that license, but contributor credits and exact
download records are retained here.

### Robot moving, driving, takeoff, motor sound - 12 different SEs

- Contributor: ShidenBeatsMusic
- Source page: <https://pixabay.com/sound-effects/film-special-effects-robot-moving-driving-takeoff-motor-sound-12-different-ses-109030/>
- Download: <https://cdn.pixabay.com/download/audio/2022/04/06/audio_c6e87c6ce0.mp3?filename=shidenbeatsmusic-robot-moving-driving-takeoff-motor-sound-12-different-ses-109030.mp3>
- SHA-256: `ba4355a12739e3ee495ef8d55413e8cbb965f32923bf4030603fcbc9bff171af`

### large mech robot steps

- Contributor: BannytheCoolio
- Source page: <https://pixabay.com/sound-effects/film-special-effects-large-mech-robot-steps-432560/>
- Download: <https://cdn.pixabay.com/download/audio/2025/11/07/audio_9ce2f3127d.mp3?filename=bannythecoolio-large-mech-robot-steps-432560.mp3>
- SHA-256: `d5dc01543c919ef0a022ff3fd73bd315f501919fee6069ae7c95163a1d37768e`

### Item Pickup

- Contributor: UGILA (Freesound), via Pixabay's freesound_community
- Source page: <https://pixabay.com/sound-effects/film-special-effects-item-pickup-37089/>
- Download: <https://cdn.pixabay.com/download/audio/2022/03/10/audio_14c68034ff.mp3?filename=freesound_community-item-pickup-37089.mp3>
- SHA-256: `bab708cf7ceb3be73382af2826683bcaa5f0ac91a84be9947fc27d47fa8de78a`

### Mechanical Door

- Contributor: DRAGON-STUDIO
- Source page: <https://pixabay.com/sound-effects/film-special-effects-mechanical-door-386159/>
- Download: <https://cdn.pixabay.com/download/audio/2025/08/07/audio_cf6a8c2604.mp3?filename=dragon-studio-mechanical-door-386159.mp3>
- SHA-256: `1892fd129e9a64bb97050a0a4913e34a08831c68be5a69dee5fa062ae29d7cf4`

### Punch

- Contributor: Universfield
- Source page: <https://pixabay.com/sound-effects/film-special-effects-punch-140236/>
- Download: <https://cdn.pixabay.com/download/audio/2023/02/22/audio_d7a43e9b3b.mp3?filename=punch-140236.mp3>
- SHA-256: `c630d23f9542dda52b53e3b162a0b98a2d29e5b3c3bf390b84b6c0279766b7b6`

### Boost

- Contributor: Eponn (Freesound), via Pixabay's freesound_community
- Source page: <https://pixabay.com/sound-effects/film-special-effects-boost-100537/>
- Download: <https://cdn.pixabay.com/download/audio/2022/03/24/audio_f57273b4d6.mp3?filename=boost-100537.mp3>
- SHA-256: `28e90486cc2cdc78e17a14e3ecd392c84cc957614a6a0f8cdae0ab16f5595308`

### toy button

- Contributor: Leszek_Szary (Freesound), via Pixabay's freesound_community
- Source page: <https://pixabay.com/sound-effects/film-special-effects-toy-button-105724/>
- Download: <https://cdn.pixabay.com/download/audio/2022/03/24/audio_4b99bedc30.mp3?filename=toy-button-105724.mp3>
- SHA-256: `14419042c91171ce3f2f17177e368e17a827073eb7425ea83c42ee3b647c865f`

### Game Bonus 02

- Contributor: Universfield
- Source page: <https://pixabay.com/sound-effects/film-special-effects-game-bonus-02-294436/>
- Reproducible download mirror: <https://raw.githubusercontent.com/Gunturadhtya/GIMERSIA-2025/0bd7e74e7c7ed4dcd1530c8f81e51a565da448ad/Assets/Audio/game-bonus-02-294436.mp3>
- SHA-256: `a819cdf23d1bd4c79f6a4415ebac0120b33cd7530b973f5740c631bd8e7123ea`

### Swing Whoosh

- Contributor: Jofae
- Source page: <https://pixabay.com/sound-effects/film-special-effects-swing-whoosh-110410/>
- Download: <https://cdn.pixabay.com/download/audio/2022/04/29/audio_f28098ce3c.mp3?filename=swing-whoosh-110410.mp3>
- SHA-256: `acac9d9e5137fdb038f39aef89650b437a30a6b38c833859115c0677692c77dd`

### Game Over 31

- Contributor: Tuomas_Data
- Source page: <https://pixabay.com/sound-effects/film-special-effects-game-over-31-179699/>
- Download: <https://cdn.pixabay.com/download/audio/2023/12/04/audio_b62aad1ff9.mp3?filename=tuomas_data-game-over-31-179699.mp3>
- SHA-256: `01ab4b2678b8c7f3c07ceb57056021925844bb216bf7d90b0d4f65682dbe8164`
- Processed `sfx/game_over.wav` SHA-256: `a5580bfa30c2bfaf2f33f38b67f12b8a8ad13fdcf2434a7c2f10463c731b160b`

## Output mapping

| Game sound | Adapted from |
| --- | --- |
| `robot_jump.wav` | Swing Whoosh |
| `robot_land.wav`, `robot_step_a.wav`, `robot_step_b.wav` | large mech robot steps |
| `coin_collect.wav` | Game Bonus 02 |
| `enemy_stomp.wav` | Punch + toy button |
| `player_death.wav` | Robot motor segment + Punch |
| `player_respawn.wav` | Boost + Item Pickup |
| `checkpoint_raise.wav` | Reversed Mechanical Door + Item Pickup |
| `goal_flag_lower.wav` | Mechanical Door + toy button |
| `level_complete.wav` | Item Pickup four-note layer + toy button |
| `game_over.wav` | Game Over 31 |
| `ui_pause_toggle.wav`, `ui_hover.wav`, `ui_back.wav` | toy button |
| `ui_confirm.wav` | Item Pickup + toy button |

## License boundary

Pixabay permits free commercial and non-commercial use, modification, and
adaptation without required attribution. It does not permit distributing
Pixabay content on a standalone basis when no creative effort has been applied
and the content remains substantially unchanged.

This repository therefore keeps only the edited, game-specific outputs and the
rebuild recipe, not the original MP3 recordings. Do not extract or redistribute
the WAV files as a standalone sound library. See the official
[license summary](https://pixabay.com/service/license-summary/) and
[FAQ](https://pixabay.com/service/faq/) for the current terms.
