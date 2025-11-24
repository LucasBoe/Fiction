extends Node

@onready var canvas_layer = $CanvasLayer

func _ready():
	canvas_layer.visible = false
	
func show_canvas():
	canvas_layer.show()
	
func _process(delta):
	if not canvas_layer.visible:
		return
		
	if Input.is_action_just_pressed("restart"):
		Globals.map_loader.get_tree().reload_current_scene()
		canvas_layer.hide()
