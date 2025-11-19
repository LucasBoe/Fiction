extends Node3D

var map_folder_path = "res://scenes/maps/";

signal loaded_map

func _ready():
	var random_map = get_all_file_paths(map_folder_path).pick_random()
	load_map_from_path(random_map)
	
func get_all_file_paths(path: String) -> Array[String]:
	var file_paths: Array[String] = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	
	var file_name = dir.get_next()
	
	while file_name != "":
		var file_path = path + "/" + file_name
		if dir.current_is_dir():
			file_paths += get_all_file_paths(file_path)
		else:
			file_paths.append(file_path)
			file_name = dir.get_next()
			
	return file_paths
	
func load_map_from_path(path):
	var scene = ResourceLoader.load(path)
	var instance = scene.instantiate()
	add_child(instance)
	emit_signal("loaded_map")
	print("Loaded Map!")
	
