@tool
extends Control
class_name PlatformBlock

@export var grass_top: bool = true:
	set(value):
		grass_top = value
		_queue_sync()

var _sync_queued: bool = false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_queue_sync()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_queue_sync()


func _queue_sync() -> void:
	if not is_inside_tree() or _sync_queued:
		return
	_sync_queued = true
	call_deferred("_sync_geometry")


func _sync_geometry() -> void:
	_sync_queued = false
	var body := get_node_or_null("StaticBody2D") as StaticBody2D
	var collision := get_node_or_null("StaticBody2D/CollisionShape2D") as CollisionShape2D
	var grass := get_node_or_null("Grass") as TextureRect
	if body == null or collision == null:
		return

	body.position = size * 0.5
	var rectangle := collision.shape as RectangleShape2D
	if rectangle != null:
		rectangle.size = size
	if grass != null:
		grass.visible = grass_top
		grass.size.y = minf(16.0, size.y)
