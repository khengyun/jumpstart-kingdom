extends Node2D
class_name GameSession

signal stats_changed(score: int, coins: int, deaths: int, lives: int, level_title: String)
signal level_completed(has_next_level: bool, level_title: String, score: int)
signal level_loaded(level_title: String, background_texture: Texture2D)
signal run_lost(level_title: String, score: int)
signal final_life_lost
signal level_finish_started

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const STARTING_LIVES: int = 3

@onready var _level_host: Node2D = $LevelHost
@onready var _actors: Node2D = $RuntimeActors

var _level_scenes: Array[PackedScene] = []
var _level_titles := PackedStringArray()
var _level: GameLevel
var _player: Player
var _level_index: int = -1
var _checkpoint_position: Vector2 = Vector2.ZERO
var _score: int = 0
var _coins: int = 0
var _deaths: int = 0
var _lives: int = STARTING_LIVES
var _level_start_score: int = 0
var _level_start_coins: int = 0
var _respawning: bool = false
var _finished: bool = false
var _generation: int = 0


func configure(level_scenes: Array[PackedScene]) -> void:
	_level_scenes = level_scenes.duplicate()
	_level_titles = _read_level_titles()


func start_new_game() -> void:
	start_level(0)


func start_level(index: int) -> void:
	if index < 0 or index >= _level_scenes.size():
		push_error("Cannot start unknown level index: %d" % index)
		return
	_score = 0
	_coins = 0
	_deaths = 0
	_lives = STARTING_LIVES
	_load_level(index)


func restart_current_level() -> void:
	if _level_index < 0:
		return
	_score = _level_start_score
	_coins = _level_start_coins
	_load_level(_level_index)


func advance_or_replay() -> void:
	if has_next_level():
		_load_level(_level_index + 1)
	else:
		start_new_game()


func retry_after_game_over() -> void:
	if _level_index < 0:
		return
	_score = _level_start_score
	_coins = _level_start_coins
	_lives = STARTING_LIVES
	_load_level(_level_index)


func request_respawn() -> void:
	if _respawning or _finished or not is_instance_valid(_player):
		return
	_player.die()


func end_run() -> void:
	_generation += 1
	_respawning = false
	_finished = false
	_level_index = -1
	_clear_session_nodes()


func get_level_count() -> int:
	return _level_scenes.size()


func get_level_titles() -> PackedStringArray:
	return _level_titles.duplicate()


func _read_level_titles() -> PackedStringArray:
	var titles := PackedStringArray()
	for index: int in _level_scenes.size():
		var candidate: Node = _level_scenes[index].instantiate()
		var level_preview := candidate as GameLevel
		if level_preview == null:
			if candidate != null:
				candidate.free()
			titles.append("Level %02d" % (index + 1))
			continue
		var title: String = level_preview.level_title.strip_edges()
		candidate.free()
		if title.is_empty():
			title = "Level %02d" % (index + 1)
		titles.append(title)
	return titles


func get_current_level_number() -> int:
	return _level_index + 1 if _level_index >= 0 else 0


func get_current_level_title() -> String:
	return _level.level_title if is_instance_valid(_level) else ""


func has_next_level() -> bool:
	return _level_index >= 0 and _level_index + 1 < _level_scenes.size()


func _load_level(index: int) -> void:
	if index < 0 or index >= _level_scenes.size():
		push_error("Level index is outside the configured level list: %d" % index)
		return

	var next_level := _level_scenes[index].instantiate() as GameLevel
	if next_level == null:
		push_error("Configured level scene must use scripts/level.gd")
		return

	_generation += 1
	_respawning = false
	_finished = false
	_clear_session_nodes()
	_level_index = index

	_level = next_level
	_level_host.add_child(_level)
	_level.coin_collected.connect(_on_coin_collected)
	_level.enemy_defeated.connect(_on_enemy_defeated)
	_level.checkpoint_activated.connect(_on_checkpoint_activated)
	_level.goal_reached.connect(_on_goal_reached)

	_checkpoint_position = _level.get_player_spawn_position()
	_spawn_player()
	_level_start_score = _score
	_level_start_coins = _coins
	level_loaded.emit(_level.level_title, _level.background_texture)
	_emit_stats()


func _clear_session_nodes() -> void:
	_player = null
	for child: Node in _actors.get_children():
		_actors.remove_child(child)
		child.queue_free()
	if is_instance_valid(_level):
		_level_host.remove_child(_level)
		_level.queue_free()
	_level = null


func _spawn_player() -> void:
	var player_instance := PLAYER_SCENE.instantiate() as Player
	if player_instance == null:
		push_error("Player scene root must use scripts/player.gd")
		return
	player_instance.position = _actors.to_local(_checkpoint_position)
	player_instance.initialize_spawn_from_scene = true
	player_instance.died.connect(_on_player_died)
	_actors.add_child(player_instance)
	_player = player_instance
	_player.set_spawn_position(_checkpoint_position)

	var camera := _player.get_node_or_null("Camera2D") as Camera2D
	if camera != null and is_instance_valid(_level):
		var bounds: Rect2 = _level.level_bounds
		camera.limit_left = floori(bounds.position.x)
		camera.limit_top = floori(bounds.position.y)
		camera.limit_right = ceili(bounds.end.x)
		camera.limit_bottom = ceili(bounds.end.y)


func _on_player_died() -> void:
	if _respawning or _finished:
		return
	_respawning = true
	_deaths += 1
	_lives = maxi(_lives - 1, 0)
	var out_of_lives: bool = _lives <= 0
	if out_of_lives:
		_finished = true
		final_life_lost.emit()
	_emit_stats()
	var generation: int = _generation
	await get_tree().create_timer(0.55, true, false, true).timeout
	if generation != _generation:
		return
	if out_of_lives:
		_respawning = false
		GameAudio.play_sound(&"game_over", -2.0)
		var title: String = _level.level_title if is_instance_valid(_level) else ""
		run_lost.emit(title, _score)
		return

	if is_instance_valid(_player):
		var old_player: Player = _player
		_player = null
		old_player.queue_free()
		await old_player.tree_exited
	if generation != _generation:
		return
	_spawn_player()
	GameAudio.play_sound(&"player_respawn", -5.0)
	_respawning = false


func _on_coin_collected(value: int) -> void:
	_coins += value
	_score += value * 100
	_emit_stats()


func _on_enemy_defeated(points: int) -> void:
	_score += points
	_emit_stats()


func _on_checkpoint_activated(respawn_position: Vector2, points: int) -> void:
	_checkpoint_position = respawn_position
	_score += points
	_emit_stats()


func _on_goal_reached() -> void:
	if _finished:
		return
	_finished = true
	level_finish_started.emit()
	_score += 1000
	_emit_stats()
	if is_instance_valid(_player):
		_player.freeze_for_finish()
	GameAudio.play_sound_delayed(&"level_complete", 0.52, -2.0)
	var generation: int = _generation
	await get_tree().create_timer(0.58, true, false, true).timeout
	if generation == _generation and _finished and is_instance_valid(_level):
		level_completed.emit(has_next_level(), _level.level_title, _score)


func _emit_stats() -> void:
	var title: String = _level.level_title if is_instance_valid(_level) else ""
	stats_changed.emit(_score, _coins, _deaths, _lives, title)
