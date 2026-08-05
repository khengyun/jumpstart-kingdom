extends Area2D
class_name ShooterProjectile

signal despawned(reason: StringName)

const FLY_ANIMATION: StringName = &"fly"

@export_range(20.0, 1200.0, 10.0, "or_greater") var speed: float = 420.0
@export_range(0.1, 10.0, 0.1, "or_greater") var lifetime: float = 3.0

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

var _direction: Vector2 = Vector2.RIGHT
var _age: float = 0.0
var _is_despawning: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_apply_direction()
	_sprite.play(FLY_ANIMATION)


func launch(direction: float) -> void:
	launch_vector(Vector2.LEFT if direction < 0.0 else Vector2.RIGHT)


func launch_vector(
	direction: Vector2,
	speed_override: float = -1.0,
	lifetime_override: float = -1.0
) -> void:
	_direction = direction.normalized() if not direction.is_zero_approx() else Vector2.RIGHT
	if speed_override >= 0.0:
		speed = speed_override
	if lifetime_override >= 0.0:
		lifetime = maxf(lifetime_override, 0.01)
	_age = 0.0
	_apply_direction()


func _physics_process(delta: float) -> void:
	global_position += _direction * speed * delta
	_age += delta
	if _age >= lifetime:
		despawn(&"lifetime")


func _on_body_entered(body: Node2D) -> void:
	if _is_despawning:
		return
	if body.has_method("die"):
		body.call("die")
		despawn(&"player")
		return
	despawn(&"world")


func _apply_direction() -> void:
	rotation = _direction.angle()
	if is_instance_valid(_sprite):
		_sprite.flip_h = false


func despawn(reason: StringName) -> void:
	if _is_despawning:
		return
	_is_despawning = true
	set_physics_process(false)
	set_deferred("monitoring", false)
	despawned.emit(reason)
	queue_free()
