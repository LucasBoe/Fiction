extends Node3D

var map_folder_path = "res://scenes/maps/";

var currently_loaded_map

signal loaded_map

func load_random_map():
	var random_map = FileUtil.get_all_file_paths(map_folder_path).pick_random()
	load_map_from_path(random_map)
	
func unload_current_map():
	currently_loaded_map.queue_free()
	currently_loaded_map = null

func load_map_from_path(path):
	
	if currently_loaded_map:
		unload_current_map()
	
	var scene = ResourceLoader.load(path)
	currently_loaded_map = scene.instantiate()
	add_child(currently_loaded_map)
	print("Loaded Map!")
	emit_signal("loaded_map")
	
