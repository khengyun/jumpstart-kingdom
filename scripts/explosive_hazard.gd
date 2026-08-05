@tool
extends Node2D
class_name ExplosiveHazard

signal armed
signal exploded(world_position: Vector2, radius: float)
signal spent

enum State {
	IDLE,
	FUSING,
	EXPLODING,
	SPENT,
}

const EFFECT_CENTER := Vector2(0.0, -24.0)

@export_category("Detection")
@export_range(8.0, 80.0, 1.0) var trigger_radius: float = 22.0:
	set(value):
		trigger_radius = value
		_queue_geometry_sync()
@export_range(24.0, 180.0, 1.0) var blast_radius: float = 96.0:
	set(value):
		blast_radius = value
		_queue_geometry_sync()

@export_category("Timing")
@export_range(0.1, 3.0, 0.05) var fuse_seconds: float = 0.65
@export_range(0.05, 1.0, 0.01) var blast_active_seconds: float = 0.18
@export_range(0.2, 2.0, 0.05) var cleanup_seconds: float = 0.62

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _shockwave: AnimatedSprite2D = $Shockwave
@onready var _trigger_area: Area2D = $TriggerArea
@onready var _blast_area: Area2D = $BlastArea
@onready var _fuse_timer: Timer = $FuseTimer
@onready var _blast_timer: Timer = $BlastTimer
@onready var _cleanup_timer: Timer = $CleanupTimer

var _state: State = State.IDLE
var _geometry_sync_queued: bool = false
var _cleanup_elapsed: bool = false


func _ready() -> void:
	_queue_geometry_sync()
	_shockwave.visible = false
	_shockwave.stop()
	_shockwave.frame = 0
	if Engine.is_editor_hint():
		queue_redraw()
		return

	_trigger_area.body_entered.connect(_on_trigger_body_entered)
	_blast_area.body_entered.connect(_on_blast_body_entered)
	_fuse_timer.timeout.connect(_explode)
	_blast_timer.timeout.connect(_finish_blast)
	_cleanup_timer.timeout.connect(_on_cleanup_timeout)
	_shockwave.animation_finished.connect(_on_shockwave_animation_finished)
	_sprite.play(&"idle")


func get_state() -> State:
	return _state


func arm() -> void:
	if Engine.is_editor_hint() or _state != State.IDLE:
		return
	_state = State.FUSING
	_trigger_area.set_deferred("monitoring", false)
	_sprite.play(&"fuse")
	_fuse_timer.start(fuse_seconds)
	armed.emit()


func _explode() -> void:
	if _state != State.FUSING:
		return
	_state = State.EXPLODING
	_sprite.play(&"explode")
	_shockwave.visible = true
	_shockwave.frame = 0
	_shockwave.play(&"explode")
	_cleanup_elapsed = false
	GameAudio.play_sound(&"enemy_stomp", -1.0, 0.66, 0.72)
	exploded.emit(global_position + EFFECT_CENTER, blast_radius)
	for body: Node2D in _blast_area.get_overlapping_bodies():
		_kill_body(body)
	_blast_timer.start(blast_active_seconds)
	_cleanup_timer.start(maxf(cleanup_seconds, blast_active_seconds + 0.05))


func _finish_blast() -> void:
	if _state != State.EXPLODING:
		return
	_state = State.SPENT
	_blast_area.set_deferred("monitoring", false)
	spent.emit()


func _on_cleanup_timeout() -> void:
	_cleanup_elapsed = true
	if not _shockwave.is_playing():
		queue_free()


func _on_shockwave_animation_finished() -> void:
	if _cleanup_elapsed:
		queue_free()


func _on_trigger_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		arm()


func _on_blast_body_entered(body: Node2D) -> void:
	if _state == State.EXPLODING:
		_kill_body(body)


func _kill_body(body: Node2D) -> void:
	if body.has_method("die"):
		body.call("die")


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	draw_circle(EFFECT_CENTER, blast_radius, Color(1.0, 0.29, 0.06, 0.1), true)
	draw_circle(EFFECT_CENTER, blast_radius, Color(1.0, 0.38, 0.08, 0.72), false, 1.5)
	draw_circle(EFFECT_CENTER, trigger_radius, Color(0.2, 0.85, 1.0, 0.8), false, 1.5)


func _queue_geometry_sync() -> void:
	if not is_inside_tree() or _geometry_sync_queued:
		return
	_geometry_sync_queued = true
	call_deferred("_sync_geometry")


func _sync_geometry() -> void:
	_geometry_sync_queued = false
	var trigger_shape := get_node_or_null("TriggerArea/CollisionShape2D") as CollisionShape2D
	var blast_shape := get_node_or_null("BlastArea/CollisionShape2D") as CollisionShape2D
	var shockwave := get_node_or_null("Shockwave") as AnimatedSprite2D
	if trigger_shape != null:
		var trigger_circle := trigger_shape.shape as CircleShape2D
		if trigger_circle != null:
			trigger_circle.radius = trigger_radius
	if blast_shape != null:
		var blast_circle := blast_shape.shape as CircleShape2D
		if blast_circle != null:
			blast_circle.radius = blast_radius
	if shockwave != null:
		var shockwave_scale: float = blast_radius / 32.0
		shockwave.scale = Vector2.ONE * shockwave_scale
	queue_redraw()
