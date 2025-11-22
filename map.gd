extends Node3D
class_name MapData

@export var difficulty : int
@export var keywords : Array[LocationKeyword]

@onready var wave_spawn_point = $WaveSpawnPoint

var houses : Array

enum LocationKeyword {
	HAS_SMITH,
	HAS_WAGNER,
	FARM,
	PLUNDERED
}

func _ready():
	houses = find_child("Houses").get_children()	
