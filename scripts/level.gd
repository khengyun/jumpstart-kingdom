extends Node2D
class_name GameLevel

signal coin_collected(value: int)
signal enemy_defeated(points: int)
signal checkpoint_activated(respawn_position: Vector2, points: int)
signal goal_reached

@export var level_title: String = "Level 1"
@export var level_bounds: Rect2 = Rect2(0.0, 0.0, 3400.0, 540.0)
@export var background_texture: Texture2D

@onready var _player_spawn: Marker2D = $Markers/PlayerSpawn


func _ready() -> void:
	_connect_branch_signals(get_node_or_null("Pickups"), &"collected", _on_coin_collected)
	_connect_branch_signals(get_node_or_null("Enemies"), &"defeated", _on_enemy_defeated)
	_connect_branch_signals(
		get_node_or_null("GameplayAreas"), &"activated", _on_checkpoint_activated
	)
	_connect_branch_signals(get_node_or_null("GameplayAreas"), &"reached", _on_goal_reached)


func get_player_spawn_position() -> Vector2:
	return _player_spawn.global_position


func _connect_branch_signals(
	branch: Node, signal_name: StringName, callback: Callable
) -> void:
	if branch == null:
		push_warning("Level is missing the expected branch for signal: %s" % signal_name)
		return
	for child: Node in branch.find_children("*", "", true, false):
		if child.has_signal(signal_name) and not child.is_connected(signal_name, callback):
			child.connect(signal_name, callback)


func _on_coin_collected(value: int) -> void:
	coin_collected.emit(value)


func _on_enemy_defeated(points: int) -> void:
	enemy_defeated.emit(points)


func _on_checkpoint_activated(respawn_position: Vector2, points: int) -> void:
	checkpoint_activated.emit(respawn_position, points)


func _on_goal_reached() -> void:
	goal_reached.emit()
