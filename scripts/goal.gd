extends Area2D
class_name Goal

signal reached

@export var required_group: StringName

var _activated: bool = false
var _locked_feedback_active: bool = false

@onready var _flag: Node2D = $AnimatedFlag


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _activated or not body.has_method("bounce"):
		return
	if is_locked():
		_play_locked_feedback()
		return
	_activated = true
	set_deferred("monitoring", false)
	GameAudio.play_sound(&"goal_flag_lower", -6.0)
	_flag.call("lower_flag")
	reached.emit()


func is_locked() -> bool:
	return not required_group.is_empty() and not get_tree().get_nodes_in_group(required_group).is_empty()


func _play_locked_feedback() -> void:
	if _locked_feedback_active:
		return
	_locked_feedback_active = true
	GameAudio.play_sound(&"ui_back", -10.0, 0.82, 0.88)
	var tween := create_tween()
	tween.tween_property(_flag, "modulate", Color(1.0, 0.38, 0.25, 1.0), 0.08)
	tween.tween_property(_flag, "modulate", Color.WHITE, 0.18)
	tween.tween_callback(_finish_locked_feedback)


func _finish_locked_feedback() -> void:
	_locked_feedback_active = false
