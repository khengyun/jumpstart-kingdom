extends Area2D

signal reached

var _activated: bool = false

@onready var _flag: Node2D = $AnimatedFlag


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _activated or not body.has_method("bounce"):
		return
	_activated = true
	set_deferred("monitoring", false)
	GameAudio.play_sound(&"goal_flag_lower", -6.0)
	_flag.call("lower_flag")
	reached.emit()
