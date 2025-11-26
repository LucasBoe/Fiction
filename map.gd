extends Node3D
class_name MapData

@export var difficulty : int
@export var keywords : Array[LocationKeyword]

#@onready var wave_spawn_point = $WaveSpawnPoint

var houses : Array
var blocked_positions : Array[Vector2i]

enum LocationKeyword {
	VILLAGE,
	CASTLE,
	FARM,
}

func _ready():
	houses = find_child("Houses").get_children()
	blocked_positions = find_blocked_position()
	GridVisualizer.refresh_blocked(blocked_positions)
	
func find_blocked_position():
	var blocked : Array[Vector2i]
	
	for x : int in GridVisualizer.GRID_SIZE:
		for y : int in GridVisualizer.GRID_SIZE:
			
			var space_state = get_world_3d().direct_space_state
			var pos = GridVisualizer.grid_to_world_position(x,y) + Vector3.UP
			var size = Vector3(.5,1,.5)
			
			var collisions = PhysicsUtil.boxcast_for_objects(space_state, pos, size)
			var counted_collisions = collisions.size()
			
			print("c: ", pos, collisions)
			
			if counted_collisions > 0:
				blocked.append(Vector2i(x,y))
				
	return blocked
