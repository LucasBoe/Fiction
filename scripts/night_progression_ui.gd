extends Control
class_name NightProgressionUI

@onready var bar : ProgressBar = $MarginContainer/TextureRect/ProgressBar
@onready var enemy_spawner = %EnemySpawner

func _ready():
	enemy_spawner.begin_night_signal.connect(night_loop)
	enemy_spawner.end_night_signal.connect(night_end)
	hide()
	
func night_loop():
	show()
	while visible:
		bar.value = enemy_spawner.night_progression * 100.0
		await get_tree().process_frame
	
func night_end():
	hide()
