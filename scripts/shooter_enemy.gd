@tool
extends CharacterBody2D
class_name ShooterEnemy

signal defeated(points: int)
signal projectile_fired(projectile: Node2D)

const PROJECTILE_SCENE: PackedScene = preload("res://scenes/shooter_projectile.tscn")
const IDLE_ANIMATION: StringName = &"idle"
const CHARGE_ANIMATION: StringName = &"charge"
const FIRE_ANIMATION: StringName = &"fire"
const DEFEAT_ANIMATION: StringName = &"defeat"
const GRAVITY: float = 1500.0
const MAX_FALL_SPEED: float = 900.0
const FIRE_ANIMATION_LOCK: float = 0.29
const CHARGE_LEAD_TIME: float = 0.55
const MUZZLE_OFFSET: Vector2 = Vector2(34.0, -14.0)
const TARGET_AIM_OFFSET: Vector2 = Vector2(0.0, -10.0)

@export_category("Shooting")
@export_range(40.0, 1200.0, 10.0, "or_greater") var detection_range: float = 420.0:
	set(value):
		detection_range = maxf(value, 1.0)
		_queue_detection_sync()
@export_range(8.0, 300.0, 2.0, "or_greater") var vertical_fire_tolerance: float = 72.0:
	set(value):
		vertical_fire_tolerance = maxf(value, 1.0)
		_queue_detection_sync()
@export_range(0.2, 10.0, 0.1, "or_greater") var fire_interval: float = 2.0:
	set(value):
		fire_interval = maxf(value, 0.05)
		var timer := get_node_or_null("FireTimer") as Timer
		if timer != null:
			timer.wait_time = fire_interval
			if not timer.is_stopped():
				timer.start(fire_interval)

@export_category("Combat")
@export_range(0, 5000, 10) var points: int = 450
@export_range(0.0, 600.0, 10.0) var stomp_min_fall_speed: float = 80.0
@export_range(0.0, 32.0, 1.0) var stomp_height_margin: float = 8.0
@export_range(0.0, 1000.0, 10.0) var stomp_bounce_speed: float = 460.0

@onready var _hitbox: Area2D = $Hitbox
@onready var _detection_area: Area2D = $DetectionArea
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _muzzle: Marker2D = $Muzzle
@onready var _fire_timer: Timer = $FireTimer

var _target: CharacterBody2D
var _facing_direction: float = 1.0
var _fire_animation_remaining: float = 0.0
var _is_defeated: bool = false
var _detection_sync_queued: bool = false


func _ready() -> void:
	_sync_detection_geometry()
	if Engine.is_editor_hint():
		set_physics_process(false)
		queue_redraw()
		return

	_hitbox.body_entered.connect(_on_hitbox_body_entered)
	_detection_area.body_entered.connect(_on_detection_body_entered)
	_detection_area.body_exited.connect(_on_detection_body_exited)
	_fire_timer.timeout.connect(_on_fire_timer_timeout)
	_fire_timer.wait_time = fire_interval
	_update_facing_visuals()
	_sprite.play(IDLE_ANIMATION)


func _physics_process(delta: float) -> void:
	velocity.x = 0.0
	if not is_on_floor():
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)
	else:
		velocity.y = 0.0
	move_and_slide()

	_refresh_target()
	if _target == null:
		_update_combat_animation(delta, false)
		return
	_aim_at_target()
	_update_combat_animation(delta, true)


func _refresh_target() -> void:
	if _is_target_ready(_target) and _is_target_in_fire_lane(_target):
		_start_fire_cycle()
		return

	_target = null
	var nearest_distance: float = INF
	for body: Node2D in _detection_area.get_overlapping_bodies():
		var candidate := body as CharacterBody2D
		if not _is_target_ready(candidate) or not _is_target_in_fire_lane(candidate):
			continue
		var distance: float = global_position.distance_squared_to(candidate.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			_target = candidate

	if _target == null:
		_fire_timer.stop()
	else:
		_start_fire_cycle()


func _is_target_ready(candidate: CharacterBody2D) -> bool:
	if not is_instance_valid(candidate) or not candidate.has_method("die"):
		return false
	if candidate.has_method("is_dead") and bool(candidate.call("is_dead")):
		return false
	return true


func _is_target_in_fire_lane(candidate: CharacterBody2D) -> bool:
	var local_target_position: Vector2 = to_local(candidate.global_position)
	return (
		absf(local_target_position.x) <= detection_range
		and absf(local_target_position.y) <= vertical_fire_tolerance
	)


func _start_fire_cycle() -> void:
	if _fire_timer.is_stopped():
		_fire_timer.start(fire_interval)


func _aim_at_target() -> void:
	if not is_instance_valid(_target):
		return
	var horizontal_delta: float = _target.global_position.x - global_position.x
	if absf(horizontal_delta) > 1.0:
		_facing_direction = signf(horizontal_delta)
	_update_facing_visuals()


func _update_facing_visuals() -> void:
	_sprite.flip_h = _facing_direction < 0.0
	_muzzle.position = Vector2(
		absf(MUZZLE_OFFSET.x) * _facing_direction,
		MUZZLE_OFFSET.y
	)


func _update_combat_animation(delta: float, has_target: bool) -> void:
	if _fire_animation_remaining > 0.0:
		_fire_animation_remaining = maxf(_fire_animation_remaining - delta, 0.0)
		if _fire_animation_remaining > 0.0:
			return

	if not has_target or _fire_timer.is_stopped():
		_play_animation(IDLE_ANIMATION)
		return
	var charge_window: float = minf(CHARGE_LEAD_TIME, fire_interval * 0.5)
	if _fire_timer.time_left <= charge_window:
		_play_animation(CHARGE_ANIMATION)
	else:
		_play_animation(IDLE_ANIMATION)


func _on_fire_timer_timeout() -> void:
	if _is_defeated:
		return
	_refresh_target()
	if _target == null:
		return
	_aim_at_target()
	_fire_projectile()


func _fire_projectile() -> void:
	if not _is_target_ready(_target):
		return
	var projectile := PROJECTILE_SCENE.instantiate() as ShooterProjectile
	var projectile_parent: Node = get_parent()
	if projectile == null or projectile_parent == null:
		if projectile != null:
			projectile.queue_free()
		return
	projectile_parent.add_child(projectile)
	projectile.global_position = _muzzle.global_position
	var target_position: Vector2 = _target.global_position + TARGET_AIM_OFFSET
	var aim_direction: Vector2 = projectile.global_position.direction_to(target_position)
	if aim_direction.is_zero_approx():
		aim_direction = Vector2(_facing_direction, 0.0)
	projectile.launch_vector(aim_direction)
	projectile_fired.emit(projectile)
	_sprite.play(FIRE_ANIMATION)
	_fire_animation_remaining = FIRE_ANIMATION_LOCK


func _on_detection_body_entered(body: Node2D) -> void:
	var candidate := body as CharacterBody2D
	if not _is_target_ready(candidate) or not _is_target_in_fire_lane(candidate):
		return
	_target = candidate
	_aim_at_target()
	_start_fire_cycle()


func _on_detection_body_exited(body: Node2D) -> void:
	if body != _target:
		return
	_target = null
	_fire_timer.stop()


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
	_target = null
	_fire_timer.stop()
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
	tween.tween_interval(0.36)
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y + 18.0, 0.20)
	tween.tween_property(self, "modulate:a", 0.0, 0.20)
	tween.set_parallel(false)
	tween.tween_callback(queue_free)


func _play_animation(animation_name: StringName) -> void:
	if _sprite.animation != animation_name:
		_sprite.play(animation_name)


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	var guide_rect := Rect2(
		Vector2(-detection_range, -vertical_fire_tolerance),
		Vector2(detection_range * 2.0, vertical_fire_tolerance * 2.0)
	)
	draw_rect(guide_rect, Color(0.2, 0.85, 1.0, 0.08), true)
	draw_rect(guide_rect, Color(0.2, 0.85, 1.0, 0.72), false, 1.0)
	draw_line(
		Vector2(-detection_range, MUZZLE_OFFSET.y),
		Vector2(detection_range, MUZZLE_OFFSET.y),
		Color(1.0, 0.62, 0.18, 0.65),
		1.0
	)
	draw_circle(MUZZLE_OFFSET, 4.0, Color(1.0, 0.62, 0.18, 0.9))
	draw_circle(
		Vector2(-MUZZLE_OFFSET.x, MUZZLE_OFFSET.y),
		4.0,
		Color(1.0, 0.62, 0.18, 0.9)
	)


func _queue_detection_sync() -> void:
	if not is_inside_tree() or _detection_sync_queued:
		return
	_detection_sync_queued = true
	call_deferred("_sync_detection_geometry")


func _sync_detection_geometry() -> void:
	_detection_sync_queued = false
	var collision := get_node_or_null(
		"DetectionArea/CollisionShape2D"
	) as CollisionShape2D
	if collision != null:
		var rectangle := collision.shape as RectangleShape2D
		if rectangle != null:
			rectangle.size = Vector2(
				detection_range * 2.0,
				vertical_fire_tolerance * 2.0
			)
	queue_redraw()
