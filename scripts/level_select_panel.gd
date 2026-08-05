extends Control
class_name LevelSelectPanel

signal level_selected(level_index: int)
signal closed

@onready var _level_buttons: VBoxContainer = %LevelButtons
@onready var _empty_state: Label = %EmptyState
@onready var _level_scroll: ScrollContainer = %LevelScroll
@onready var _back_button: Button = %BackButton

var _buttons: Array[Button] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_back_button.pressed.connect(close_panel)
	_back_button.mouse_entered.connect(_play_hover_sound)
	visible = false


func open_panel(level_titles: PackedStringArray) -> void:
	_rebuild_level_buttons(level_titles)
	_level_scroll.scroll_vertical = 0
	visible = true
	if _buttons.is_empty():
		_back_button.grab_focus()
	else:
		_buttons.front().grab_focus()


func hide_panel() -> void:
	visible = false


func close_panel() -> void:
	if not visible:
		return
	visible = false
	GameAudio.play_sound(&"ui_back", -8.0)
	closed.emit()


func get_level_button_count() -> int:
	return _buttons.size()


func _rebuild_level_buttons(level_titles: PackedStringArray) -> void:
	for child: Node in _level_buttons.get_children():
		_level_buttons.remove_child(child)
		child.queue_free()
	_buttons.clear()
	_empty_state.visible = level_titles.is_empty()

	for index: int in level_titles.size():
		var button := Button.new()
		button.name = "LevelButton%02d" % (index + 1)
		button.custom_minimum_size = Vector2(0.0, 52.0)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text = "LEVEL %02d     %s" % [index + 1, level_titles[index]]
		button.pressed.connect(_select_level.bind(index))
		button.mouse_entered.connect(_play_hover_sound)
		_level_buttons.add_child(button)
		_buttons.append(button)

	_update_focus_neighbors()


func _update_focus_neighbors() -> void:
	if _buttons.is_empty():
		_back_button.focus_neighbor_top = NodePath()
		_back_button.focus_neighbor_bottom = NodePath()
		return

	for index: int in _buttons.size():
		var button: Button = _buttons[index]
		var previous: Control = _back_button if index == 0 else _buttons[index - 1]
		var next: Control = _back_button if index == _buttons.size() - 1 else _buttons[index + 1]
		button.focus_neighbor_top = button.get_path_to(previous)
		button.focus_neighbor_bottom = button.get_path_to(next)

	_back_button.focus_neighbor_top = _back_button.get_path_to(_buttons.back())
	_back_button.focus_neighbor_bottom = _back_button.get_path_to(_buttons.front())


func _select_level(level_index: int) -> void:
	if level_index < 0 or level_index >= _buttons.size():
		return
	GameAudio.play_sound(&"ui_confirm", -8.0)
	level_selected.emit(level_index)


func _play_hover_sound() -> void:
	GameAudio.play_sound(&"ui_hover", -12.0)
