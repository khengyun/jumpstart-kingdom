extends Control
class_name GameHud

@onready var _score_label: Label = %ScoreLabel
@onready var _level_label: Label = %LevelLabel
@onready var _life_icons: Array[TextureRect] = [%LifeIcon1, %LifeIcon2, %LifeIcon3]

func set_stats(score: int, coins: int, _deaths: int, lives: int, level_title: String) -> void:
	_score_label.text = "SCORE  %06d    COINS  %02d" % [score, coins]
	_level_label.text = level_title.to_upper()
	for index: int in range(_life_icons.size()):
		_life_icons[index].visible = index < lives


func show_hud() -> void:
	visible = true


func hide_hud() -> void:
	visible = false
