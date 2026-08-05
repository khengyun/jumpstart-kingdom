extends Area2D

signal reached

var _activated: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if _activated or not body.has_method("bounce"):
		return
	_activated = true
	set_deferred("monitoring", false)
	reached.emit()
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(-3.0, -108.0, 6.0, 108.0), Color("#d9ecf2"))
	draw_circle(Vector2(0.0, -110.0), 7.0, Color("#ffd84a"))
	var banner_color := Color("#5ee18b") if not _activated else Color("#ffd84a")
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(3.0, -102.0),
			Vector2(48.0, -88.0),
			Vector2(3.0, -70.0),
		]),
		banner_color
	)
	draw_rect(Rect2(-18.0, -4.0, 36.0, 4.0), Color("#405366"))
