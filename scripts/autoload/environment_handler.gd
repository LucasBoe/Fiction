extends Node3D
class_name EnvironmentHandler

@onready var spawnPointHolder = $SpawnPoints
var spawnPoints: Array[ArrowIndicator] = []

func _ready():
	Globals.environment_handler = self
	
	_collect_spawn_points(spawnPointHolder)
	
	_hide_wave_indicator()

func _collect_spawn_points(node: Node) -> void:
	for child in node.get_children():
		if child is ArrowIndicator:
			spawnPoints.append(child)
		_collect_spawn_points(child) # recurse into children

func _show_wave_indicator():
	for arrow in spawnPoints:
		arrow.show()

func _hide_wave_indicator():
	for arrow in spawnPoints:
		arrow.hide()
