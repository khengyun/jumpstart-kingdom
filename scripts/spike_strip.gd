@tool
extends Control
class_name SpikeStrip

const SPIKE_TEXTURE: Texture2D = preload("res://assets/hazards/mechanical-spike.png")

var _sync_queued: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var area := get_node_or_null("Area2D") as Area2D
	if (
		not Engine.is_editor_hint()
		and area != null
		and not area.body_entered.is_connected(_on_body_entered)
	):
		area.body_entered.connect(_on_body_entered)
	_queue_sync()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_queue_sync()


func _draw() -> void:
	var spike_count: int = maxi(1, int(round(size.x / 24.0)))
	var spike_width: float = size.x / float(spike_count)
	for index: int in range(spike_count):
		var destination := Rect2(float(index) * spike_width, 0.0, spike_width, size.y)
		draw_texture_rect(SPIKE_TEXTURE, destination, false)


func _queue_sync() -> void:
	if not is_inside_tree() or _sync_queued:
		return
	_sync_queued = true
	call_deferred("_sync_geometry")


func _sync_geometry() -> void:
	_sync_queued = false
	var area := get_node_or_null("Area2D") as Area2D
	var collision := get_node_or_null("Area2D/CollisionShape2D") as CollisionShape2D
	if area == null or collision == null:
		return
	area.position = size * 0.5
	var rectangle := collision.shape as RectangleShape2D
	if rectangle != null:
		rectangle.size = size
	queue_redraw()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.call("die")
