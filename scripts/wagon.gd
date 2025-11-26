extends Moveable
class_name Wagon

@onready var body = $WagonBody
@onready var lantern_light := find_child("LanternLight") as Light3D

@export var display_name = ""
@export var upgrades : Array[WagonUpgrade]

@export var day_tween_time: float = 1
@export var night_tween_time: float = 4

var _original_energy: float = 0.0
const WAGON_SCENE_PATH = "res://scenes/wagons/"

static var wagons : Array

func _ready():
	if lantern_light:
		# remember whatever the light was set to in the editor
		_original_energy = lantern_light.light_energy
		
		Globals.environment.set_day_signal.connect(on_set_day)
		Globals.environment.set_evening_signal.connect(on_set_day)
		Globals.environment.set_night_signal.connect(on_set_night)
		
	for upgrade in upgrades:
		upgrade.original_wagon = self
	
	wagons.append(self)

func on_set_day():
	if not lantern_light:
		return
	
	var tween := create_tween()
	tween.tween_property(lantern_light, "light_energy", 0.0, day_tween_time)

func on_set_night():
	if not lantern_light:
		return
	
	var tween := create_tween()
	tween.tween_interval(1)
	tween.tween_property(lantern_light, "light_energy", _original_energy, night_tween_time)
	
static func get_all_wagon_scene_paths():
	var wagons = FileUtil.get_all_file_paths(WAGON_SCENE_PATH)
	for wagon in wagons:
		if wagon.contains("debris") or wagon.contains("money"):
			wagons.erase(wagon)
			
	return wagons
	
static func get_all_active_wagons():
	for wagon in wagons:
		if not is_instance_valid(wagon):
			wagons.erase(wagon)
			
	return wagons
