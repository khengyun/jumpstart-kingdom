extends Node2D

@export var start_raised: bool = true

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _transition_id: int = 0


func _ready() -> void:
	_sprite.play(&"waving" if start_raised else &"lowered")


func raise_flag() -> void:
	_transition_id += 1
	var transition_id: int = _transition_id
	_sprite.play(&"raising")
	await _sprite.animation_finished
	if transition_id == _transition_id and _sprite.animation == &"raising":
		_sprite.play(&"waving")


func lower_flag() -> void:
	_transition_id += 1
	var transition_id: int = _transition_id
	_sprite.play(&"lowering")
	await _sprite.animation_finished
	if transition_id == _transition_id and _sprite.animation == &"lowering":
		_sprite.play(&"lowered")
