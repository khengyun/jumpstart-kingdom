#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
output_dir="$script_dir/sfx"
work_dir="$(mktemp -d "${TMPDIR:-/tmp}/jumpstart-pixabay.XXXXXX")"

cleanup() {
	find "$work_dir" -depth -delete
}
trap cleanup EXIT

download() {
	local filename="$1"
	local url="$2"
	local sha256="$3"
	local destination="$work_dir/$filename"

	curl --fail --location --silent --show-error --retry 3 \
		--output "$destination" "$url"
	printf '%s  %s\n' "$sha256" "$destination" | sha256sum --check --status
}

download \
	"robot_motor.mp3" \
	"https://cdn.pixabay.com/download/audio/2022/04/06/audio_c6e87c6ce0.mp3?filename=shidenbeatsmusic-robot-moving-driving-takeoff-motor-sound-12-different-ses-109030.mp3" \
	"ba4355a12739e3ee495ef8d55413e8cbb965f32923bf4030603fcbc9bff171af"
download \
	"robot_steps.mp3" \
	"https://cdn.pixabay.com/download/audio/2025/11/07/audio_9ce2f3127d.mp3?filename=bannythecoolio-large-mech-robot-steps-432560.mp3" \
	"d5dc01543c919ef0a022ff3fd73bd315f501919fee6069ae7c95163a1d37768e"
download \
	"item_pickup.mp3" \
	"https://cdn.pixabay.com/download/audio/2022/03/10/audio_14c68034ff.mp3?filename=freesound_community-item-pickup-37089.mp3" \
	"bab708cf7ceb3be73382af2826683bcaa5f0ac91a84be9947fc27d47fa8de78a"
download \
	"mechanical_door.mp3" \
	"https://cdn.pixabay.com/download/audio/2025/08/07/audio_cf6a8c2604.mp3?filename=dragon-studio-mechanical-door-386159.mp3" \
	"1892fd129e9a64bb97050a0a4913e34a08831c68be5a69dee5fa062ae29d7cf4"
download \
	"punch.mp3" \
	"https://cdn.pixabay.com/download/audio/2023/02/22/audio_d7a43e9b3b.mp3?filename=punch-140236.mp3" \
	"c630d23f9542dda52b53e3b162a0b98a2d29e5b3c3bf390b84b6c0279766b7b6"
download \
	"boost.mp3" \
	"https://cdn.pixabay.com/download/audio/2022/03/24/audio_f57273b4d6.mp3?filename=boost-100537.mp3" \
	"28e90486cc2cdc78e17a14e3ecd392c84cc957614a6a0f8cdae0ab16f5595308"
download \
	"toy_button.mp3" \
	"https://cdn.pixabay.com/download/audio/2022/03/24/audio_4b99bedc30.mp3?filename=toy-button-105724.mp3" \
	"14419042c91171ce3f2f17177e368e17a827073eb7425ea83c42ee3b647c865f"
download \
	"game_bonus_02.mp3" \
	"https://raw.githubusercontent.com/Gunturadhtya/GIMERSIA-2025/0bd7e74e7c7ed4dcd1530c8f81e51a565da448ad/Assets/Audio/game-bonus-02-294436.mp3" \
	"a819cdf23d1bd4c79f6a4415ebac0120b33cd7530b973f5740c631bd8e7123ea"
download \
	"swing_whoosh.mp3" \
	"https://cdn.pixabay.com/download/audio/2022/04/29/audio_f28098ce3c.mp3?filename=swing-whoosh-110410.mp3" \
	"acac9d9e5137fdb038f39aef89650b437a30a6b38c833859115c0677692c77dd"
download \
	"game_over_31.mp3" \
	"https://cdn.pixabay.com/download/audio/2023/12/04/audio_b62aad1ff9.mp3?filename=tuomas_data-game-over-31-179699.mp3" \
	"01ab4b2678b8c7f3c07ceb57056021925844bb216bf7d90b0d4f65682dbe8164"

mkdir -p "$output_dir"

ffmpeg_common=(-hide_banner -loglevel error -y)
wav_common=(-ac 1 -ar 44100 -c:a pcm_s16le)

# The user-selected Swing Whoosh is kept intentionally recognizable: remove its
# leading/trailing silence, brighten it slightly, and level it for the jump hook.
ffmpeg "${ffmpeg_common[@]}" -i "$work_dir/swing_whoosh.mp3" \
	-af "atrim=start=0.045:end=0.235,asetpts=PTS-STARTPTS,aresample=44100,rubberband=pitch=1.06,highpass=f=180,lowpass=f=11000,volume=2.35,afade=t=in:st=0:d=0.004,afade=t=out:st=0.14:d=0.05,apad=whole_dur=0.24,atrim=duration=0.24,alimiter=limit=0.82:level=false:latency=true" \
	"${wav_common[@]}" "$output_dir/robot_jump.wav"

ffmpeg "${ffmpeg_common[@]}" -i "$work_dir/robot_steps.mp3" \
	-af "atrim=start=0.03:end=0.47,asetpts=PTS-STARTPTS,aresample=44100,rubberband=pitch=1.32,highpass=f=95,lowpass=f=6200,volume=0.30,afade=t=in:st=0:d=0.004,afade=t=out:st=0.31:d=0.11,apad=whole_dur=0.43,atrim=duration=0.43,alimiter=limit=0.82:level=false:latency=true" \
	"${wav_common[@]}" "$output_dir/robot_land.wav"

ffmpeg "${ffmpeg_common[@]}" -i "$work_dir/robot_steps.mp3" \
	-af "atrim=start=0.035:end=0.31,asetpts=PTS-STARTPTS,aresample=44100,rubberband=pitch=1.55,highpass=f=520,lowpass=f=7000,volume=0.62,afade=t=in:st=0:d=0.003,afade=t=out:st=0.20:d=0.07,apad=whole_dur=0.34,atrim=duration=0.34,alimiter=limit=0.72:level=false:latency=true" \
	"${wav_common[@]}" "$output_dir/robot_step_a.wav"

ffmpeg "${ffmpeg_common[@]}" -i "$work_dir/robot_steps.mp3" \
	-af "atrim=start=1.075:end=1.36,asetpts=PTS-STARTPTS,aresample=44100,rubberband=pitch=1.68,highpass=f=600,lowpass=f=7600,volume=0.58,afade=t=in:st=0:d=0.003,afade=t=out:st=0.21:d=0.07,apad=whole_dur=0.34,atrim=duration=0.34,alimiter=limit=0.72:level=false:latency=true" \
	"${wav_common[@]}" "$output_dir/robot_step_b.wav"

# Game Bonus 02 is the user-selected coin cue. Its long silent tail is removed,
# then it is lightly pitched and filtered to sit behind rapid coin pickups.
ffmpeg "${ffmpeg_common[@]}" -i "$work_dir/game_bonus_02.mp3" \
	-af "atrim=start=0.055:end=0.98,asetpts=PTS-STARTPTS,aresample=44100,rubberband=pitch=1.04,highpass=f=180,lowpass=f=12000,volume=0.74,afade=t=in:st=0:d=0.004,afade=t=out:st=0.82:d=0.09,apad=whole_dur=0.93,atrim=duration=0.93,alimiter=limit=0.84:level=false:latency=true" \
	"${wav_common[@]}" "$output_dir/coin_collect.wav"

ffmpeg "${ffmpeg_common[@]}" -i "$work_dir/punch.mp3" -i "$work_dir/toy_button.mp3" \
	-filter_complex "[0:a]atrim=start=0.08:end=0.56,asetpts=PTS-STARTPTS,aresample=44100,rubberband=pitch=1.22,lowpass=f=4700,volume=0.48[p];[1:a]atrim=start=0:end=0.22,asetpts=PTS-STARTPTS,aresample=44100,rubberband=pitch=0.82,volume=0.20,adelay=48:all=1[b];[p][b]amix=inputs=2:duration=longest:normalize=0,afade=t=out:st=0.35:d=0.12,apad=whole_dur=0.50,atrim=duration=0.50,alimiter=limit=0.86:level=false:latency=true[out]" \
	-map "[out]" "${wav_common[@]}" "$output_dir/enemy_stomp.wav"

ffmpeg "${ffmpeg_common[@]}" -i "$work_dir/robot_motor.mp3" -i "$work_dir/punch.mp3" \
	-filter_complex "[0:a]atrim=start=40.975:end=42.75,asetpts=PTS-STARTPTS,aresample=44100,areverse,rubberband=pitch=0.78,lowpass=f=6500,volume=0.58[down];[1:a]atrim=start=0.08:end=0.46,asetpts=PTS-STARTPTS,aresample=44100,rubberband=pitch=0.68,lowpass=f=3600,volume=0.28[hit];[down][hit]amix=inputs=2:duration=longest:normalize=0,afade=t=out:st=0.92:d=0.24,apad=whole_dur=1.20,atrim=duration=1.20,alimiter=limit=0.88:level=false:latency=true[out]" \
	-map "[out]" "${wav_common[@]}" "$output_dir/player_death.wav"

ffmpeg "${ffmpeg_common[@]}" -i "$work_dir/boost.mp3" -i "$work_dir/item_pickup.mp3" \
	-filter_complex "[0:a]atrim=start=0.06:end=0.70,asetpts=PTS-STARTPTS,aresample=44100,rubberband=pitch=1.24,highpass=f=200,volume=0.38[up];[1:a]atrim=start=0.055:end=0.40,asetpts=PTS-STARTPTS,aresample=44100,rubberband=pitch=1.55,highpass=f=520,volume=0.52,adelay=410:all=1[chime];[up][chime]amix=inputs=2:duration=longest:normalize=0,afade=t=out:st=0.68:d=0.10,apad=whole_dur=0.82,atrim=duration=0.82,alimiter=limit=0.88:level=false:latency=true[out]" \
	-map "[out]" "${wav_common[@]}" "$output_dir/player_respawn.wav"

# Flag cues reuse the door mechanism in opposite directions, with different
# pitch, EQ, timing, and confirmation layers.
ffmpeg "${ffmpeg_common[@]}" -i "$work_dir/mechanical_door.mp3" -i "$work_dir/item_pickup.mp3" \
	-filter_complex "[0:a]atrim=start=0.055:end=0.96,asetpts=PTS-STARTPTS,aresample=44100,areverse,rubberband=pitch=1.14,highpass=f=160,lowpass=f=7800,volume=0.48[raise];[1:a]atrim=start=0.055:end=0.40,asetpts=PTS-STARTPTS,aresample=44100,rubberband=pitch=1.48,highpass=f=500,volume=0.50,adelay=700:all=1[chime];[raise][chime]amix=inputs=2:duration=longest:normalize=0,afade=t=out:st=1.02:d=0.12,apad=whole_dur=1.18,atrim=duration=1.18,alimiter=limit=0.88:level=false:latency=true[out]" \
	-map "[out]" "${wav_common[@]}" "$output_dir/checkpoint_raise.wav"

ffmpeg "${ffmpeg_common[@]}" -i "$work_dir/mechanical_door.mp3" -i "$work_dir/toy_button.mp3" \
	-filter_complex "[0:a]atrim=start=0.055:end=0.96,asetpts=PTS-STARTPTS,aresample=44100,rubberband=pitch=0.84,highpass=f=120,lowpass=f=6500,volume=0.43[lower];[1:a]atrim=start=0:end=0.20,asetpts=PTS-STARTPTS,aresample=44100,rubberband=pitch=0.72,volume=0.24,adelay=780:all=1[stop];[lower][stop]amix=inputs=2:duration=longest:normalize=0,afade=t=out:st=0.88:d=0.10,apad=whole_dur=1.02,atrim=duration=1.02,alimiter=limit=0.84:level=false:latency=true[out]" \
	-map "[out]" "${wav_common[@]}" "$output_dir/goal_flag_lower.wav"

ffmpeg "${ffmpeg_common[@]}" -i "$work_dir/item_pickup.mp3" -i "$work_dir/toy_button.mp3" \
	-filter_complex "[0:a]atrim=start=0.055:end=0.43,asetpts=PTS-STARTPTS,aresample=44100,highpass=f=430,asplit=4[n1][n2][n3][n4];[n1]rubberband=pitch=1.00,volume=0.38[c1];[n2]rubberband=pitch=1.26,volume=0.42,adelay=180:all=1[c2];[n3]rubberband=pitch=1.50,volume=0.46,adelay=360:all=1[c3];[n4]rubberband=pitch=2.00,volume=0.55,adelay=620:all=1[c4];[1:a]atrim=start=0:end=0.25,asetpts=PTS-STARTPTS,aresample=44100,rubberband=pitch=0.82,lowpass=f=5200,volume=0.28,adelay=850:all=1[final];[c1][c2][c3][c4][final]amix=inputs=5:duration=longest:normalize=0,afade=t=out:st=1.12:d=0.22,apad=whole_dur=1.42,atrim=duration=1.42,alimiter=limit=0.90:level=false:latency=true[out]" \
	-map "[out]" "${wav_common[@]}" "$output_dir/level_complete.wav"

# User-selected loss cue: remove the long silent tail and level it for the menu.
ffmpeg "${ffmpeg_common[@]}" -i "$work_dir/game_over_31.mp3" \
	-af "atrim=start=0.025:end=1.12,asetpts=PTS-STARTPTS,aresample=44100,highpass=f=80,lowpass=f=14000,volume=0.65,afade=t=in:st=0:d=0.004,afade=t=out:st=1.01:d=0.08,apad=whole_dur=1.10,atrim=duration=1.10,alimiter=limit=0.84:level=false:latency=true" \
	"${wav_common[@]}" "$output_dir/game_over.wav"

# Interface family: one source, transformed into four short but related cues.
ffmpeg "${ffmpeg_common[@]}" -i "$work_dir/toy_button.mp3" \
	-af "atrim=start=0:end=0.18,asetpts=PTS-STARTPTS,aresample=44100,highpass=f=380,rubberband=pitch=1.00,volume=0.35,afade=t=out:st=0.11:d=0.05,apad=whole_dur=0.18,atrim=duration=0.18,alimiter=limit=0.78:level=false:latency=true" \
	"${wav_common[@]}" "$output_dir/ui_pause_toggle.wav"

ffmpeg "${ffmpeg_common[@]}" -i "$work_dir/toy_button.mp3" \
	-af "atrim=start=0:end=0.11,asetpts=PTS-STARTPTS,aresample=44100,highpass=f=720,rubberband=pitch=1.82,volume=0.72,afade=t=out:st=0.065:d=0.03,apad=whole_dur=0.11,atrim=duration=0.11,alimiter=limit=0.70:level=false:latency=true" \
	"${wav_common[@]}" "$output_dir/ui_hover.wav"

ffmpeg "${ffmpeg_common[@]}" -i "$work_dir/item_pickup.mp3" -i "$work_dir/toy_button.mp3" \
	-filter_complex "[0:a]atrim=start=0.055:end=0.35,asetpts=PTS-STARTPTS,aresample=44100,rubberband=pitch=1.30,highpass=f=500,volume=0.40[pick];[1:a]atrim=start=0:end=0.19,asetpts=PTS-STARTPTS,aresample=44100,volume=0.30[button];[pick][button]amix=inputs=2:duration=longest:normalize=0,afade=t=out:st=0.29:d=0.08,apad=whole_dur=0.40,atrim=duration=0.40,alimiter=limit=0.82:level=false:latency=true[out]" \
	-map "[out]" "${wav_common[@]}" "$output_dir/ui_confirm.wav"

ffmpeg "${ffmpeg_common[@]}" -i "$work_dir/toy_button.mp3" \
	-af "atrim=start=0:end=0.25,asetpts=PTS-STARTPTS,aresample=44100,areverse,rubberband=pitch=0.78,lowpass=f=5200,volume=0.30,afade=t=out:st=0.21:d=0.07,apad=whole_dur=0.32,atrim=duration=0.32,alimiter=limit=0.76:level=false:latency=true" \
	"${wav_common[@]}" "$output_dir/ui_back.wav"

printf 'Built 16 Pixabay-derived sound effects in %s\n' "$output_dir"
