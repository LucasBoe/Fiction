extends Resource
class_name WagonUpgrade

var original_wagon : Wagon
@export var upgrade_cost = 0
@export var upgrade_name : String
@export var upgrade_wagon : PackedScene
@export var upgrade_icon : Texture2D

static func execute(upgrade : WagonUpgrade):
	execute_wagon_upgrade(upgrade.upgrade_wagon.resource_path, upgrade.original_wagon)

static func execute_wagon_upgrade(wagon_path, original_wagon = null):
	if not wagon_path.is_empty():
		var scene = ResourceLoader.load(wagon_path)
		var instance = scene.instantiate()
		Globals.placement_handler.active_holder.add_child(instance)
		instance.global_position = Vector3(0,-10,0)
		
	if original_wagon != null:
		original_wagon.queue_free()

static func get_all_possible_upgrades():
	var pool : Array[WagonUpgrade]
	for wagon : Wagon in Wagon.get_all_active_wagons():
		if wagon.upgrades.size() == 0:
			continue
				
		if pool.any(func(w: WagonUpgrade): return upgrade_is_for_wagon(w, wagon)):
			continue
				
		pool.append_array(wagon.upgrades)
	return pool
		
static func upgrade_is_for_wagon(w : WagonUpgrade, wagon):
	
	if wagon == null:
		return false
		
	if w.original_wagon == null:
		return false
	
	return w.original_wagon.name == wagon.name
