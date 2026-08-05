extends Control
class_name AboutPanel

signal closed

@onready var _back_button: Button = %BackButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_back_button.pressed.connect(close_panel)
	_back_button.mouse_entered.connect(_play_hover_sound)
	visible = false


func open_panel() -> void:
	visible = true
	_back_button.grab_focus()


func close_panel() -> void:
	if not visible:
		return
	visible = false
	GameAudio.play_sound(&"ui_back", -8.0)
	closed.emit()


func _play_hover_sound() -> void:
	GameAudio.play_sound(&"ui_hover", -12.0)
