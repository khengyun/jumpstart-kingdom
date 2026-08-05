@tool
extends CharacterBody2D
class_name FlyingEnemy

signal defeated(points: int)

const FLY_ANIMATION: StringName = &"fly"
const ALERT_ANIMATION: StringName = &"alert"
const DEFEAT_ANIMATION: StringName = &"defeat"

@export_category("Flight Path")
@export_range(10.0, 300.0, 1.0) var speed: float = 72.0
@export_range(20.0, 800.0, 5.0) var patrol_distance: float = 130.0:
	set(value):
		patrol_distance = value
		_queue_editor_redraw()
@export_enum("Left:-1", "Right:1") var initial_direction: int = -1
@export_range(0.0, 80.0, 1.0) var hover_amplitude: float = 12.0:
	set(value):
		hover_amplitude = value
		_queue_editor_redraw()
@export_range(0.0, 4.0, 0.05) var hover_frequency: float = 1.2
@export_range(0.0, 360.0, 1.0) var hover_phase_degrees: float = 0.0

@export_category("Combat")
@export_range(0, 5000, 10) var points: int = 350
@export_range(0.0, 600.0, 10.0) var stomp_min_fall_speed: float = 80.0
@export_range(0.0, 32.0, 1.0) var stomp_height_margin: float = 8.0
@export_range(0.0, 1000.0, 10.0) var stomp_bounce_speed: float = 460.0

@onready var _hitbox: Area2D = $Hitbox
@onready var _detection_area: Area2D = $DetectionArea
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _spawn_position: Vector2
var _direction: float = -1.0
var _elapsed: float = 0.0
var _is_alert: bool = false
var _is_defeated: bool = false


func _ready() -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)
		queue_redraw()
		return

	_spawn_position = global_position
	_direction = -1.0 if initial_direction < 0 else 1.0
	_hitbox.body_entered.connect(_on_hitbox_body_entered)
	_detection_area.body_entered.connect(_on_detection_body_entered)
	_detection_area.body_exited.connect(_on_detection_body_exited)
	_sprite.flip_h = _direction < 0.0
	_sprite.play(FLY_ANIMATION)


func _physics_process(delta: float) -> void:
	_elapsed += delta
	var phase: float = deg_to_rad(hover_phase_degrees)
	var desired_y: float = (
		_spawn_position.y
		+ sin(phase + _elapsed * TAU * hover_frequency) * hover_amplitude
	)

	velocity.x = _direction * speed
	velocity.y = (desired_y - global_position.y) / maxf(delta, 0.0001)
	move_and_slide()

	var x_offset: float = global_position.x - _spawn_position.x
	var reached_edge: bool = (
		(_direction < 0.0 and x_offset <= -patrol_distance)
		or (_direction > 0.0 and x_offset >= patrol_distance)
	)
	if reached_edge:
		global_position.x = clampf(
			global_position.x,
			_spawn_position.x - patrol_distance,
			_spawn_position.x + patrol_distance
		)
		_turn_around()
	elif _has_horizontal_world_collision():
		_turn_around()


func _has_horizontal_world_collision() -> bool:
	for index: int in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(index)
		if absf(collision.get_normal().x) > 0.5:
			return true
	return false


func _turn_around() -> void:
	_direction *= -1.0
	_sprite.flip_h = _direction < 0.0


func _on_detection_body_entered(body: Node2D) -> void:
	if _is_defeated or not body.has_method("die"):
		return
	_is_alert = true
	_sprite.play(ALERT_ANIMATION)


func _on_detection_body_exited(body: Node2D) -> void:
	if _is_defeated or not _is_alert or not body.has_method("die"):
		return
	_is_alert = false
	_sprite.play(FLY_ANIMATION)


func _on_hitbox_body_entered(body: Node2D) -> void:
	if _is_defeated or not body.has_method("die"):
		return

	var character := body as CharacterBody2D
	if character == null:
		return

	var relative_fall_speed: float = character.velocity.y - velocity.y
	var is_stomp: bool = (
		relative_fall_speed > stomp_min_fall_speed
		and character.global_position.y < global_position.y - stomp_height_margin
	)
	if is_stomp and body.has_method("bounce"):
		body.call("bounce", stomp_bounce_speed)
		_be_defeated()
	else:
		body.call("die")


func _be_defeated() -> void:
	_is_defeated = true
	GameAudio.play_sound(&"enemy_stomp", -4.0, 0.95, 1.04)
	velocity = Vector2.ZERO
	collision_layer = 0
	collision_mask = 0
	_hitbox.set_deferred("monitoring", false)
	_detection_area.set_deferred("monitoring", false)
	set_physics_process(false)
	defeated.emit(points)
	_sprite.play(DEFEAT_ANIMATION)

	var tween := create_tween()
	tween.tween_interval(0.28)
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y + 30.0, 0.24)
	tween.tween_property(self, "rotation", rotation + 0.28, 0.24)
	tween.tween_property(self, "modulate:a", 0.0, 0.24)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	var guide_color := Color(0.2, 0.85, 1.0, 0.72)
	draw_line(
		Vector2(-patrol_distance, 0.0),
		Vector2(patrol_distance, 0.0),
		guide_color,
		1.0
	)
	draw_line(
		Vector2(-patrol_distance, -7.0),
		Vector2(-patrol_distance, 7.0),
		guide_color,
		1.0
	)
	draw_line(
		Vector2(patrol_distance, -7.0),
		Vector2(patrol_distance, 7.0),
		guide_color,
		1.0
	)
	draw_line(
		Vector2(0.0, -hover_amplitude),
		Vector2(0.0, hover_amplitude),
		guide_color,
		1.0
	)
	draw_circle(Vector2.ZERO, 105.0, Color(1.0, 0.65, 0.24, 0.25), false, 1.0)


func _queue_editor_redraw() -> void:
	if Engine.is_editor_hint() and is_inside_tree():
		queue_redraw()
