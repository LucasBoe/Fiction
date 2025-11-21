extends Node3D
class_name MapLoader

const PATH = "path"
const DIFFICULTY = "difficulty"
const KEYWORDS = "keywords"
const map_folder_path = "res://scenes/maps/";

var currently_loaded_map
var map_infos : Array

signal loaded_map

func _ready():
	Globals.map_loader = self
	_index_all_map_infos()

func _index_all_map_infos():
	var paths = FileUtil.get_all_file_paths(map_folder_path)
	for path in paths:
		var scene = ResourceLoader.load(path)
		var map = scene.instantiate() as MapData
		map_infos.append({
			PATH: path,
			DIFFICULTY: map.difficulty,
			KEYWORDS: map.keywords
		})
		map.queue_free()
	print("indexed ", map_infos.size(), " map infos")

func load_map_based_on_keywords(keywords):
	var potential_maps : Array
	for info in map_infos:
		print("check map ", info[PATH], " and compare keywords ", info[KEYWORDS], " with ", keywords)
		for keyword in info[KEYWORDS]:
			if not keywords.has(keyword):
				print("map ", info[PATH], " keywords (", keyword, ") does not match keywords (", keywords, ")")
				break
				
		potential_maps.append(info[PATH])
		
	if potential_maps.is_empty():
		print("no matching map found for keywords - loading random")
		load_random_map()
		
	load_map_from_path(potential_maps.pick_random())

func load_random_map():
	var random_map = map_infos.pick_random()
	load_map_from_path(random_map[PATH])
	
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
	
