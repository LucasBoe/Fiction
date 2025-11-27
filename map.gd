extends Node3D
class_name MapData

@export var difficulty : int
@export var keywords : Array[LocationKeyword]

#@onready var wave_spawn_point = $WaveSpawnPoint

var houses : Array
var blocked_positions : Array[Vector2i]
var display_name : String
const names = ["Alderbrook","Amberfield","Ashbourne","Baywick","Birch Hollow","Blackwater","Blue Harbor","Briar Glen","Bristlecone","Brookhaven","Cedarfall","Cedar Vale","Cloverford","Coldstream","Copper Cove","Cinder Ridge","Crystalford","Dawnhaven","Driftwood Bay","Eaglecrest","Elmspire","Emberfield","Fableton","Fairmeadow","Fern Hollow","Foxglove","Frost Harbor","Gildershire","Goldenbrook","Greenhaven","Hallowmere","Harborview","Hazelwick","Hearthstead","Highgate","Hillcrest","Hollowbrook","Honeybridge","Ironwood","Iverton","Juniper Ridge","Kestrel Point","Kingsvale","Lakebright","Lantern Bay","Larkspur","Larkvale","Laurelspine","Lilac Grove","Linden Falls","Little Wren","Mapleford","Marshlight","Meadowrun","Millstone","Mistwood","Moonhaven","Mossy Glen","Northwind","Oakfield","Oakhollow","Osprey Point","Pebblebrook","Pine Harbor","Pinecrest","Redfern","Riverbend","Riverhollow","Rosemead","Rowanbridge","Sable Creek","Sage Meadow","Sandbar","Seabright","Seagrass","Silverpine","Silverrun","Skylark","Snowvale","Sparrow Falls","Springtide","Starling","Steeplechase","Stonemere","Stormhaven","Sunfield","Sunhollow","Thimblewick","Thornberry","Thistlewick","Tidewater","Timberfall","Tranquil Bay","Tumblebrook","Velvet Harbor","Westering","Westmere","Whitebridge","Willowfen","Windemere"]

enum LocationKeyword {
	VILLAGE,
	CASTLE,
	FARM,
}

func _ready():
	houses = find_child("Houses").get_children()
	display_name = names.pick_random()
	blocked_positions = find_blocked_position()
	GridVisualizer.refresh_blocked(blocked_positions)
	
func find_blocked_position():
	var blocked : Array[Vector2i]
	
	for x : int in GridVisualizer.GRID_SIZE:
		for y : int in GridVisualizer.GRID_SIZE:
			
			var space_state = get_world_3d().direct_space_state
			var pos = GridVisualizer.grid_to_world_position(x,y) + Vector3.UP
			var size = Vector3(.5,1,.5)
			
			var collisions = PhysicsUtil.boxcast_for_objects(space_state,pos, size)
			var counted_collisions = collisions.size()
			
			print("c: ", pos, collisions)
			
			if counted_collisions > 0:
				blocked.append(Vector2i(x,y))
				
	return blocked
