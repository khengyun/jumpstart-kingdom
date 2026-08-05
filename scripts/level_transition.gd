extends Control
class_name LevelTransition

@onready var _curtain: ColorRect = $Curtain
@onready var _content: VBoxContainer = $Content
@onready var _stage_label: Label = $Content/StageLabel
@onready var _title_label: Label = $Content/TitleLabel
@onready var _accent: ColorRect = $Content/Accent

var _active_tween: Tween
var _content_rest_y: float


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_content_rest_y = _content.position.y
	hide_immediately()


func cover() -> void:
	_kill_tween()
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_curtain.modulate.a = 0.0
	_content.modulate.a = 0.0
	_accent.scale.x = 0.0

	_active_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_active_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(_curtain, "modulate:a", 1.0, 0.38)
	await _active_tween.finished


func reveal(level_title: String, level_number: int) -> void:
	_kill_tween()
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_stage_label.text = "STAGE %02d" % level_number
	_title_label.text = level_title.to_upper()
	_content.position.y = _content_rest_y + 14.0
	_content.modulate.a = 0.0
	_accent.scale.x = 0.0

	_active_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_active_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(_content, "modulate:a", 1.0, 0.26)
	_active_tween.parallel().tween_property(_content, "position:y", _content_rest_y, 0.32)
	_active_tween.parallel().tween_property(_accent, "scale:x", 1.0, 0.34)
	_active_tween.tween_interval(0.72)
	_active_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_active_tween.tween_property(_content, "modulate:a", 0.0, 0.20)
	_active_tween.parallel().tween_property(_curtain, "modulate:a", 0.0, 0.48)
	await _active_tween.finished
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func hide_immediately() -> void:
	_kill_tween()
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_curtain.modulate.a = 0.0
	_content.modulate.a = 0.0
	_content.position.y = _content_rest_y
	_accent.scale.x = 1.0


func _kill_tween() -> void:
	if _active_tween != null and _active_tween.is_valid():
		_active_tween.kill()
	_active_tween = null
