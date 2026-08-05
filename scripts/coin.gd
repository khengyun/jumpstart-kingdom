extends Area2D

signal collected(value: int)

@export_range(1, 100, 1) var value: int = 1
@export_range(0.0, 24.0, 0.5) var bob_height: float = 6.0
@export_range(0.1, 8.0, 0.1) var bob_speed: float = 2.8

var _origin_y: float
var _elapsed: float = 0.0
var _taken: bool = false

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_origin_y = position.y
	body_entered.connect(_on_body_entered)
	_sprite.play(&"spin")


func _physics_process(delta: float) -> void:
	_elapsed += delta
	position.y = _origin_y + sin(_elapsed * bob_speed) * bob_height
	rotation = sin(_elapsed * bob_speed * 0.65) * 0.08


func _on_body_entered(body: Node2D) -> void:
	if _taken or not body.has_method("bounce"):
		return

	_taken = true
	GameAudio.play_sound(&"coin_collect", -3.0, 0.98, 1.04)
	set_deferred("monitoring", false)
	set_physics_process(false)
	collected.emit(value)
	rotation = 0.0
	_sprite.play(&"collect")

	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 42.0, 0.28).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", Vector2(1.25, 1.25), 0.22)
	tween.tween_property(self, "modulate:a", 0.0, 0.28)
	tween.chain().tween_callback(queue_free)
