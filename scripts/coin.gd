extends Area2D

signal collected(value: int)

@export_range(1, 100, 1) var value: int = 1
@export_range(0.0, 24.0, 0.5) var bob_height: float = 6.0
@export_range(0.1, 8.0, 0.1) var bob_speed: float = 2.8

var _origin_y: float
var _elapsed: float = 0.0
var _taken: bool = false


func _ready() -> void:
	_origin_y = position.y
	body_entered.connect(_on_body_entered)
	queue_redraw()


func _physics_process(delta: float) -> void:
	_elapsed += delta
	position.y = _origin_y + sin(_elapsed * bob_speed) * bob_height
	rotation = sin(_elapsed * bob_speed * 0.65) * 0.08


func _on_body_entered(body: Node2D) -> void:
	if _taken or not body.has_method("bounce"):
		return

	_taken = true
	set_deferred("monitoring", false)
	set_physics_process(false)
	collected.emit(value)

	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "position:y", position.y - 42.0, 0.24).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.18)
	tween.tween_property(self, "modulate:a", 0.0, 0.24)
	tween.chain().tween_callback(queue_free)


func _draw() -> void:
	draw_circle(Vector2.ZERO, 11.0, Color("#6d3d08"))
	draw_circle(Vector2.ZERO, 9.0, Color("#ffd84a"))
	draw_circle(Vector2(-2.5, -2.5), 3.0, Color("#fff3a6"))
	draw_arc(Vector2.ZERO, 6.5, -PI * 0.5, PI * 0.5, 18, Color("#e69a17"), 2.0)
