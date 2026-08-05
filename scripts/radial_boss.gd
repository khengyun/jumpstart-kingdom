@tool
extends CharacterBody2D
class_name RadialBoss

signal defeated(points: int)
signal health_changed(remaining_hits: int, maximum_hits: int)
signal volley_fired(projectile_count: int)

enum State {
	DORMANT,
	ACTIVE,
	TELEGRAPHING,
	HURT,
	DEFEATED,
}

const PROJECTILE_SCENE: PackedScene = preload("res://scenes/shooter_projectile.tscn")
const BODY_CENTER := Vector2(0.0, -62.0)
const IDLE_ANIMATION: StringName = &"idle"
const ATTACK_ANIMATION: StringName = &"attack"
const HURT_ANIMATION: StringName = &"hurt"
const DEFEAT_ANIMATION: StringName = &"defeat"

@export_category("Arena Activation")
@export_range(160.0, 900.0, 10.0) var activation_radius: float = 520.0:
	set(value):
		activation_radius = value
		_queue_editor_sync()

@export_category("Boss Health")
@export_range(1, 8, 1) var stomp_hits_required: int = 3
@export_range(0, 20000, 100) var points: int = 5000
@export_range(0.0, 600.0, 10.0) var stomp_min_fall_speed: float = 90.0
@export_range(0.0, 48.0, 1.0) var stomp_height_margin: float = 12.0
@export_range(0.0, 1000.0, 10.0) var stomp_bounce_speed: float = 520.0
@export_range(0.1, 2.0, 0.05) var hurt_seconds: float = 0.65

@export_category("Radial Volley")
@export_range(4, 24, 1) var bullets_per_volley: int = 16:
	set(value):
		bullets_per_volley = clampi(value, 4, 24)
		_queue_editor_sync()
@export_range(1, 4, 1) var gap_count: int = 2:
	set(value):
		gap_count = clampi(value, 1, 4)
		_queue_editor_sync()
@export_range(5.0, 60.0, 1.0) var gap_half_angle_degrees: float = 28.0:
	set(value):
		gap_half_angle_degrees = value
		_queue_editor_sync()
@export_range(0.0, 360.0, 1.0) var initial_volley_angle_degrees: float = 0.0:
	set(value):
		initial_volley_angle_degrees = value
		_queue_editor_sync()
@export_range(0.0, 90.0, 0.25) var rotation_per_volley_degrees: float = 11.25
@export_range(0.1, 2.0, 0.05) var telegraph_seconds: float = 0.40
@export_range(0.6, 4.0, 0.05) var volley_interval: float = 1.25
@export_range(60.0, 420.0, 5.0) var bullet_speed: float = 180.0
@export_range(0.5, 5.0, 0.1) var bullet_lifetime: float = 3.2
@export_range(32.0, 96.0, 1.0) var projectile_spawn_radius: float = 62.0
@export_range(12, 96, 1) var max_active_bullets: int = 72

@export_category("Hover")
@export_range(0.0, 40.0, 1.0) var hover_amplitude: float = 12.0
@export_range(0.0, 3.0, 0.05) var hover_frequency: float = 0.7
@export_range(0.0, 360.0, 1.0) var hover_phase_degrees: float = 0.0

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _hitbox: Area2D = $Hitbox
@onready var _activation_area: Area2D = $ActivationArea
@onready var _volley_timer: Timer = $VolleyTimer
@onready var _telegraph_timer: Timer = $TelegraphTimer
@onready var _hurt_timer: Timer = $HurtTimer

var _state: State = State.DORMANT
var _remaining_hits: int = 3
var _spawn_position: Vector2
var _elapsed: float = 0.0
var _volley_index: int = 0
var _target: CharacterBody2D
var _projectiles: Array[ShooterProjectile] = []
var _editor_sync_queued: bool = false


func _ready() -> void:
	_sync_editor_geometry()
	if Engine.is_editor_hint():
		set_physics_process(false)
		queue_redraw()
		return

	_spawn_position = position
	_remaining_hits = stomp_hits_required
	_hitbox.body_entered.connect(_on_hitbox_body_entered)
	_activation_area.body_entered.connect(_on_activation_body_entered)
	_activation_area.body_exited.connect(_on_activation_body_exited)
	_volley_timer.timeout.connect(_begin_telegraph)
	_telegraph_timer.timeout.connect(_fire_radial_volley)
	_hurt_timer.timeout.connect(_finish_hurt)
	_sprite.play(IDLE_ANIMATION)
	health_changed.emit(_remaining_hits, stomp_hits_required)


func _physics_process(delta: float) -> void:
	if _state == State.DEFEATED:
		return
	_elapsed += delta
	var phase: float = deg_to_rad(hover_phase_degrees)
	position.y = (
		_spawn_position.y
		+ sin(phase + _elapsed * TAU * hover_frequency) * hover_amplitude
	)
	if not _is_target_ready(_target):
		_refresh_target()


func get_remaining_hits() -> int:
	return _remaining_hits


func get_state() -> State:
	return _state


func get_active_projectile_count() -> int:
	_purge_invalid_projectiles()
	return _projectiles.size()


func _on_activation_body_entered(body: Node2D) -> void:
	var candidate := body as CharacterBody2D
	if _is_target_ready(candidate):
		_set_target(candidate)


func _on_activation_body_exited(body: Node2D) -> void:
	if body == _target:
		_clear_target()


func _set_target(candidate: CharacterBody2D) -> void:
	if candidate == _target or not _is_target_ready(candidate):
		return
	_disconnect_target_signal()
	_target = candidate
	if _target.has_signal(&"died") and not _target.is_connected(&"died", _on_target_died):
		_target.connect(&"died", _on_target_died)
	if _state == State.DORMANT:
		_state = State.ACTIVE
		_sprite.play(IDLE_ANIMATION)
		_volley_timer.start(minf(volley_interval, 0.8))


func _clear_target() -> void:
	_disconnect_target_signal()
	_target = null
	if _state != State.HURT and _state != State.DEFEATED:
		_state = State.DORMANT
		_volley_timer.stop()
		_telegraph_timer.stop()
		_sprite.play(IDLE_ANIMATION)
	_clear_projectiles()


func _disconnect_target_signal() -> void:
	if (
		is_instance_valid(_target)
		and _target.has_signal(&"died")
		and _target.is_connected(&"died", _on_target_died)
	):
		_target.disconnect(&"died", _on_target_died)


func _on_target_died() -> void:
	_clear_target()


func _refresh_target() -> void:
	if _state == State.DEFEATED:
		return
	for body: Node2D in _activation_area.get_overlapping_bodies():
		var candidate := body as CharacterBody2D
		if _is_target_ready(candidate):
			_set_target(candidate)
			return
	if _target != null:
		_clear_target()


func _is_target_ready(candidate: CharacterBody2D) -> bool:
	if not is_instance_valid(candidate) or not candidate.has_method("die"):
		return false
	if candidate.has_method("is_dead") and bool(candidate.call("is_dead")):
		return false
	return true


func _begin_telegraph() -> void:
	if _state != State.ACTIVE or not _is_target_ready(_target):
		return
	_state = State.TELEGRAPHING
	_sprite.play(ATTACK_ANIMATION)
	_telegraph_timer.start(telegraph_seconds)


func _fire_radial_volley() -> void:
	if _state != State.TELEGRAPHING or not _is_target_ready(_target):
		return
	_purge_invalid_projectiles()
	var phase := deg_to_rad(
		initial_volley_angle_degrees
		+ float(_volley_index) * rotation_per_volley_degrees
	)
	var spawned_count: int = 0
	for index: int in bullets_per_volley:
		if _projectiles.size() >= max_active_bullets:
			break
		var angle: float = phase + TAU * float(index) / float(bullets_per_volley)
		if _angle_is_in_safe_gap(angle, phase):
			continue
		if _spawn_projectile(Vector2.from_angle(angle)):
			spawned_count += 1
	_volley_index += 1
	if spawned_count > 0:
		GameAudio.play_sound(&"enemy_stomp", -10.0, 1.10, 1.18)
		volley_fired.emit(spawned_count)
	_state = State.ACTIVE
	_sprite.play(IDLE_ANIMATION)
	var lost_hits: int = stomp_hits_required - _remaining_hits
	_volley_timer.start(maxf(0.65, volley_interval - float(lost_hits) * 0.10))


func _angle_is_in_safe_gap(angle: float, phase: float) -> bool:
	var half_angle := deg_to_rad(gap_half_angle_degrees)
	for gap_index: int in gap_count:
		var gap_angle: float = phase + TAU * float(gap_index) / float(gap_count)
		if absf(wrapf(angle - gap_angle, -PI, PI)) <= half_angle:
			return true
	return false


func _spawn_projectile(direction: Vector2) -> bool:
	var projectile := PROJECTILE_SCENE.instantiate() as ShooterProjectile
	var projectile_parent: Node = get_parent()
	if projectile == null or projectile_parent == null:
		if projectile != null:
			projectile.queue_free()
		return false
	projectile_parent.add_child(projectile)
	projectile.global_position = global_position + BODY_CENTER + direction * projectile_spawn_radius
	var lost_hits: int = stomp_hits_required - _remaining_hits
	projectile.launch_vector(
		direction,
		bullet_speed + float(lost_hits) * 15.0,
		bullet_lifetime
	)
	projectile.despawned.connect(_on_projectile_despawned.bind(projectile))
	_projectiles.append(projectile)
	return true


func _on_projectile_despawned(_reason: StringName, projectile: ShooterProjectile) -> void:
	_projectiles.erase(projectile)


func _purge_invalid_projectiles() -> void:
	for index: int in range(_projectiles.size() - 1, -1, -1):
		if not is_instance_valid(_projectiles[index]):
			_projectiles.remove_at(index)


func _clear_projectiles() -> void:
	var active_projectiles: Array[ShooterProjectile] = _projectiles.duplicate()
	_projectiles.clear()
	for projectile: ShooterProjectile in active_projectiles:
		if is_instance_valid(projectile):
			projectile.despawn(&"owner_cleanup")


func _on_hitbox_body_entered(body: Node2D) -> void:
	if _state == State.HURT or _state == State.DEFEATED or not body.has_method("die"):
		return
	var character := body as CharacterBody2D
	if character == null:
		return
	var is_stomp: bool = (
		character.velocity.y - velocity.y > stomp_min_fall_speed
		and character.global_position.y
		< global_position.y + BODY_CENTER.y - stomp_height_margin
	)
	if is_stomp and body.has_method("bounce"):
		body.call("bounce", stomp_bounce_speed)
		_take_stomp_hit()
	else:
		body.call("die")


func _take_stomp_hit() -> void:
	_remaining_hits = maxi(_remaining_hits - 1, 0)
	health_changed.emit(_remaining_hits, stomp_hits_required)
	GameAudio.play_sound(&"enemy_stomp", -2.0, 0.78, 0.88)
	_volley_timer.stop()
	_telegraph_timer.stop()
	_clear_projectiles()
	if _remaining_hits <= 0:
		_be_defeated()
		return
	_state = State.HURT
	_hitbox.set_deferred("monitoring", false)
	_sprite.play(HURT_ANIMATION)
	_hurt_timer.start(hurt_seconds)


func _finish_hurt() -> void:
	if _state != State.HURT:
		return
	_hitbox.set_deferred("monitoring", true)
	_sprite.play(IDLE_ANIMATION)
	if _is_target_ready(_target):
		_state = State.ACTIVE
		_volley_timer.start(minf(volley_interval, 0.8))
	else:
		_state = State.DORMANT
		_refresh_target()


func _be_defeated() -> void:
	if _state == State.DEFEATED:
		return
	_state = State.DEFEATED
	_volley_timer.stop()
	_telegraph_timer.stop()
	_hurt_timer.stop()
	_clear_projectiles()
	_disconnect_target_signal()
	_target = null
	remove_from_group(&"level_boss")
	collision_layer = 0
	collision_mask = 0
	_hitbox.set_deferred("monitoring", false)
	_activation_area.set_deferred("monitoring", false)
	set_physics_process(false)
	_sprite.play(DEFEAT_ANIMATION)
	defeated.emit(points)
	var tween := create_tween()
	tween.tween_interval(0.64)
	tween.tween_property(self, "modulate:a", 0.0, 0.22)
	tween.tween_callback(queue_free)


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	draw_circle(BODY_CENTER, activation_radius, Color(0.2, 0.85, 1.0, 0.08), true)
	draw_circle(BODY_CENTER, activation_radius, Color(0.2, 0.85, 1.0, 0.62), false, 1.0)
	var phase := deg_to_rad(initial_volley_angle_degrees)
	for index: int in bullets_per_volley:
		var angle: float = phase + TAU * float(index) / float(bullets_per_volley)
		if _angle_is_in_safe_gap(angle, phase):
			continue
		var direction := Vector2.from_angle(angle)
		draw_line(
			BODY_CENTER + direction * projectile_spawn_radius,
			BODY_CENTER + direction * (projectile_spawn_radius + 48.0),
			Color(1.0, 0.55, 0.13, 0.68),
			1.0
		)


func _queue_editor_sync() -> void:
	if not is_inside_tree() or _editor_sync_queued:
		return
	_editor_sync_queued = true
	call_deferred("_sync_editor_geometry")


func _sync_editor_geometry() -> void:
	_editor_sync_queued = false
	var activation_collision := get_node_or_null(
		"ActivationArea/CollisionShape2D"
	) as CollisionShape2D
	if activation_collision != null:
		var circle := activation_collision.shape as CircleShape2D
		if circle != null:
			circle.radius = activation_radius
	queue_redraw()
