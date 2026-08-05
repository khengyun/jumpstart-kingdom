extends Area2D
class_name Checkpoint

signal activated(respawn_position: Vector2, points: int)

@export_range(0, 5000, 10) var points: int = 500

var _activated: bool = false

@onready var _flag: Node2D = $AnimatedFlag
@onready var _respawn_point: Marker2D = $RespawnPoint


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _activated or not body.has_method("set_spawn_position"):
		return
	_activated = true
	set_deferred("monitoring", false)
	body.call("set_spawn_position", _respawn_point.global_position)
	_flag.call("raise_flag")
	GameAudio.play_sound(&"checkpoint_raise", -3.0)
	activated.emit(_respawn_point.global_position, points)
