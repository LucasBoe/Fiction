extends Node3D
class_name PlacementHandler

@onready var canvas = %CanvasLayer
@onready var inactive_holder = $InactiveObjectHolder
@onready var active_holder = $ActiveObjectHolder

var active = false
var button : Button

signal placement_started
signal placement_finished

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

func _align_all_placeables():
	var placement_position = Vector3i(0, 0, 4)
	
	for child in inactive_holder.get_children():
		child.reparent(active_holder)
		
	for child in active_holder.get_children():
		child.global_position = placement_position
		child.rotation = Vector3.ZERO
		if (child is Moveable):
			var m = (child as Moveable)
			m.rotation_in_degrees = 0
			placement_position += Vector3i(0, 0, m.grid_size.y)
		else:
			placement_position += Vector3i.BACK

func _button_pressed():
	
	if not active:
		return
		
	active = false
	
	button.pressed.disconnect(_button_pressed)
	button.queue_free()

	emit_signal("placement_finished")
