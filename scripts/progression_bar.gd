extends Control
class_name ProgressionBar

@onready var indicator : TextureRect = $Indicator
@onready var location_dummy : TextureRect = $MarginContainer/HBoxContainer/Location
@onready var path_dummy : MarginContainer = $MarginContainer/HBoxContainer/Path

@onready var location_capital_current = preload("res://ui/travel/location_capital_current.png")
@onready var location_capital_unknown = preload("res://ui/travel/location_capital_unknown.png")
@onready var location_current         = preload("res://ui/travel/location_current.png")
@onready var location_done            = preload("res://ui/travel/location_done.png")
@onready var location_unknown         = preload("res://ui/travel/location_unknown.png")
@onready var travel_current           = preload("res://ui/travel/travel_current.png")
@onready var travel_done              = preload("res://ui/travel/travel_done.png")
@onready var travel_unknown           = preload("res://ui/travel/travel_unknown.png")

var locations : Array
var paths : Array

var progression = 0
var phase = phases.CURRENT

enum phases {
	TRAVEL,
	CURRENT,
	DONE
}

func _ready() -> void:
	location_dummy.visible = false
	path_dummy.visible = false
	indicator.visible = false
	
	await get_tree().process_frame
	
	for i in Globals.MAX_LOCATIONS:
		create_location()
		create_path()
	create_location(true)
	
	Globals.map_loader.loaded_map.connect(on_new_map)
	Globals.reward_phase_begin_signal.connect(on_finished_map)
	Globals.reward_phase_end_signal.connect(on_travel)
	
	#progression = 3
	#phase = phases.DONE
	#refresh_visuals()
	
func create_location(is_capital = false):
	var location = create_from_dummy(location_dummy, locations)
	if is_capital:
		location.texture = location_capital_unknown
	
func create_path():
	var path = create_from_dummy(path_dummy, paths)
	
func create_from_dummy(dummy, list = null):
	var instance = dummy.duplicate()
	dummy.get_parent().add_child(instance)
	if list != null:
		list.append(instance)
		
	instance.visible = true
	return instance

func on_new_map():
	progression = Globals.map_loader.map_number
	phase = phases.CURRENT
	refresh_visuals()
	
func on_finished_map():
	progression = Globals.map_loader.map_number
	phase = phases.DONE
	refresh_visuals()

func on_travel():
	progression = Globals.map_loader.map_number
	phase = phases.TRAVEL
	refresh_visuals()

func refresh_visuals():
	var current = roundi(progression - 1.0)
	
	for i in locations.size():
		var location = locations[i] as TextureRect
		var is_captial = location.texture.get_height() > location.texture.get_width()
		
		if i > current:
			location.texture = location_capital_unknown if is_captial else location_unknown
		elif i <= current:
			if phase == phases.CURRENT and i == current:
				location.texture = location_capital_current if is_captial else location_current
				move_indicator(location)
			else:
				location.texture = location_done
		
		var is_current = i == roundi(current) and i > current
		
	for i in paths.size():
		var path = paths[i].get_child(0) as NinePatchRect
		if i < current:
			path.texture = travel_done
		elif i == current and phase == phases.TRAVEL:
			path.texture = travel_current
			move_indicator(path)
		else:
			path.texture = travel_unknown
				
func move_indicator(target : Control):
	
	var target_position = target.global_position + Vector2(target.size.x / 2, target.size.y) - Vector2(indicator.size.x / 2, 4)
	if not indicator.visible:
		indicator.global_position = target_position
		
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(indicator, "global_position", target_position, .25)
	indicator.visible = true
