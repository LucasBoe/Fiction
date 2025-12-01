extends Node3D
class_name MapData

@export var difficulty : int
@export var keywords : Array[LocationKeyword]

#@onready var wave_spawn_point = $WaveSpawnPoint

var houses : Array
var blocked_positions : Array[Vector2i]
var display_name : String

const village_names = [
	"Blackmere",
	"Grimwood",
	"Ashbrook",
	"Thornvale",
	"Ravenspire",
	"Barrowstead",
	"Dreadholm",
	"Crowmark",
	"Wyrdfell",
	"Deadwater",
	"Nightford",
	"Murkmire",
	"Gallowsend",
	"Bleakhaven",
	"Bramblehold",
	"Wolfmere",
	"Ironfall",
	"Shadowfen",
	"Vilewood",
	"Darkreach"
]
const castle_names = [
	"Frostheim Ruin",
	"The Broken Hall of Hjal",
	"Grimrock Hold",
	"Coldwach",
	"Jorund’s Fall",
	"Hailspire",
	"The Bleakhold",
	"Stormcrag",
	"The Ruins of Kjorstag",
	"Ashenreach",
	"Stone-Winter Watch",
	"Hroth’s Rest",
	"The Shorn Keep",
	"Skarvum Ruin",
	"Thundermoor Post",
	"The Fallen Longhall",
	"Icevein Hold",
	"The Ruin at Draugrfall",
	"The Old Hold of Skell"
]
const farm_names = [
	"Blackroot Farm",
	"Bramblefield",
	"Crow’s Acre",
	"Rotwillow Farm",
	"Elderfall Croft",
	"Ashthorn Farm",
	"Barrowfield",
	"Widow’s Patch",
	"Gallowsoil Farm",
	"Wyrdacre",
	"Duskmere Field",
	"Greybark Farm",
	"Thornreach Croft",
	"Bleedroot Farm",
	"Nightseed Farm",
	"Murkwheat Fields",
	"Hollowcrop",
	"Raveland Farm",
	"Rustleaf Croft",
	"Cinderfield Farm"
]

enum LocationKeyword {
	VILLAGE,
	CASTLE,
	FARM,
}

func _ready():
	houses = find_child("Houses").get_children()
	display_name = "Shirewood" if keywords.is_empty() else get_random_name(keywords[0])
	blocked_positions = find_blocked_position()
	GridVisualizer.refresh_blocked(blocked_positions)

func get_random_name(keyword : LocationKeyword) -> String:
	if keyword == LocationKeyword.VILLAGE:
		return village_names.pick_random()
	elif keyword == LocationKeyword.CASTLE:
		return castle_names.pick_random()
	return farm_names.pick_random()
	
func check_is_blocked(location):
	var l = GridVisualizer.world_to_grid_position(location - Vector3(.5,.5,.5))
	return blocked_positions.has(l)

func find_blocked_position():
	var blocked : Array[Vector2i]
	
	for x : int in GridVisualizer.GRID_SIZE:
		for y : int in GridVisualizer.GRID_SIZE:
			
			var space_state = get_world_3d().direct_space_state
			var pos = GridVisualizer.grid_to_world_position(x,y) + Vector3.UP
			var size = Vector3(.5,1,.5)
			
			var collisions = PhysicsUtil.boxcast_for_objects(space_state,pos, size)
			var counted_collisions = collisions.size()
			
			if counted_collisions > 0:
				blocked.append(Vector2i(x,y))
				
	return blocked
