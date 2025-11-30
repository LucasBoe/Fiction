extends Node3D
class_name PlacementHandler

@onready var canvas = %CanvasLayer
@onready var inactive_holder = $InactiveObjectHolder
@onready var active_holder = $ActiveObjectHolder

var button : Button

func _ready():
	Globals.placement_handler = self

func run_placement_phase():
	_align_all_placeables()

func reset_placement():
	#migrate all placed objects to inactive parent
	for child in active_holder.get_children():
		child.reparent(inactive_holder)
		child.visible = false
		child.global_position = Vector3(0,-10,0)

func _align_all_placeables():
	var placement_position = Vector3(-7.5, 0, -4.5)
	
	for child in inactive_holder.get_children():
		child.reparent(active_holder)	
		child.visible = true
	
	var all_wagons = active_holder.get_children()
	for child in all_wagons:
		child.global_position = placement_position
		child.rotation = Vector3.ZERO
		if (child is Moveable):
			var m = (child as Moveable)
			var local_offset = Vector3(0, 0, 0 if _is_odd(m.grid_size.y) else 0.5)
			child.global_position += local_offset
			m.rotation_in_degrees = 0
			placement_position += Vector3(0, 0, m.grid_size.y)
			child.global_position += Vector3(0 if _is_odd(m.grid_size.x) else .5,0,0)
		else:
			placement_position += Vector3.BACK
			
	RaycastHandler.all_wagons = all_wagons
	
func _is_odd(x: int):
	return x % 2 != 0
