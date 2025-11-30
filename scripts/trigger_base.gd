extends StaticBody3D
class_name TriggerBase

func on_click() -> void:
	return
	
func notify_enter():
	scale = Vector3(1.1, 1.1, 1.1)
	
func notify_exit():
	scale = Vector3.ONE
