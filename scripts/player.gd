extends CharacterBody2D
class_name Player

signal died

const MOVE_LEFT_ACTION: StringName = &"move_left"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const JUMP_ACTION: StringName = &"jump"

const IDLE_ANIMATION: StringName = &"idle"
const RUN_ANIMATION: StringName = &"run"
const JUMP_ANIMATION: StringName = &"jump"
const FALL_ANIMATION: StringName = &"fall"
const DEATH_ANIMATION: StringName = &"death"
const RUN_ANIMATION_THRESHOLD: float = 10.0
const FALL_ANIMATION_THRESHOLD: float = 20.0

@export_category("Horizontal Movement")
@export_range(0.0, 1000.0, 1.0) var max_speed: float = 220.0
@export_range(0.0, 5000.0, 10.0) var ground_acceleration: float = 1800.0
@export_range(0.0, 5000.0, 10.0) var ground_deceleration: float = 2200.0
@export_range(0.0, 5000.0, 10.0) var air_acceleration: float = 1050.0
@export_range(0.0, 5000.0, 10.0) var air_deceleration: float = 420.0

@export_category("Jump")
@export_range(0.0, 2000.0, 5.0) var jump_speed: float = 600.0
@export_range(0.0, 2000.0, 5.0) var stomp_bounce_speed: float = 400.0
@export_range(0.0, 5000.0, 10.0) var gravity: float = 1500.0
@export_range(0.0, 3000.0, 5.0) var terminal_velocity: float = 900.0
@export_range(0.0, 1.0, 0.01) var jump_cut_ratio: float = 0.42
@export_range(0.0, 0.5, 0.01) var coyote_time: float = 0.12
@export_range(0.0, 0.5, 0.01) var jump_buffer_time: float = 0.12

@export_category("Respawn")
@export var initialize_spawn_from_scene: bool = true
@export var spawn_position: Vector2 = Vector2.ZERO
@export var death_y: float = 2000.0

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _facing_direction: float = 1.0
var _is_dead: bool = false


func _ready() -> void:
	if initialize_spawn_from_scene:
		spawn_position = global_position
	_sprite.play(IDLE_ANIMATION)


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_update_jump_windows(delta)
	_apply_horizontal_movement(delta)
	_apply_gravity(delta)
	_consume_buffered_jump()
	_apply_variable_jump_cut()

	move_and_slide()
	_update_animation()

	if global_position.y >= death_y:
		die()


func _update_jump_windows(delta: float) -> void:
	if is_on_floor():
		_coyote_timer = coyote_time
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed(JUMP_ACTION):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)


func _apply_horizontal_movement(delta: float) -> void:
	var input_axis: float = Input.get_axis(MOVE_LEFT_ACTION, MOVE_RIGHT_ACTION)
	var target_speed: float = input_axis * max_speed
	var acceleration: float

	if is_zero_approx(input_axis):
		acceleration = ground_deceleration if is_on_floor() else air_deceleration
	else:
		acceleration = ground_acceleration if is_on_floor() else air_acceleration
		var next_facing_direction: float = signf(input_axis)
		if not is_equal_approx(next_facing_direction, _facing_direction):
			_facing_direction = next_facing_direction

	velocity.x = move_toward(velocity.x, target_speed, acceleration * delta)


func _apply_gravity(delta: float) -> void:
	if is_on_floor() and velocity.y >= 0.0:
		return
	velocity.y = minf(velocity.y + gravity * delta, terminal_velocity)


func _consume_buffered_jump() -> void:
	if _jump_buffer_timer <= 0.0 or _coyote_timer <= 0.0:
		return

	velocity.y = -jump_speed
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0


func _apply_variable_jump_cut() -> void:
	if Input.is_action_just_released(JUMP_ACTION) and velocity.y < 0.0:
		velocity.y = maxf(velocity.y, -jump_speed * jump_cut_ratio)


## Gives the player an upward impulse after stomping an enemy or spring.
## Passing zero uses [member stomp_bounce_speed].
func bounce(strength: float = 0.0) -> void:
	if _is_dead:
		return

	var bounce_strength: float = strength if strength > 0.0 else stomp_bounce_speed
	velocity.y = -bounce_strength
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0


## Enters the dead state and emits [signal died] once. Call [method respawn] to reset.
func die() -> void:
	if _is_dead:
		return

	_is_dead = true
	velocity = Vector2.ZERO
	_play_animation(DEATH_ANIMATION, true)
	set_physics_process(false)
	died.emit()


## Restores the player at [member spawn_position] and re-enables movement.
func respawn() -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0
	_is_dead = false
	set_physics_process(true)
	_sprite.flip_h = _facing_direction < 0.0
	_play_animation(IDLE_ANIMATION, true)


func set_spawn_position(new_spawn_position: Vector2) -> void:
	spawn_position = new_spawn_position


func is_dead() -> bool:
	return _is_dead


func freeze_for_finish() -> void:
	velocity = Vector2.ZERO
	set_physics_process(false)
	_play_animation(IDLE_ANIMATION, true)


func _update_animation() -> void:
	_sprite.flip_h = _facing_direction < 0.0

	if not is_on_floor():
		var airborne_animation: StringName = (
			JUMP_ANIMATION if velocity.y < FALL_ANIMATION_THRESHOLD else FALL_ANIMATION
		)
		_play_animation(airborne_animation)
	elif absf(velocity.x) >= RUN_ANIMATION_THRESHOLD:
		_play_animation(RUN_ANIMATION)
	else:
		_play_animation(IDLE_ANIMATION)


func _play_animation(animation_name: StringName, restart: bool = false) -> void:
	if restart or _sprite.animation != animation_name:
		_sprite.play(animation_name)
