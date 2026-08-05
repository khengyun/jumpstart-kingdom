extends Node

const SFX_BUS: StringName = &"SFX"
const UI_BUS: StringName = &"UI"
const PLAYER_POOL_SIZE: int = 12

const STREAM_PATHS: Dictionary = {
	&"robot_jump": "res://assets/audio/sfx/robot_jump.wav",
	&"robot_land": "res://assets/audio/sfx/robot_land.wav",
	&"robot_step_a": "res://assets/audio/sfx/robot_step_a.wav",
	&"robot_step_b": "res://assets/audio/sfx/robot_step_b.wav",
	&"coin_collect": "res://assets/audio/sfx/coin_collect.wav",
	&"enemy_stomp": "res://assets/audio/sfx/enemy_stomp.wav",
	&"player_death": "res://assets/audio/sfx/player_death.wav",
	&"player_respawn": "res://assets/audio/sfx/player_respawn.wav",
	&"checkpoint_raise": "res://assets/audio/sfx/checkpoint_raise.wav",
	&"goal_flag_lower": "res://assets/audio/sfx/goal_flag_lower.wav",
	&"level_complete": "res://assets/audio/sfx/level_complete.wav",
	&"game_over": "res://assets/audio/sfx/game_over.wav",
	&"ui_pause_toggle": "res://assets/audio/sfx/ui_pause_toggle.wav",
	&"ui_hover": "res://assets/audio/sfx/ui_hover.wav",
	&"ui_confirm": "res://assets/audio/sfx/ui_confirm.wav",
	&"ui_back": "res://assets/audio/sfx/ui_back.wav",
}

const UI_SOUNDS: Dictionary = {
	&"ui_pause_toggle": true,
	&"ui_hover": true,
	&"ui_confirm": true,
	&"ui_back": true,
}

var _players: Array[AudioStreamPlayer] = []
var _streams: Dictionary = {}
var _next_player_index: int = 0
var _next_step_is_a: bool = true
var _play_generation: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_optional_streams()
	for index: int in range(PLAYER_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.name = "SfxPlayer%02d" % index
		player.process_mode = Node.PROCESS_MODE_ALWAYS
		player.max_polyphony = 1
		add_child(player)
		_players.append(player)


func play_sound(
	sound_id: StringName,
	volume_db: float = 0.0,
	pitch_min: float = 1.0,
	pitch_max: float = 1.0
) -> void:
	var stream: AudioStream = _streams.get(sound_id) as AudioStream
	if stream == null:
		if not STREAM_PATHS.has(sound_id):
			push_warning("Unknown sound effect: %s" % sound_id)
		return

	var player: AudioStreamPlayer = _get_available_player()
	player.stream = stream
	player.bus = UI_BUS if UI_SOUNDS.has(sound_id) else SFX_BUS
	player.volume_db = volume_db
	player.pitch_scale = randf_range(minf(pitch_min, pitch_max), maxf(pitch_min, pitch_max))
	player.play()


func play_sound_delayed(
	sound_id: StringName,
	delay_seconds: float,
	volume_db: float = 0.0,
	pitch_min: float = 1.0,
	pitch_max: float = 1.0
) -> void:
	var play_generation: int = _play_generation
	await get_tree().create_timer(delay_seconds, true, false, true).timeout
	if play_generation != _play_generation:
		return
	play_sound(sound_id, volume_db, pitch_min, pitch_max)


func play_footstep() -> void:
	var sound_id: StringName = &"robot_step_a" if _next_step_is_a else &"robot_step_b"
	_next_step_is_a = not _next_step_is_a
	play_sound(sound_id, -14.0, 0.97, 1.03)


func stop_all() -> void:
	_play_generation += 1
	_next_player_index = 0
	_next_step_is_a = true
	for player: AudioStreamPlayer in _players:
		player.stop()
		player.stream = null


func _load_optional_streams() -> void:
	var missing_count: int = 0
	for sound_id: StringName in STREAM_PATHS:
		var resource_path: String = STREAM_PATHS[sound_id]
		if not ResourceLoader.exists(resource_path):
			missing_count += 1
			continue
		var stream := load(resource_path) as AudioStream
		if stream == null:
			missing_count += 1
			continue
		_streams[sound_id] = stream

	if missing_count > 0:
		push_warning(
			"%d optional sound effects are unavailable; the game will continue silently for them."
			% missing_count
		)


func _get_available_player() -> AudioStreamPlayer:
	for player: AudioStreamPlayer in _players:
		if not player.playing:
			return player

	var player: AudioStreamPlayer = _players[_next_player_index]
	_next_player_index = (_next_player_index + 1) % _players.size()
	player.stop()
	return player
