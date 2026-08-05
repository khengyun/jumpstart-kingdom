@tool
extends AnimatableBody2D
class_name MovingPlatform

const PLATFORM_SIZE: Vector2 = Vector2(160.0, 24.0)
const GUIDE_COLOR: Color = Color(0.2, 0.85, 1.0, 0.78)
const ENDPOINT_COLOR: Color = Color(0.2, 0.85, 1.0, 0.42)
const DIRECTION_COLOR: Color = Color(1.0, 0.62, 0.18, 0.9)
const LEFT_ANIMATION: StringName = &"left"
const RIGHT_ANIMATION: StringName = &"right"

## Maximum horizontal distance from the placed center position to either endpoint.
@export_range(0.0, 1200.0, 5.0, "or_greater") var travel_distance: float = 160.0:
	set(value):
		travel_distance = maxf(value, 0.0)
		_queue_editor_redraw()

## Horizontal movement speed in pixels per second. Set to zero to keep the platform still.
@export_range(0.0, 600.0, 1.0, "or_greater") var speed: float = 80.0

## Direction used when the platform first starts moving from its center position.
@export_enum("Left:-1", "Right:1") var initial_direction: int = 1:
	set(value):
		initial_direction = -1 if value < 0 else 1
		_queue_editor_redraw()

var _center_position: Vector2
var _direction: float = 1.0

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_direction = -1.0 if initial_direction < 0 else 1.0
	_play_direction_animation()
	if Engine.is_editor_hint():
		set_physics_process(false)
		queue_redraw()
		return

	_center_position = position


func _physics_process(delta: float) -> void:
	if is_zero_approx(speed) or is_zero_approx(travel_distance):
		return

	var offset_x: float = position.x - _center_position.x
	var next_offset_x: float = offset_x + _direction * speed * delta
	if next_offset_x <= -travel_distance:
		next_offset_x = -travel_distance
		_direction = 1.0
		_play_direction_animation()
	elif next_offset_x >= travel_distance:
		next_offset_x = travel_distance
		_direction = -1.0
		_play_direction_animation()

	position = Vector2(_center_position.x + next_offset_x, _center_position.y)

func _play_direction_animation() -> void:
	if not is_instance_valid(_sprite):
		return
	_sprite.play(LEFT_ANIMATION if _direction < 0.0 else RIGHT_ANIMATION)


func _draw() -> void:
	if not Engine.is_editor_hint():
		return

	var half_size: Vector2 = PLATFORM_SIZE * 0.5
	var guide_y: float = half_size.y + 12.0
	var left_point := Vector2(-travel_distance, guide_y)
	var right_point := Vector2(travel_distance, guide_y)
	draw_line(left_point, right_point, GUIDE_COLOR, 2.0)
	draw_line(left_point + Vector2(0.0, -7.0), left_point + Vector2(0.0, 7.0), GUIDE_COLOR, 2.0)
	draw_line(
		right_point + Vector2(0.0, -7.0),
		right_point + Vector2(0.0, 7.0),
		GUIDE_COLOR,
		2.0
	)
	draw_circle(Vector2(0.0, guide_y), 3.0, GUIDE_COLOR)

	var endpoint_outline_size := Vector2(PLATFORM_SIZE.x, PLATFORM_SIZE.y)
	for endpoint_x: float in [-travel_distance, travel_distance]:
		draw_rect(
			Rect2(Vector2(endpoint_x, 0.0) - half_size, endpoint_outline_size),
			ENDPOINT_COLOR,
			false,
			1.0
		)

	var direction_sign: float = -1.0 if initial_direction < 0 else 1.0
	var arrow_tip := Vector2(direction_sign * 22.0, guide_y)
	draw_line(Vector2(0.0, guide_y), arrow_tip, DIRECTION_COLOR, 2.0)
	draw_line(
		arrow_tip,
		arrow_tip + Vector2(-direction_sign * 7.0, -5.0),
		DIRECTION_COLOR,
		2.0
	)
	draw_line(
		arrow_tip,
		arrow_tip + Vector2(-direction_sign * 7.0, 5.0),
		DIRECTION_COLOR,
		2.0
	)


func _queue_editor_redraw() -> void:
	if Engine.is_editor_hint() and is_inside_tree():
		queue_redraw()
