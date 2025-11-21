extends Node3D
class_name MapData

@export var difficulty : int
@export var keywords : LocationKeyword

@onready var wave_spawn_point = $WaveSpawnPoint

enum LocationKeyword {
	HAS_SMITH_OR_IS_CASTLE,
	HAS_WAGNER,
	FIRE,
	STARVING,
	BANDITS
}
