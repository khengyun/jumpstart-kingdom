extends Node

const SETTINGS_PATH: String = "user://settings.cfg"
const MASTER_BUS: StringName = &"Master"

var master_volume: float = 0.8
var master_muted: bool = false


func _ready() -> void:
	_load_settings()
	_apply_audio_settings()


func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_apply_audio_settings()
	_save_settings()


func set_master_muted(value: bool) -> void:
	master_muted = value
	_apply_audio_settings()
	_save_settings()


func _apply_audio_settings() -> void:
	var bus_index: int = AudioServer.get_bus_index(MASTER_BUS)
	if bus_index < 0:
		return
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(master_volume, 0.0001)))
	AudioServer.set_bus_mute(bus_index, master_muted)


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	master_volume = clampf(float(config.get_value("audio", "master_volume", 0.8)), 0.0, 1.0)
	master_muted = bool(config.get_value("audio", "master_muted", false))


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "master_muted", master_muted)
	var error: Error = config.save(SETTINGS_PATH)
	if error != OK:
		push_warning("Could not save audio settings: %s" % error_string(error))
