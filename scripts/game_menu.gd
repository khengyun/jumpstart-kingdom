extends Control
class_name GameMenu

signal resume_requested
signal restart_requested
signal primary_requested
signal retry_requested
signal settings_requested
signal about_requested
signal main_menu_requested

enum MenuMode {
	NONE,
	PAUSE,
	WIN,
	LOST,
}

@onready var _pause_panel: PanelContainer = %PausePanel
@onready var _win_panel: PanelContainer = %WinPanel
@onready var _lost_panel: PanelContainer = %LostPanel
@onready var _resume_button: Button = %ResumeButton
@onready var _restart_button: Button = %RestartButton
@onready var _primary_button: Button = %PrimaryButton
@onready var _win_level_title: Label = %WinLevelTitle
@onready var _win_score_value: Label = %WinScoreValue
@onready var _retry_button: Button = %RetryButton
@onready var _lost_level_title: Label = %LostLevelTitle
@onready var _lost_score_value: Label = %LostScoreValue

var _mode: MenuMode = MenuMode.NONE


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	%ResumeButton.pressed.connect(func() -> void: resume_requested.emit())
	%RestartButton.pressed.connect(_on_restart_pressed)
	%PauseSettingsButton.pressed.connect(_on_settings_pressed)
	%PauseMainMenuButton.pressed.connect(_on_main_menu_pressed)
	%PrimaryButton.pressed.connect(_on_primary_pressed)
	%RetryButton.pressed.connect(_on_retry_pressed)
	%WinSettingsButton.pressed.connect(_on_settings_pressed)
	%WinAboutButton.pressed.connect(_on_about_pressed)
	%WinMainMenuButton.pressed.connect(_on_main_menu_pressed)
	%LostSettingsButton.pressed.connect(_on_settings_pressed)
	%LostAboutButton.pressed.connect(_on_about_pressed)
	%LostMainMenuButton.pressed.connect(_on_main_menu_pressed)
	_bind_hover_sounds()
	hide_menu()


func show_pause() -> void:
	_mode = MenuMode.PAUSE
	visible = true
	_pause_panel.visible = true
	_win_panel.visible = false
	_lost_panel.visible = false
	_resume_button.grab_focus()


func show_win(has_next_level: bool, level_title: String, score: int) -> void:
	_mode = MenuMode.WIN
	visible = true
	_pause_panel.visible = false
	_win_panel.visible = true
	_lost_panel.visible = false
	_primary_button.text = "NEXT LEVEL" if has_next_level else "PLAY AGAIN"
	_win_level_title.text = "%s cleared" % level_title
	_win_score_value.text = "%06d" % score
	_primary_button.grab_focus()


func show_lost(level_title: String, score: int) -> void:
	_mode = MenuMode.LOST
	visible = true
	_pause_panel.visible = false
	_win_panel.visible = false
	_lost_panel.visible = true
	_lost_level_title.text = "Power lost in %s" % level_title
	_lost_score_value.text = "%06d" % score
	_retry_button.grab_focus()


func hide_menu() -> void:
	_mode = MenuMode.NONE
	visible = false
	_pause_panel.visible = false
	_win_panel.visible = false
	_lost_panel.visible = false


func restore_focus() -> void:
	if _mode == MenuMode.PAUSE:
		_resume_button.grab_focus()
	elif _mode == MenuMode.WIN:
		_primary_button.grab_focus()
	elif _mode == MenuMode.LOST:
		_retry_button.grab_focus()


func _bind_hover_sounds() -> void:
	for node: Node in find_children("*", "BaseButton", true, false):
		var button := node as BaseButton
		if button != null:
			button.mouse_entered.connect(_play_hover_sound)


func _play_hover_sound() -> void:
	GameAudio.play_sound(&"ui_hover", -12.0)


func _on_restart_pressed() -> void:
	GameAudio.play_sound(&"ui_confirm", -8.0)
	restart_requested.emit()


func _on_primary_pressed() -> void:
	GameAudio.play_sound(&"ui_confirm", -8.0)
	primary_requested.emit()


func _on_retry_pressed() -> void:
	GameAudio.play_sound(&"ui_confirm", -8.0)
	retry_requested.emit()


func _on_settings_pressed() -> void:
	GameAudio.play_sound(&"ui_confirm", -8.0)
	settings_requested.emit()


func _on_about_pressed() -> void:
	GameAudio.play_sound(&"ui_confirm", -8.0)
	about_requested.emit()


func _on_main_menu_pressed() -> void:
	main_menu_requested.emit()
