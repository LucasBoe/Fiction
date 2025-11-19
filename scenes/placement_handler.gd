extends Node3D
class_name PlacementHandler

@onready var canvas = %CanvasLayer

var active = false
var button : Button

signal placement_started
signal placement_finished

func run_placement_phase() -> void:

	if active:
		return

	active = true
	
	button = Button.new()
	button.text = "Finish Placement"
	button.pressed.connect(_button_pressed)
	canvas.add_child(button)
	emit_signal("placement_started")

func _button_pressed() -> void:
	
	if not active:
		return
		
	active = false
	
	button.pressed.disconnect(_button_pressed)
	button.queue_free()

	emit_signal("placement_finished")
