extends Node3D
class_name Building

@export var is_enemy_target = false # will be actively focused
@export var can_be_damaged_by_enemy = false # not focused but will receive damage
@export var reward_amount_base = 10
@export var debris_mesh = preload("res://scenes/debris/house_1x1_debris.tscn")

@export var display_name = ""
@export var display_description = ""

@export var day_tween_time: float = 1
@export var night_tween_time: float = 4

var health : Health
var reward_trigger : RewardTrigger

@onready var lights_root := get_node_or_null("Lights")
var _lights: Array[Light3D] = []
var _original_energy := {}

func _ready():
	
	if is_enemy_target or can_be_damaged_by_enemy:
		health = $Health
		if health == null:
			print(name, " want's to be damaged but does not cointain health object")
		else:
			health.is_empty.connect(destroy)
		
	reward_trigger = find_child("RewardTrigger")
	if reward_trigger:
		reward_trigger.visible = false
	
	if lights_root:
		_collect_lights(lights_root)
		if _lights.size() > 0:
			for l in _lights:
				_original_energy[l] = l.light_energy

			Globals.environment.set_day_signal.connect(on_set_day)
			Globals.environment.set_evening_signal.connect(on_set_day)
			Globals.environment.set_night_signal.connect(on_set_night)

func _collect_lights(node: Node):
	for child in node.get_children():
		if child is Light3D:
			_lights.append(child)
		if child.get_child_count() > 0:
			_collect_lights(child)

func on_set_day():
	if _lights.is_empty():
		return

	for l in _lights:
		var tween := create_tween()
		tween.tween_property(l, "light_energy", 0.0, day_tween_time)

func on_set_night():
	if _lights.is_empty():
		return

	for l in _lights:
		var target_energy: float = _original_energy.get(l, 1.0)
		var tween := create_tween()
		tween.tween_interval(1)
		tween.tween_property(l, "light_energy", target_energy, night_tween_time)

func destroy():
	if Globals.map_loader.currently_loaded_map != null:
		(Globals.map_loader.currently_loaded_map as MapData).houses.erase(self)
	
		var instance = debris_mesh.instantiate() as Node3D
		Globals.map_loader.currently_loaded_map.add_child(instance)
		instance.global_transform = global_transform
	
	SoundPlayer.play3D(SoundPlayer.building_destroy, global_position)
	
	queue_free()
	Globals.map_loader.rebuild_navigation()
	
