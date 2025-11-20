extends Node3D
class_name PlacementHandler

@onready var canvas = %CanvasLayer
@onready var inactive_holder = $InactiveObjectHolder
@onready var active_holder = $ActiveObjectHolder

var active = false
var button : Button

signal placement_started
signal placement_finished

func _ready():
	Globals.placement_handler = self

func run_placement_phase():

	if active:
		return

	active = true
	
	_align_all_placeables()
	
	button = Button.new()
	button.text = "Finish Placement"
	button.pressed.connect(_button_pressed)
	canvas.add_child(button)
	emit_signal("placement_started")

func reset_placement():
	#migrate all placed objects to inactive parent
	for child in active_holder.get_children():
		child.reparent(inactive_holder)
		
func get_next_potential_target(position):
	
	var all_targets : Array
	for child in active_holder.get_children():
		if child is WagonMoney:
			all_targets.append(child)
			
	if all_targets.is_empty():
		return null
		
	var closestSquaredDistance = INF
	var closestNode = null
	for target in all_targets:
		var squaredDistance = target.global_position.distance_squared_to(position)
		if squaredDistance < closestSquaredDistance:
			closestSquaredDistance = squaredDistance
			closestNode = target

	return closestNode	

func _align_all_placeables():
	var placement_position = Vector3(0.5, 0, 4.5)
	
	for child in inactive_holder.get_children():
		child.reparent(active_holder)
		
	for child in active_holder.get_children():
		child.global_position = placement_position
		child.rotation = Vector3.ZERO
		if (child is Moveable):
			var m = (child as Moveable)
			m.rotation_in_degrees = 0
			placement_position += Vector3(0, 0, m.grid_size.y)
			child.global_position += Vector3(0 if _is_odd(m.grid_size.x) else .5,0,0)
		else:
			placement_position += Vector3i.BACK

func _button_pressed():
	
	if not active:
		return
		
	active = false
	
	button.pressed.disconnect(_button_pressed)
	button.queue_free()

	emit_signal("placement_finished")
	
func _is_odd(x: int):
	return x % 2 != 0
