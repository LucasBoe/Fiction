extends MarginContainer
class_name TutorialUI

@onready var line_dummy : TutorialLine = $MarginContainer/VBoxContainer/TutorialLine

var move_camera
var zoom_in_out
var toggle_top
var rotate_wagon
var place_kings
var place_others
var finish_place

func _ready():
	line_dummy.visible = false
	Globals.tutorial = self
	
	move_camera = create_line("Use WASD to move the camera")
	zoom_in_out = create_line("Use the mouse wheel to zoom in / out")
	toggle_top = create_line("Use TAB to toggle top down camera")
	rotate_wagon = create_line("Use SPACE or RMB to rotate wagons")
	place_kings = create_line("Place Kings Wagon at safe location")
	place_others = create_line("Place defensive Wagons")
	finish_place = create_line("Finish placement")
	
func create_line(text):
	var line_instance = line_dummy.duplicate()
	line_dummy.get_parent().add_child(line_instance)
	line_instance.show()
	line_instance.text_label.text = text
	return line_instance
