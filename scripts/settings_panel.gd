extends Control
class_name SettingsPanel

signal closed

@onready var _volume_slider: HSlider = %VolumeSlider
@onready var _volume_value: Label = %VolumeValue
@onready var _mute_check: CheckButton = %MuteCheck
@onready var _back_button: Button = %BackButton

var _syncing: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_volume_slider.value_changed.connect(_on_volume_changed)
	_volume_slider.drag_ended.connect(_on_volume_drag_ended)
	_mute_check.toggled.connect(_on_mute_toggled)
	_back_button.pressed.connect(close_panel)
	_back_button.mouse_entered.connect(_play_hover_sound)
	visible = false


func open_panel() -> void:
	_syncing = true
	_volume_slider.value = GameSettings.master_volume * 100.0
	_mute_check.button_pressed = GameSettings.master_muted
	_update_volume_label()
	_syncing = false
	visible = true
	_volume_slider.grab_focus()


func close_panel() -> void:
	if not visible:
		return
	visible = false
	if not GameSettings.master_muted:
		GameAudio.play_sound(&"ui_back", -8.0)
	closed.emit()


func _on_volume_changed(value: float) -> void:
	_update_volume_label()
	if not _syncing:
		GameSettings.set_master_volume(value / 100.0)


func _on_volume_drag_ended(value_changed: bool) -> void:
	if value_changed and not GameSettings.master_muted:
		GameAudio.play_sound(&"ui_confirm", -10.0)


func _on_mute_toggled(toggled_on: bool) -> void:
	if _syncing:
		return
	GameSettings.set_master_muted(toggled_on)
	if not toggled_on:
		GameAudio.play_sound(&"ui_confirm", -10.0)


func _update_volume_label() -> void:
	_volume_value.text = "%d%%" % int(round(_volume_slider.value))


func _play_hover_sound() -> void:
	GameAudio.play_sound(&"ui_hover", -12.0)
