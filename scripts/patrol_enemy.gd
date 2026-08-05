extends CharacterBody2D

signal defeated(points: int)

@export_range(10.0, 300.0, 1.0) var speed: float = 62.0
@export_range(20.0, 600.0, 5.0) var patrol_distance: float = 115.0
@export_range(0, 5000, 10) var points: int = 250

const GRAVITY: float = 1500.0
const MAX_FALL_SPEED: float = 900.0

@onready var floor_ray: RayCast2D = $FloorRayCast
@onready var hitbox: Area2D = $Hitbox
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _spawn_x: float
var _direction: float = -1.0
var _is_defeated: bool = false


func _ready() -> void:
	_spawn_x = position.x
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	_sprite.flip_h = _direction < 0.0
	_sprite.play(&"walk")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)

	velocity.x = _direction * speed
	floor_ray.target_position.x = _direction * 22.0
	move_and_slide()

	var reached_patrol_edge: bool = (
		absf(position.x - _spawn_x) >= patrol_distance
		and signf(position.x - _spawn_x) == _direction
	)
	if is_on_wall() or reached_patrol_edge or (is_on_floor() and not floor_ray.is_colliding()):
		_turn_around()


func _turn_around() -> void:
	_direction *= -1.0
	_sprite.flip_h = _direction < 0.0


func _on_hitbox_body_entered(body: Node2D) -> void:
	if _is_defeated or not body.has_method("die"):
		return

	var character: CharacterBody2D = body as CharacterBody2D
	if character == null:
		return

	var is_stomp: bool = (
		character.velocity.y > 80.0
		and character.global_position.y < global_position.y - 8.0
	)
	if is_stomp and body.has_method("bounce"):
		body.call("bounce")
		_be_defeated()
	else:
		body.call("die")


func _be_defeated() -> void:
	_is_defeated = true
	GameAudio.play_sound(&"enemy_stomp", -4.0, 0.95, 1.04)
	velocity = Vector2.ZERO
	collision_layer = 0
	hitbox.set_deferred("monitoring", false)
	set_physics_process(false)
	defeated.emit(points)
	_sprite.play(&"defeat")

	var tween: Tween = create_tween()
	tween.tween_interval(0.20)
	tween.tween_property(self, "modulate:a", 0.0, 0.14)
	tween.tween_callback(queue_free)
