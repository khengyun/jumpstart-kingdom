extends Node2D

const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const COIN_SCENE: PackedScene = preload("res://scenes/coin.tscn")
const ENEMY_SCENE: PackedScene = preload("res://scenes/patrol_enemy.tscn")
const GOAL_SCENE: PackedScene = preload("res://scenes/goal.tscn")

const VIEWPORT_SIZE := Vector2(960.0, 540.0)
const LEVEL_LEFT: float = 0.0
const LEVEL_RIGHT: float = 3400.0
const FLOOR_Y: float = 460.0
const START_POSITION := Vector2(135.0, 410.0)

@onready var level: Node2D = $World/Level
@onready var actors: Node2D = $World/Actors
@onready var pickups: Node2D = $World/Pickups
@onready var gameplay_areas: Node2D = $World/GameplayAreas
@onready var ui: CanvasLayer = $UI

var _player: CharacterBody2D
var _checkpoint_position: Vector2 = START_POSITION
var _score: int = 0
var _coins: int = 0
var _deaths: int = 0
var _respawning: bool = false
var _finished: bool = false

var _score_label: Label
var _help_label: Label
var _pause_label: Label
var _finish_panel: PanelContainer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_level()
	_build_gameplay_objects()
	_build_ui()
	_spawn_player()
	_update_hud()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_toggle_pause()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("restart"):
		if _finished:
			get_tree().paused = false
			get_tree().reload_current_scene()
		else:
			_request_respawn()
		get_viewport().set_input_as_handled()


func _draw() -> void:
	draw_rect(Rect2(-400.0, -400.0, 4300.0, 1300.0), Color("#77c8f5"))
	draw_circle(Vector2(260.0, 105.0), 68.0, Color("#ffe58a"))

	for cloud_position: Vector2 in [
		Vector2(420.0, 120.0), Vector2(1080.0, 175.0), Vector2(1770.0, 105.0),
		Vector2(2440.0, 155.0), Vector2(3110.0, 95.0)
	]:
		draw_circle(cloud_position, 32.0, Color("#e9f8ff"))
		draw_circle(cloud_position + Vector2(38.0, 6.0), 24.0, Color("#e9f8ff"))
		draw_circle(cloud_position + Vector2(-35.0, 9.0), 21.0, Color("#e9f8ff"))

	for index: int in range(8):
		var base_x: float = float(index) * 520.0 - 220.0
		draw_colored_polygon(
			PackedVector2Array([
				Vector2(base_x, FLOOR_Y),
				Vector2(base_x + 250.0, 205.0 + float(index % 2) * 35.0),
				Vector2(base_x + 520.0, FLOOR_Y),
			]),
			Color("#59ad91")
		)


func _build_level() -> void:
	_add_platform(Vector2(450.0, 500.0), Vector2(900.0, 80.0))
	_add_platform(Vector2(1375.0, 500.0), Vector2(650.0, 80.0))
	_add_platform(Vector2(2200.0, 500.0), Vector2(700.0, 80.0))
	_add_platform(Vector2(3050.0, 500.0), Vector2(700.0, 80.0))

	_add_platform(Vector2(590.0, 382.0), Vector2(170.0, 28.0))
	_add_platform(Vector2(820.0, 306.0), Vector2(130.0, 26.0))
	_add_platform(Vector2(1150.0, 392.0), Vector2(150.0, 28.0))
	_add_platform(Vector2(1450.0, 318.0), Vector2(170.0, 28.0))
	_add_platform(Vector2(1680.0, 244.0), Vector2(130.0, 26.0))
	_add_platform(Vector2(2070.0, 380.0), Vector2(180.0, 28.0))
	_add_platform(Vector2(2320.0, 304.0), Vector2(150.0, 28.0))
	_add_platform(Vector2(2520.0, 232.0), Vector2(120.0, 26.0))
	_add_platform(Vector2(2810.0, 382.0), Vector2(150.0, 28.0))
	_add_platform(Vector2(3050.0, 306.0), Vector2(180.0, 28.0))

	_add_platform(Vector2(-30.0, 250.0), Vector2(60.0, 700.0), Color("#315567"))


func _build_gameplay_objects() -> void:
	for coin_position: Vector2 in [
		Vector2(420.0, 405.0), Vector2(555.0, 335.0), Vector2(625.0, 335.0),
		Vector2(820.0, 255.0), Vector2(1090.0, 345.0), Vector2(1210.0, 345.0),
		Vector2(1395.0, 270.0), Vector2(1460.0, 270.0), Vector2(1525.0, 270.0),
		Vector2(1680.0, 198.0), Vector2(2030.0, 332.0), Vector2(2110.0, 332.0),
		Vector2(2320.0, 256.0), Vector2(2520.0, 184.0), Vector2(2780.0, 334.0),
		Vector2(2840.0, 334.0), Vector2(2990.0, 258.0), Vector2(3060.0, 258.0),
		Vector2(3260.0, 402.0)
	]:
		_add_coin(coin_position)

	_add_enemy(Vector2(285.0, 420.0), 90.0)
	_add_enemy(Vector2(1270.0, 420.0), 120.0)
	_add_enemy(Vector2(2070.0, 420.0), 95.0)
	_add_enemy(Vector2(2900.0, 420.0), 100.0)

	_add_spikes(Rect2(690.0, 436.0, 96.0, 24.0))
	_add_spikes(Rect2(1480.0, 436.0, 64.0, 24.0))
	_add_spikes(Rect2(2260.0, 436.0, 96.0, 24.0))
	_add_spikes(Rect2(3100.0, 436.0, 96.0, 24.0))
	_add_death_zone()
	_add_checkpoint(Vector2(1940.0, FLOOR_Y))
	_add_goal(Vector2(3290.0, FLOOR_Y))


func _add_platform(center: Vector2, size: Vector2, color: Color = Color("#815a3c")) -> void:
	var body := StaticBody2D.new()
	body.position = center
	body.collision_layer = 1
	body.collision_mask = 0

	var shape := RectangleShape2D.new()
	shape.size = size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	body.add_child(collision)

	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([
		Vector2(-size.x * 0.5, -size.y * 0.5),
		Vector2(size.x * 0.5, -size.y * 0.5),
		Vector2(size.x * 0.5, size.y * 0.5),
		Vector2(-size.x * 0.5, size.y * 0.5),
	])
	visual.color = color
	body.add_child(visual)

	if size.x > 80.0 and size.y < 100.0:
		var top_strip := Polygon2D.new()
		top_strip.polygon = PackedVector2Array([
			Vector2(-size.x * 0.5, -size.y * 0.5),
			Vector2(size.x * 0.5, -size.y * 0.5),
			Vector2(size.x * 0.5, -size.y * 0.5 + 8.0),
			Vector2(-size.x * 0.5, -size.y * 0.5 + 8.0),
		])
		top_strip.color = Color("#75d35b")
		top_strip.z_index = 1
		body.add_child(top_strip)

	level.add_child(body)


func _add_coin(coin_position: Vector2) -> void:
	var coin: Area2D = COIN_SCENE.instantiate() as Area2D
	coin.position = coin_position
	coin.connect("collected", Callable(self, "_on_coin_collected"))
	pickups.add_child(coin)


func _add_enemy(enemy_position: Vector2, patrol_distance: float) -> void:
	var enemy: CharacterBody2D = ENEMY_SCENE.instantiate() as CharacterBody2D
	enemy.position = enemy_position
	enemy.set("patrol_distance", patrol_distance)
	enemy.connect("defeated", Callable(self, "_on_enemy_defeated"))
	actors.add_child(enemy)


func _add_spikes(rect: Rect2) -> void:
	var area := Area2D.new()
	area.position = rect.get_center()
	area.collision_layer = 0
	area.collision_mask = 2

	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collision := CollisionShape2D.new()
	collision.shape = shape
	area.add_child(collision)

	var spike_count: int = maxi(1, int(rect.size.x / 24.0))
	var spike_width: float = rect.size.x / float(spike_count)
	for index: int in range(spike_count):
		var left: float = -rect.size.x * 0.5 + float(index) * spike_width
		var spike := Polygon2D.new()
		spike.polygon = PackedVector2Array([
			Vector2(left, rect.size.y * 0.5),
			Vector2(left + spike_width * 0.5, -rect.size.y * 0.5),
			Vector2(left + spike_width, rect.size.y * 0.5),
		])
		spike.color = Color("#ef5361")
		area.add_child(spike)

	area.body_entered.connect(_on_hazard_body_entered)
	gameplay_areas.add_child(area)


func _add_death_zone() -> void:
	var area := Area2D.new()
	area.position = Vector2(LEVEL_RIGHT * 0.5, 690.0)
	area.collision_layer = 0
	area.collision_mask = 2
	var shape := RectangleShape2D.new()
	shape.size = Vector2(LEVEL_RIGHT + 800.0, 180.0)
	var collision := CollisionShape2D.new()
	collision.shape = shape
	area.add_child(collision)
	area.body_entered.connect(_on_hazard_body_entered)
	gameplay_areas.add_child(area)


func _add_checkpoint(checkpoint_position: Vector2) -> void:
	var area := Area2D.new()
	area.position = checkpoint_position
	area.collision_layer = 0
	area.collision_mask = 2
	area.set_meta("respawn_position", checkpoint_position + Vector2(0.0, -50.0))

	var shape := RectangleShape2D.new()
	shape.size = Vector2(70.0, 130.0)
	var collision := CollisionShape2D.new()
	collision.position = Vector2(0.0, -65.0)
	collision.shape = shape
	area.add_child(collision)

	var pole := Polygon2D.new()
	pole.polygon = PackedVector2Array([
		Vector2(-2.0, -112.0), Vector2(2.0, -112.0),
		Vector2(2.0, 0.0), Vector2(-2.0, 0.0),
	])
	pole.color = Color("#d9ecf2")
	area.add_child(pole)
	var flag := Polygon2D.new()
	flag.name = "Flag"
	flag.polygon = PackedVector2Array([
		Vector2(2.0, -108.0), Vector2(36.0, -94.0), Vector2(2.0, -78.0),
	])
	flag.color = Color("#50a8ff")
	area.add_child(flag)

	area.body_entered.connect(_on_checkpoint_body_entered.bind(area))
	gameplay_areas.add_child(area)


func _add_goal(goal_position: Vector2) -> void:
	var goal: Area2D = GOAL_SCENE.instantiate() as Area2D
	goal.position = goal_position
	goal.connect("reached", Callable(self, "_on_goal_reached"))
	gameplay_areas.add_child(goal)


func _spawn_player() -> void:
	var player_instance: Node = PLAYER_SCENE.instantiate()
	_player = player_instance as CharacterBody2D
	if _player == null:
		push_error("Player scene root must be CharacterBody2D")
		return

	_player.position = _checkpoint_position
	_player.set("initialize_spawn_from_scene", true)
	_player.connect("died", Callable(self, "_on_player_died"))
	actors.add_child(_player)
	_player.call("set_spawn_position", _checkpoint_position)

	var camera: Camera2D = _player.get_node_or_null("Camera2D") as Camera2D
	if camera != null:
		camera.limit_left = int(LEVEL_LEFT)
		camera.limit_right = int(LEVEL_RIGHT)
		camera.limit_top = 0
		camera.limit_bottom = int(VIEWPORT_SIZE.y)


func _request_respawn() -> void:
	if _respawning or _finished or not is_instance_valid(_player):
		return
	_player.call("die")


func _on_player_died() -> void:
	if _respawning or _finished:
		return
	_respawning = true
	_deaths += 1
	_update_hud()
	await get_tree().create_timer(0.55).timeout
	if is_instance_valid(_player):
		_player.queue_free()
		await _player.tree_exited
	_spawn_player()
	_respawning = false


func _on_hazard_body_entered(body: Node2D) -> void:
	if body.has_method("die"):
		body.call("die")


func _on_coin_collected(value: int) -> void:
	_coins += value
	_score += value * 100
	_update_hud()


func _on_enemy_defeated(points: int) -> void:
	_score += points
	_update_hud()


func _on_checkpoint_body_entered(body: Node2D, area: Area2D) -> void:
	if not body.has_method("set_spawn_position") or not area.monitoring:
		return
	_checkpoint_position = area.get_meta("respawn_position", START_POSITION) as Vector2
	body.call("set_spawn_position", _checkpoint_position)
	area.set_deferred("monitoring", false)
	var flag: Polygon2D = area.get_node("Flag") as Polygon2D
	flag.color = Color("#ffd84a")
	_score += 500
	_update_hud()


func _on_goal_reached() -> void:
	if _finished:
		return
	_finished = true
	_score += 1000
	_update_hud()
	if is_instance_valid(_player):
		_player.velocity = Vector2.ZERO
		_player.set_physics_process(false)
	_finish_panel.visible = true
	_help_label.text = "Press R to play again"


func _toggle_pause() -> void:
	if _finished:
		return
	get_tree().paused = not get_tree().paused
	_pause_label.visible = get_tree().paused


func _build_ui() -> void:
	_score_label = Label.new()
	_score_label.position = Vector2(20.0, 16.0)
	_score_label.add_theme_font_size_override("font_size", 22)
	_score_label.add_theme_color_override("font_color", Color.WHITE)
	_score_label.add_theme_color_override("font_shadow_color", Color("#17364a"))
	_score_label.add_theme_constant_override("shadow_offset_x", 2)
	_score_label.add_theme_constant_override("shadow_offset_y", 2)
	ui.add_child(_score_label)

	_help_label = Label.new()
	_help_label.text = "A/D or ←/→: Move   •   Space/W/↑: Jump   •   R: Respawn   •   Esc: Pause"
	_help_label.position = Vector2(20.0, 505.0)
	_help_label.add_theme_font_size_override("font_size", 16)
	_help_label.add_theme_color_override("font_color", Color.WHITE)
	_help_label.add_theme_color_override("font_shadow_color", Color("#17364a"))
	_help_label.add_theme_constant_override("shadow_offset_x", 2)
	_help_label.add_theme_constant_override("shadow_offset_y", 2)
	ui.add_child(_help_label)

	_pause_label = Label.new()
	_pause_label.text = "PAUSED\nPress Esc to resume"
	_pause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pause_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_pause_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_pause_label.add_theme_font_size_override("font_size", 34)
	_pause_label.add_theme_color_override("font_color", Color.WHITE)
	_pause_label.add_theme_color_override("font_shadow_color", Color("#17364a"))
	_pause_label.add_theme_constant_override("shadow_offset_x", 3)
	_pause_label.add_theme_constant_override("shadow_offset_y", 3)
	_pause_label.visible = false
	ui.add_child(_pause_label)

	_finish_panel = PanelContainer.new()
	_finish_panel.position = Vector2(285.0, 175.0)
	_finish_panel.size = Vector2(390.0, 175.0)
	var finish_label := Label.new()
	finish_label.text = "LEVEL COMPLETE!\nYou reached the light gate.\n\nPress R to play again"
	finish_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	finish_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	finish_label.add_theme_font_size_override("font_size", 24)
	finish_label.add_theme_color_override("font_color", Color("#17364a"))
	_finish_panel.add_child(finish_label)
	_finish_panel.visible = false
	ui.add_child(_finish_panel)


func _update_hud() -> void:
	if _score_label != null:
		_score_label.text = "SCORE  %06d    CRYSTALS  %02d    DEATHS  %02d" % [_score, _coins, _deaths]
