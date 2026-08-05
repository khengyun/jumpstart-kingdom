extends Node2D

enum AppState {
	TITLE,
	PLAYING,
	PAUSED,
	WON,
	SETTINGS,
	ABOUT,
}

@export var levels: Array[PackedScene] = []

@onready var _session: GameSession = $SessionHost/GameSession
@onready var _backdrop: TextureRect = $Background/Backdrop
@onready var _hud: GameHud = $UI/HUD
@onready var _start_menu: StartMenu = $UI/StartMenu
@onready var _game_menu: GameMenu = $UI/GameMenu
@onready var _settings_panel: SettingsPanel = $UI/SettingsPanel
@onready var _about_panel: AboutPanel = $UI/AboutPanel

var _state: AppState = AppState.TITLE
var _modal_return_state: AppState = AppState.TITLE


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_session.configure(levels)
	_session.stats_changed.connect(_hud.set_stats)
	_session.level_completed.connect(_on_level_completed)
	_session.level_loaded.connect(_on_level_loaded)

	_start_menu.play_requested.connect(_on_play_requested)
	_start_menu.settings_requested.connect(_open_settings)
	_start_menu.about_requested.connect(_open_about)

	_game_menu.resume_requested.connect(_resume_game)
	_game_menu.restart_requested.connect(_restart_level)
	_game_menu.primary_requested.connect(_advance_or_replay)
	_game_menu.settings_requested.connect(_open_settings)
	_game_menu.about_requested.connect(_open_about)
	_game_menu.main_menu_requested.connect(_on_main_menu_requested)

	_settings_panel.closed.connect(_on_modal_closed)
	_about_panel.closed.connect(_on_modal_closed)
	_show_title()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if _state == AppState.SETTINGS:
			_settings_panel.close_panel()
		elif _state == AppState.ABOUT:
			_about_panel.close_panel()
		elif _state == AppState.PLAYING:
			_pause_game()
		elif _state == AppState.PAUSED:
			_resume_game()
		else:
			return
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("restart"):
		if _state == AppState.PLAYING:
			_session.request_respawn()
		elif _state == AppState.WON:
			GameAudio.play_sound(&"ui_confirm", -8.0)
			_advance_or_replay()
		else:
			return
		get_viewport().set_input_as_handled()


func _on_play_requested() -> void:
	if levels.is_empty():
		push_error("Add at least one level scene to Main.levels")
		return
	get_tree().paused = false
	_state = AppState.PLAYING
	_start_menu.hide_menu()
	_game_menu.hide_menu()
	_hud.show_hud()
	_session.start_new_game()


func _show_title() -> void:
	get_tree().paused = false
	GameAudio.stop_all()
	_session.end_run()
	_hud.hide_hud()
	_game_menu.hide_menu()
	_settings_panel.visible = false
	_about_panel.visible = false
	_state = AppState.TITLE
	_start_menu.show_menu()


func _on_main_menu_requested() -> void:
	_show_title()
	GameAudio.play_sound(&"ui_back", -8.0)


func _pause_game() -> void:
	if _state != AppState.PLAYING:
		return
	get_tree().paused = true
	_state = AppState.PAUSED
	_game_menu.show_pause()
	GameAudio.play_sound(&"ui_pause_toggle", -8.0, 0.94, 0.94)


func _resume_game() -> void:
	if _state != AppState.PAUSED:
		return
	get_tree().paused = false
	_state = AppState.PLAYING
	_game_menu.hide_menu()
	GameAudio.play_sound(&"ui_back", -8.0, 1.06, 1.06)


func _restart_level() -> void:
	if _state != AppState.PAUSED:
		return
	get_tree().paused = false
	_state = AppState.PLAYING
	_game_menu.hide_menu()
	_session.restart_current_level()


func _advance_or_replay() -> void:
	if _state != AppState.WON:
		return
	get_tree().paused = false
	_state = AppState.PLAYING
	_game_menu.hide_menu()
	_session.advance_or_replay()


func _on_level_completed(has_next_level: bool, level_title: String, score: int) -> void:
	if _state != AppState.PLAYING:
		return
	get_tree().paused = true
	_state = AppState.WON
	_game_menu.show_win(has_next_level, level_title, score)


func _on_level_loaded(_level_title: String, background_texture: Texture2D) -> void:
	if background_texture != null:
		_backdrop.texture = background_texture


func _open_settings() -> void:
	if _state == AppState.SETTINGS or _state == AppState.ABOUT:
		return
	_modal_return_state = _state
	_state = AppState.SETTINGS
	_settings_panel.open_panel()


func _open_about() -> void:
	if _state == AppState.SETTINGS or _state == AppState.ABOUT:
		return
	_modal_return_state = _state
	_state = AppState.ABOUT
	_about_panel.open_panel()


func _on_modal_closed() -> void:
	_state = _modal_return_state
	if _state == AppState.TITLE:
		_start_menu.restore_focus()
	elif _state == AppState.PAUSED or _state == AppState.WON:
		_game_menu.restore_focus()
