extends StaticBody3D
class_name TriggerBase

var display_name = ""
const display_description = ""

func on_click() -> void:
	return
	
func notify_enter():
	scale = Vector3(1.1, 1.1, 1.1)
	
func notify_exit():
	scale = Vector3.ONE
	
func is_claimable():
	return false
