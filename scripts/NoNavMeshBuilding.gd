extends Building
class_name NoNavMeshBuilding

func _ready():
	super._ready()
	
	await get_tree().process_frame
	
	Globals.map_loader.unloaded_map.connect(_on_unloaded_map)
	
	var new_parent = Globals.placement_handler
	get_parent().remove_child(self)
	new_parent.add_child(self)

func _on_unloaded_map():
	destroy()
