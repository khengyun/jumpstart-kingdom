extends CharacterBody2D
class_name Player

signal died

const MOVE_LEFT_ACTION: StringName = &"move_left"
const MOVE_RIGHT_ACTION: StringName = &"move_right"
const JUMP_ACTION: StringName = &"jump"

const BODY_COLOR: Color = Color("#35c7b3")
const BODY_SHADOW_COLOR: Color = Color("#187f83")
const VISOR_COLOR: Color = Color("#16384f")
const VISOR_HIGHLIGHT_COLOR: Color = Color("#b9f5ed")
const ACCENT_COLOR: Color = Color("#ffb84a")
const OUTLINE_COLOR: Color = Color("#102c3a")

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

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _facing_direction: float = 1.0
var _is_dead: bool = false


func _ready() -> void:
	if initialize_spawn_from_scene:
		spawn_position = global_position
	queue_redraw()


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	_update_jump_windows(delta)
	_apply_horizontal_movement(delta)
	_apply_gravity(delta)
	_consume_buffered_jump()
	_apply_variable_jump_cut()

	move_and_slide()

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
			queue_redraw()

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
	set_physics_process(false)
	queue_redraw()
	died.emit()


## Restores the player at [member spawn_position] and re-enables movement.
func respawn() -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0
	_is_dead = false
	set_physics_process(true)
	queue_redraw()


func set_spawn_position(new_spawn_position: Vector2) -> void:
	spawn_position = new_spawn_position


func is_dead() -> bool:
	return _is_dead


func _draw() -> void:
	var facing: float = _facing_direction

	# Backpack, scarf, and feet are drawn first so the body overlaps them.
	draw_rect(Rect2(-facing * 10.0 - 4.0, -5.0, 7.0, 14.0), BODY_SHADOW_COLOR)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-facing * 8.0, -2.0),
			Vector2(-facing * 18.0, 1.0),
			Vector2(-facing * 9.0, 5.0),
		]),
		ACCENT_COLOR
	)
	draw_rect(Rect2(-9.0, 9.0, 7.0, 6.0), BODY_SHADOW_COLOR)
	draw_rect(Rect2(2.0, 9.0, 7.0, 6.0), BODY_SHADOW_COLOR)

	# Rounded teal explorer body with a directional glass visor.
	draw_circle(Vector2(0.0, -4.0), 11.0, OUTLINE_COLOR)
	draw_rect(Rect2(-11.0, -4.0, 22.0, 13.0), OUTLINE_COLOR)
	draw_circle(Vector2(0.0, -4.0), 9.5, BODY_COLOR)
	draw_rect(Rect2(-9.5, -4.0, 19.0, 12.0), BODY_COLOR)
	draw_circle(Vector2(facing * 2.5, -6.0), 6.0, VISOR_COLOR)
	draw_circle(Vector2(facing * 4.0, -8.0), 1.7, VISOR_HIGHLIGHT_COLOR)

	# Antenna and chest badge keep the placeholder readable at small sizes.
	draw_line(Vector2(0.0, -14.0), Vector2(facing * 3.0, -19.0), OUTLINE_COLOR, 2.0)
	draw_circle(Vector2(facing * 3.0, -20.0), 2.5, ACCENT_COLOR)
	draw_circle(Vector2(facing * 4.0, 4.0), 2.0, ACCENT_COLOR)

	if _is_dead:
		draw_line(Vector2(-4.0, -9.0), Vector2(4.0, -3.0), ACCENT_COLOR, 2.0)
		draw_line(Vector2(4.0, -9.0), Vector2(-4.0, -3.0), ACCENT_COLOR, 2.0)
