extends Control
class_name StartMenu

signal play_requested
signal settings_requested
signal about_requested

@onready var _play_button: Button = %PlayButton
@onready var _settings_button: Button = %SettingsButton
@onready var _about_button: Button = %AboutButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_play_button.pressed.connect(_on_play_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_about_button.pressed.connect(_on_about_pressed)
	_bind_hover_sounds()


func show_menu() -> void:
	visible = true
	_play_button.grab_focus()


func hide_menu() -> void:
	visible = false


func restore_focus() -> void:
	if visible:
		_play_button.grab_focus()


func _bind_hover_sounds() -> void:
	for node: Node in find_children("*", "BaseButton", true, false):
		var button := node as BaseButton
		if button != null:
			button.mouse_entered.connect(_play_hover_sound)


func _play_hover_sound() -> void:
	GameAudio.play_sound(&"ui_hover", -12.0)


func _on_play_pressed() -> void:
	GameAudio.play_sound(&"ui_confirm", -8.0)
	play_requested.emit()


func _on_settings_pressed() -> void:
	GameAudio.play_sound(&"ui_confirm", -8.0)
	settings_requested.emit()


func _on_about_pressed() -> void:
	GameAudio.play_sound(&"ui_confirm", -8.0)
	about_requested.emit()
