extends Moveable
class_name Wagon

@onready var body = $WagonBody
@onready var lantern_light := find_child("LanternLight") as Light3D
@onready var range_visualization = $RangeVisualization

@export var display_name = ""
@export var display_description = ""
@export var upgrades : Array[WagonUpgrade]

@export var day_tween_time: float = 1
@export var night_tween_time: float = 4

@export var is_enemy_target = true

var _original_energy: float = 0.0
const WAGON_SCENE_PATH = "res://scenes/wagons/"

static var wagons : Array

func _ready():
	if lantern_light:
		# remember whatever the light was set to in the editor
		_original_energy = lantern_light.light_energy
		
		Globals.environment.set_day_signal.connect(on_set_day)
		Globals.environment.set_evening_signal.connect(on_set_evening)
		Globals.environment.set_night_signal.connect(on_set_night)
	
	RaycastHandler.on_hover_enter.connect(_on_hover_enter)
	RaycastHandler.on_hover_exit.connect(_on_hover_exit)
	
	#make sure ugrades are new and unique
	var upgrade_instances : Array[WagonUpgrade]
	for upgrade in upgrades:
		var instance = upgrade.duplicate()
		instance.original_wagon = self
		upgrade_instances.append(instance)
	upgrades = upgrade_instances
	
	if range_visualization:
		range_visualization.hide()
	
	wagons.append(self)

func _on_hover_enter (wagon):
	if wagon == self && range_visualization:
		range_visualization.show()

func _on_hover_exit ():
	if range_visualization:
		range_visualization.hide()

func on_set_day():		
	if not lantern_light:
		return
	
	var tween := create_tween()
	tween.tween_property(lantern_light, "light_energy", 0.0, day_tween_time)

func on_set_evening():
	if range_visualization != null:
		range_visualization.get_child(0).show()
		
	if not lantern_light:
		return
	
	var tween := create_tween()
	tween.tween_interval(1)
	tween.tween_property(lantern_light, "light_energy", _original_energy, night_tween_time)

func on_set_night():
	if range_visualization != null:
		range_visualization.get_child(0).hide()
		
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
	var i := wagons.size() - 1
	while i >= 0:
		if not is_instance_valid(wagons[i]):
			wagons.remove_at(i)
		i -= 1
	return wagons
