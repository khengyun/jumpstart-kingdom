extends Control
class_name GameHud

@onready var _score_label: Label = %ScoreLabel
@onready var _level_label: Label = %LevelLabel


func set_stats(score: int, coins: int, deaths: int, level_title: String) -> void:
	_score_label.text = "SCORE  %06d    COINS  %02d    DEATHS  %02d" % [score, coins, deaths]
	_level_label.text = level_title.to_upper()


func show_hud() -> void:
	visible = true


func hide_hud() -> void:
	visible = false
